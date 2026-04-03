part of 'dart_ddi.dart';

class _DDIImpl implements DDI {
  _DDIImpl({required bool enableZoneRegistry})
      : _enableZoneRegistry = enableZoneRegistry;

  final bool _enableZoneRegistry;

  late final DartDDIQualifier _beans = _enableZoneRegistry
      ? DartDDIZoneQualifierImpl()
      : DartDDIDefaultQualifierImpl();

  @override
  @pragma('vm:prefer-inline')
  Object get currentContext => _beans.currentContext;

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

      if (!_enableZoneRegistry && context != null) {
        _beans.createContext(context);
      }

      final fac = _beans.getFactory(
        qualifier: effectiveQualifierName,
        fallback: false,
        contextQualifier: context,
      );

      if (fac != null) {
        if (BeanStateEnum.none == fac.state) {
          _beans.remove(
            effectiveQualifierName,
            context: context,
          );
        } else {
          throw DuplicatedBeanException(effectiveQualifierName.toString());
        }
      }

      // Force the type to be correct. Fixes the behavior with FutureOr and interfaces
      if (factory.type != BeanT) {
        factory.setType<BeanT>();
      }

      _beans.setFactory(effectiveQualifierName, factory);

      final f = factory.register(
        qualifier: effectiveQualifierName,
        ddiInstance: this,
      );

      f.onError((e, _) {
        _beans.remove(
          effectiveQualifierName,
          context: context,
        );
      });

      return f;
    }
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
            ?.isRegistered ??
        false;
  }

  @override
  bool isFuture<BeanT extends Object>({Object? qualifier, Object? context}) {
    final Object effectiveQualifierName = qualifier ?? BeanT;
    final Object effectiveContext = context ?? currentContext;
    if (_beans.getFactory(
      qualifier: effectiveQualifierName,
      contextQualifier: effectiveContext,
    )
        case final DDIBaseFactory<BeanT> factory?) {
      return factory.isFuture;
    }

    throw BeanNotFoundException(effectiveQualifierName.toString());
  }

  @override
  bool isReady<BeanT extends Object>({Object? qualifier, Object? context}) {
    final Object effectiveQualifierName = qualifier ?? BeanT;
    final Object effectiveContext = context ?? currentContext;
    if (_beans.getFactory(
      qualifier: effectiveQualifierName,
      contextQualifier: effectiveContext,
    )
        case final DDIBaseFactory<BeanT> factory?) {
      return factory.isReady;
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

    if (_beans.getFactory(
      qualifier: effectiveQualifierName,
      contextQualifier: effectiveContext,
    )
        case final DDIBaseFactory<BeanT> factory?) {
      return factory.getWith<ParameterT>(
        parameter: parameter,
        qualifier: effectiveQualifierName,
        ddiInstance: this,
      );
    } else if (select != null && BeanT != Object) {
      // Try to find a bean with the selector
      for (final MapEntry(key: _, :value) in _beans.entries) {
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

    final reg = _beans.getFactory(
      qualifier: effectiveQualifierName,
      contextQualifier: effectiveContext,
    );

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
      for (final MapEntry(key: _, :value) in _beans.entries) {
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

    return _beans.entries
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

    if (_beans.getFactory(
      qualifier: effectiveQualifierName,
      contextQualifier: effectiveContext,
      fallback: fallbackToRoot,
    )
        case final factory?) {
      return factory.destroy(
        apply: () => _beans.remove(
          effectiveQualifierName,
          context: effectiveContext,
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

    if (_beans.getFactory(
      qualifier: effectiveQualifierName,
      contextQualifier: effectiveContext,
      fallback: fallbackToRoot,
    )
        case final DDIBaseFactory<BeanT> factory?) {
      return factory.dispose(ddiInstance: this);
    }

    throw BeanNotFoundException(effectiveQualifierName.toString());
  }

  @override
  void disposeByType<BeanT extends Object>() {
    for (final MapEntry(key: _, :value) in _beans.entries) {
      value.dispose(ddiInstance: this);
    }
  }

  @override
  FutureOr<void> addDecorator<BeanT extends Object>(
    List<BeanT Function(BeanT)> decorators, {
    Object? qualifier,
  }) {
    final Object effectiveQualifierName = qualifier ?? BeanT;

    final factory = _beans.getFactory<BeanT>(qualifier: effectiveQualifierName);

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

    final factory = _beans.getFactory(qualifier: effectiveQualifierName);

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

    final factory = _beans.getFactory(qualifier: effectiveQualifierName);

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
    final factory = _beans.getFactory(qualifier: qualifier ?? BeanT);
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
