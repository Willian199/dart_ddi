part of 'dart_ddi.dart';

class _DDIImpl implements DDI {
  _DDIImpl({required bool enableZoneRegistry})
      : _enableZoneRegistry = enableZoneRegistry;

  final bool _enableZoneRegistry;
  Future<void> _contextWriteQueue = Future<void>.value();
  final Set<Object> _contextsBeingDestroyed = <Object>{};

  late final DartDDIQualifier _beans = _enableZoneRegistry
      ? DartDDIZoneQualifierImpl()
      : DartDDIDefaultQualifierImpl();

  @override
  @pragma('vm:prefer-inline')
  Object get currentContext => _beans.currentContext;

  @override
  @pragma('vm:prefer-inline')
  void createContext(Object context) {
    if (_contextsBeingDestroyed.contains(context)) {
      throw StateError('Context "$context" is being destroyed.');
    }
    _beans.createContext(context);
  }

  @override
  FutureOr<void> destroyContext(Object context) {
    // Re-entrant destroy from module cleanup for the same context should be a no-op.
    // This avoids deadlocks when a context destroy flow triggers another
    // destroyContext(context) before the first one completes.
    if (_contextsBeingDestroyed.contains(context)) {
      return null;
    }

    return _runContextWriteLocked(() async {
      if (!_beans.hasContextQualifier(context)) {
        throw ContextNotFoundException(context.toString());
      }

      // Preflight: validate the full tree before destroying anything,
      // avoiding partial destruction.
      if (_beans.contextHasDestroyBlockers(context)) {
        throw StateError(
          'Context "$context" contains non-destroyable factories.',
        );
      }

      final List<Object> contextOrder =
          _beans.contextDestroyOrder(context).toList();

      _contextsBeingDestroyed.addAll(contextOrder);

      try {
        for (final contextKey in contextOrder) {
          if (!_beans.hasContextQualifier(contextKey)) {
            continue;
          }

          final List<Object> keys =
              _beans.entries(context: contextKey).map((e) => e.key).toList();

          for (final key in keys) {
            final destroyResult = _destroy(key, contextKey);
            if (destroyResult is Future) {
              await destroyResult;
            }
          }
        }

        for (final contextKey in contextOrder) {
          if (!_beans.hasContextQualifier(contextKey)) {
            continue;
          }

          if (_beans.entries(context: contextKey).isNotEmpty) {
            throw StateError(
              'Context "$context" still contains factories after destroy operation.',
            );
          }
        }

        if (_beans.hasContextQualifier(context)) {
          _beans.destroyContext(context);
        }
      } finally {
        for (final contextKey in contextOrder) {
          _contextsBeingDestroyed.remove(contextKey);
        }
      }
    });
  }

  @override
  @pragma('vm:prefer-inline')
  bool contextExists(Object context) => _beans.hasContextQualifier(context);

  @override
  BeanT runInContext<BeanT>(Object name, BeanT Function() body) {
    if (_enableZoneRegistry) {
      return _beans.runWithContext<BeanT>(name, () {
        final BeanT result;

        try {
          result = body();
        } catch (_) {
          _destroyCurrentContextSync();
          rethrow;
        }

        if (result is Future) {
          return (result as Future).whenComplete(() async {
            await _destroyCurrentContextAsync();
          }) as BeanT;
        }

        try {
          return result;
        } finally {
          _destroyCurrentContextSync();
        }
      });
    }

    final Object previousContext = _beans.currentContext;
    return _beans.runWithContext<BeanT>(name, () {
      final BeanT result;

      try {
        result = body();
      } catch (_) {
        try {
          _destroyCurrentContextSync();
        } finally {
          _beans.restoreContext(previousContext);
        }
        rethrow;
      }

      if (result is Future) {
        return (result as Future).whenComplete(() async {
          try {
            await _destroyCurrentContextAsync();
          } finally {
            _beans.restoreContext(previousContext);
          }
        }) as BeanT;
      }

      try {
        return result;
      } finally {
        try {
          _destroyCurrentContextSync();
        } finally {
          _beans.restoreContext(previousContext);
        }
      }
    });
  }

  void _destroyCurrentContextSync() {
    if (!_beans.hasContext) {
      return;
    }

    for (final key in _beans.keys.toList()) {
      _destroy(key, null);
    }
  }

  Future<void> _destroyCurrentContextAsync() async {
    if (!_beans.hasContext) {
      return;
    }

    for (final key in _beans.keys.toList()) {
      final destroyResult = _destroy(key, null);

      if (destroyResult is Future) {
        await destroyResult;
      }
    }
  }

  @override
  Future<void> register<BeanT extends Object>({
    required DDIBaseFactory<BeanT> factory,
    Object? qualifier,
    Object? context,
    FutureOrBoolCallback? canRegister,
  }) async {
    if (BeanT == Object) {
      throw FactoryNotAllowedException(BeanT.toString());
    }

    bool shouldRegister = true;

    if (canRegister != null) {
      if (canRegister is BoolCallback) {
        shouldRegister = canRegister();
      } else {
        shouldRegister = await canRegister();
      }
    }

    if (shouldRegister) {
      final Object effectiveQualifierName = qualifier ?? BeanT;

      if (context != null && !_beans.hasContextQualifier(context)) {
        throw ContextNotFoundException(context.toString());
      }

      final Object registrationContext = context ?? _beans.currentContext;
      if (_contextsBeingDestroyed.contains(registrationContext)) {
        throw StateError(
          'Context "$registrationContext" is being destroyed.',
        );
      }

      final fac = _beans.getFactory<BeanT>(
        qualifier: effectiveQualifierName,
        fallback: false,
        contextQualifier: registrationContext,
      );

      if (fac != null) {
        if (BeanStateEnum.none == fac.factory.state) {
          _beans.removeFactory(
            effectiveQualifierName,
            context: registrationContext,
          );
        } else {
          throw DuplicatedBeanException(effectiveQualifierName.toString());
        }
      }

      // Force the type to be correct. Fixes the behavior with FutureOr and interfaces
      if (factory.type != BeanT) {
        factory.setType<BeanT>();
      }

      _beans.setFactory(
        effectiveQualifierName,
        factory,
        context: registrationContext,
      );

      final f = factory.register(
        qualifier: effectiveQualifierName,
        ddiInstance: this,
      );

      f.onError((e, _) {
        _beans.removeFactory(
          effectiveQualifierName,
          context: registrationContext,
        );
      });

      return f;
    }
  }

  Future<T> _runContextWriteLocked<T>(FutureOr<T> Function() action) {
    final previous = _contextWriteQueue;
    final completer = Completer<void>();
    _contextWriteQueue = completer.future;

    return previous.catchError((_) {}).then((_) async {
      try {
        return await action();
      } finally {
        completer.complete();
      }
    });
  }

  @override
  bool isRegistered<BeanT extends Object>(
      {Object? qualifier, Object? context}) {
    final Object effectiveQualifierName = qualifier ?? BeanT;
    final Object effectiveContext = context ?? currentContext;
    final bool fallbackToRoot = context == null && _beans.hasContext;

    return _beans
            .getFactory(
              qualifier: effectiveQualifierName,
              contextQualifier: effectiveContext,
              fallback: fallbackToRoot,
            )
            ?.factory
            .isRegistered ??
        false;
  }

  @override
  bool isFuture<BeanT extends Object>({Object? qualifier, Object? context}) {
    final Object effectiveQualifierName = qualifier ?? BeanT;
    final Object effectiveContext = context ?? currentContext;
    final bool fallbackToRoot = context == null && _beans.hasContext;
    final located = _beans.getFactory<BeanT>(
      qualifier: effectiveQualifierName,
      contextQualifier: effectiveContext,
      fallback: fallbackToRoot,
    );
    if (located != null) {
      return located.factory.isFuture;
    }

    throw BeanNotFoundException(effectiveQualifierName.toString());
  }

  @override
  bool isReady<BeanT extends Object>({Object? qualifier, Object? context}) {
    final Object effectiveQualifierName = qualifier ?? BeanT;
    final Object effectiveContext = context ?? currentContext;
    final bool fallbackToRoot = context == null && _beans.hasContext;
    final located = _beans.getFactory<BeanT>(
      qualifier: effectiveQualifierName,
      contextQualifier: effectiveContext,
      fallback: fallbackToRoot,
    );
    if (located != null) {
      return located.factory.isReady;
    }

    throw BeanNotFoundException(effectiveQualifierName.toString());
  }

  @override
  BeanT getWith<BeanT extends Object, ParameterT extends Object>({
    ParameterT? parameter,
    Object? qualifier,
    Object? select,
    Object? context,
  }) {
    final Object effectiveQualifierName = qualifier ?? BeanT;
    final Object effectiveContext = context ?? currentContext;
    final bool fallbackToRoot = context == null && _beans.hasContext;

    final located = _beans.getFactory<BeanT>(
      qualifier: effectiveQualifierName,
      contextQualifier: effectiveContext,
      fallback: fallbackToRoot,
    );
    if (located != null) {
      return located.factory.getWith<ParameterT>(
        parameter: parameter,
        qualifier: effectiveQualifierName,
        ddiInstance: this,
      );
    } else if (select != null && BeanT != Object) {
      // Try to find a bean with the selector
      for (final MapEntry(key: _, :value) in _beans.entries(context: context)) {
        if (value.type == BeanT &&
            (value.selector?.call(select) ?? false) as bool) {
          return (value as DDIBaseFactory<BeanT>).getWith<ParameterT>(
            parameter: parameter,
            qualifier: effectiveQualifierName,
            ddiInstance: this,
          );
        }
      }
    }

    throw BeanNotFoundException(effectiveQualifierName.toString());
  }

  @override
  Future<BeanT> getAsyncWith<BeanT extends Object, ParameterT extends Object>({
    ParameterT? parameter,
    Object? qualifier,
    Object? select,
    Object? context,
  }) async {
    final Object effectiveQualifierName = qualifier ?? BeanT;
    final Object effectiveContext = context ?? currentContext;
    final bool fallbackToRoot = context == null && _beans.hasContext;

    final reg = _beans
        .getFactory(
          qualifier: effectiveQualifierName,
          contextQualifier: effectiveContext,
          fallback: fallbackToRoot,
        )
        ?.factory;

    if (reg case final DDIBaseFactory<BeanT> factory?) {
      final clazz = factory.getAsyncWith<ParameterT>(
        parameter: parameter,
        qualifier: effectiveQualifierName,
        ddiInstance: this,
      );

      return clazz is Future<Future> ? await clazz : clazz;
    } else if (reg case final DDIBaseFactory<Future<BeanT>> factory?) {
      // This prevents to return a Future<Future<BeanT>>
      // This was find with the Object Scope
      return await factory.getAsyncWith<ParameterT>(
        parameter: parameter,
        qualifier: effectiveQualifierName,
        ddiInstance: this,
      );
    } else if (select != null && BeanT != Object) {
      // Try to find a bean with the selector
      for (final MapEntry(key: _, :value) in _beans.entries(context: context)) {
        if (value.type == BeanT &&
            value.selector != null &&
            await (value.selector?.call(select) ?? false)) {
          return (value as DDIBaseFactory<BeanT>).getAsyncWith<ParameterT>(
            parameter: parameter,
            qualifier: effectiveQualifierName,
            ddiInstance: this,
          );
        }
      }
    }

    throw BeanNotFoundException(effectiveQualifierName.toString());
  }

  @override
  List<Object> getByType<BeanT extends Object>() {
    final Type type = BeanT;

    return _beans
        .entries()
        .where((element) => element.value.type == type)
        .map((e) => e.key)
        .toList();
  }

  @override
  FutureOr<void> destroy<BeanT extends Object>(
      {Object? qualifier, Object? context}) {
    final Object effectiveQualifierName = qualifier ?? BeanT;

    return _destroy<BeanT>(effectiveQualifierName, context);
  }

  FutureOr<void> _destroy<BeanT extends Object>(
    Object effectiveQualifierName,
    Object? context,
  ) async {
    final Object effectiveContext = context ?? currentContext;
    final bool fallbackToRoot = context == null && _beans.hasContext;

    final located = _beans.getFactory(
      qualifier: effectiveQualifierName,
      contextQualifier: effectiveContext,
      fallback: fallbackToRoot,
    );

    if (located != null) {
      return located.factory.destroy(
        apply: () => _beans.removeFactory(
          effectiveQualifierName,
          context: located.context,
        ),
        ddiInstance: this,
      );
    }
    return null;
  }

  @override
  void destroyByType<BeanT extends Object>([Object? context]) {
    final keys = getByType<BeanT>();

    for (final key in keys) {
      _destroy(key, context);
    }
  }

  @override
  Future<void> dispose<BeanT extends Object>(
      {Object? qualifier, Object? context}) {
    final Object effectiveQualifierName = qualifier ?? BeanT;
    final Object effectiveContext = context ?? currentContext;
    final bool fallbackToRoot = context == null && _beans.hasContext;

    final located = _beans.getFactory<BeanT>(
      qualifier: effectiveQualifierName,
      contextQualifier: effectiveContext,
      fallback: fallbackToRoot,
    );

    if (located != null) {
      return located.factory.dispose(ddiInstance: this);
    }

    throw BeanNotFoundException(effectiveQualifierName.toString());
  }

  @override
  void disposeByType<BeanT extends Object>() {
    for (final MapEntry(key: _, :value) in _beans.entries()) {
      value.dispose(ddiInstance: this);
    }
  }

  @override
  FutureOr<void> addDecorator<BeanT extends Object>(
    List<BeanT Function(BeanT)> decorators, {
    Object? qualifier,
  }) {
    final Object effectiveQualifierName = qualifier ?? BeanT;

    final factory =
        _beans.getFactory<BeanT>(qualifier: effectiveQualifierName)?.factory;

    if (factory case final DDIScopeFactory<BeanT> f?) {
      return f.addDecorator(decorators);
    }
    assert(
      factory == null,
      'The instance is registered but the Scope doesn\'t support decorators.',
    );

    throw BeanNotFoundException(effectiveQualifierName.toString());
  }

  @override
  void addInterceptor<BeanT extends Object>(
    Set<Object>? interceptors, {
    Object? qualifier,
  }) {
    final Object effectiveQualifierName = qualifier ?? BeanT;

    final factory =
        _beans.getFactory<BeanT>(qualifier: effectiveQualifierName)?.factory;

    if (factory case final DDIScopeFactory<BeanT> f?) {
      f.addInterceptor(interceptors ?? {});
    } else {
      assert(
        factory == null,
        'The instance is registered but the Scope doesn\'t support interceptors.',
      );
      throw BeanNotFoundException(effectiveQualifierName.toString());
    }
  }

  @override
  void addChildModules<BeanT extends Object>({
    required Object child,
    Object? qualifier,
  }) {
    addChildrenModules<BeanT>(child: {child}, qualifier: qualifier);
  }

  @override
  void addChildrenModules<BeanT extends Object>({
    required Set<Object> child,
    Object? qualifier,
  }) {
    final Object effectiveQualifierName = qualifier ?? BeanT;

    final factory =
        _beans.getFactory<BeanT>(qualifier: effectiveQualifierName)?.factory;

    if (factory case final DDIScopeFactory<BeanT> f?) {
      f.addChildrenModules(child);
    } else {
      assert(
        factory == null,
        'The instance is registered but the Scope doesn\'t support children.',
      );
      throw BeanNotFoundException(effectiveQualifierName.toString());
    }
  }

  @override
  Set<Object> getChildren<BeanT extends Object>({Object? qualifier}) {
    final factory =
        _beans.getFactory<BeanT>(qualifier: qualifier ?? BeanT)?.factory;
    if (factory case final DDIScopeFactory<BeanT> f?) {
      return f.children;
    }
    assert(
      factory == null,
      'The instance is registered but the Scope doesn\'t support children.',
    );
    return {};
  }

  @override
  @pragma('vm:prefer-inline')
  bool get isEmpty => _beans.isEmpty;

  @override
  @pragma('vm:prefer-inline')
  int get length => _beans.length;
}
