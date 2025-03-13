part of 'dart_ddi.dart';

class _DDIImpl implements DDI {
  final Map<Object, DDIBaseFactory<Object>> _beans = {};

  @override
  Future<void> register<BeanT extends Object>({
    required DDIBaseFactory<BeanT> factory,
    Object? qualifier,
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

      if (_beans[effectiveQualifierName] != null) {
        if (BeanStateEnum.none == (_beans[effectiveQualifierName]?.state ?? BeanStateEnum.none)) {
          _beans.remove(effectiveQualifierName);
        } else {
          throw DuplicatedBeanException(effectiveQualifierName.toString());
        }
      }

      // Force the type to be correct. Fixes the behavior with FutureOr and interfaces
      if (factory.type != BeanT) {
        factory.setType<BeanT>();
      }

      factory.state = BeanStateEnum.beingRegistered;
      _beans[effectiveQualifierName] = factory;

      final f = factory.register(
        qualifier: effectiveQualifierName,
        apply: (instance) {
          instance.state = BeanStateEnum.registered;
          _beans[effectiveQualifierName] = instance;
        },
      );

      f.onError((e, _) {
        _beans.remove(effectiveQualifierName);
      });

      return f;
    }
  }

  @override
  bool isRegistered<BeanT extends Object>({Object? qualifier}) {
    final Object effectiveQualifierName = qualifier ?? BeanT;

    return BeanStateEnum.none != (_beans[effectiveQualifierName]?.state ?? BeanStateEnum.none);
  }

  @override
  bool isFuture<BeanT extends Object>({Object? qualifier}) {
    final Object effectiveQualifierName = qualifier ?? BeanT;
    if (_beans[effectiveQualifierName] case final DDIBaseFactory<BeanT> factory?) {
      return factory.isFuture;
    }

    throw BeanNotFoundException(effectiveQualifierName.toString());
  }

  @override
  bool isReady<BeanT extends Object>({Object? qualifier}) {
    final Object effectiveQualifierName = qualifier ?? BeanT;
    if (_beans[effectiveQualifierName] case final DDIBaseFactory<BeanT> factory?) {
      return factory.isReady && factory.state == BeanStateEnum.created;
    }

    throw BeanNotFoundException(effectiveQualifierName.toString());
  }

  @override
  BeanT getWith<BeanT extends Object, ParameterT extends Object>({
    ParameterT? parameter,
    Object? qualifier,
    Object? select,
  }) {
    final Object effectiveQualifierName = qualifier ?? BeanT;

    if (_beans[effectiveQualifierName] case final DDIBaseFactory<BeanT> factory?) {
      return InstanceRunnerUtils.run<BeanT, ParameterT>(
        factory: factory,
        effectiveQualifierName: effectiveQualifierName,
        parameter: parameter,
      );
    } else if (select != null && BeanT != Object) {
      // Try to find a bean with the selector
      for (final MapEntry(key: _, :value) in _beans.entries) {
        if (value.type == BeanT && (value.selector?.call(select) ?? false) as bool) {
          return InstanceRunnerUtils.run<BeanT, ParameterT>(
            factory: value as DDIBaseFactory<BeanT>,
            effectiveQualifierName: effectiveQualifierName,
            parameter: parameter,
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
  }) async {
    final Object effectiveQualifierName = qualifier ?? BeanT;

    final reg = _beans[effectiveQualifierName];

    if (reg case final DDIBaseFactory<BeanT> factory?) {
      final clazz = InstanceRunnerUtils.runAsync<BeanT, ParameterT>(
        factory: factory,
        effectiveQualifierName: effectiveQualifierName,
        parameter: parameter,
      );

      return clazz is Future<Future> ? await clazz : clazz;
    } else if (reg case final DDIBaseFactory<Future<BeanT>> factory?) {
      // This prevents to return a Future<Future<BeanT>>
      // This was find with the Object Scope
      return await InstanceRunnerUtils.runAsync<Future<BeanT>, ParameterT>(
        factory: factory,
        effectiveQualifierName: effectiveQualifierName,
        parameter: parameter,
      );
    } else if (select != null && BeanT != Object) {
      // Try to find a bean with the selector
      for (final MapEntry(key: _, :value) in _beans.entries) {
        if (value.type == BeanT && value.selector != null && await (value.selector?.call(select) ?? false)) {
          return InstanceRunnerUtils.runAsync<BeanT, ParameterT>(
            factory: value as DDIBaseFactory<BeanT>,
            effectiveQualifierName: effectiveQualifierName,
            parameter: parameter,
          );
        }
      }
    }

    throw BeanNotFoundException(effectiveQualifierName.toString());
  }

  @override
  List<Object> getByType<BeanT extends Object>() {
    final Type type = BeanT;

    return _beans.entries.where((element) => element.value.type == type).map((e) => e.key).toList();
  }

  @override
  FutureOr<void> destroy<BeanT extends Object>({Object? qualifier}) {
    final Object effectiveQualifierName = qualifier ?? BeanT;

    return _destroy<BeanT>(effectiveQualifierName);
  }

  FutureOr<void> _destroy<BeanT extends Object>(Object effectiveQualifierName) async {
    if (_beans[effectiveQualifierName] case final factory?) {
      return factory.destroy(() => _beans.remove(effectiveQualifierName));
    }
    return null;
  }

  @override
  void destroyByType<BeanT extends Object>() {
    final keys = getByType<BeanT>();

    for (final key in keys) {
      _destroy(key);
    }
  }

  @override
  Future<void> dispose<BeanT extends Object>({Object? qualifier}) {
    final Object effectiveQualifierName = qualifier ?? BeanT;

    if (_beans[effectiveQualifierName] case final DDIBaseFactory<BeanT> factory?) {
      return factory.dispose();
    }

    throw BeanNotFoundException(effectiveQualifierName.toString());
  }

  @override
  void disposeByType<BeanT extends Object>() {
    for (final MapEntry(key: _, :value) in _beans.entries) {
      value.dispose();
    }
  }

  @override
  FutureOr<void> addDecorator<BeanT extends Object>(
    List<BeanT Function(BeanT)> decorators, {
    Object? qualifier,
  }) {
    final Object effectiveQualifierName = qualifier ?? BeanT;

    final DDIBaseFactory<BeanT>? factory = _beans[effectiveQualifierName] as DDIBaseFactory<BeanT>?;

    if (factory == null) {
      throw BeanNotFoundException(effectiveQualifierName.toString());
    }

    return factory.addDecorator(decorators);
  }

  @override
  void addInterceptor<BeanT extends Object>(
    Set<Object>? interceptors, {
    Object? qualifier,
  }) {
    final Object effectiveQualifierName = qualifier ?? BeanT;

    if (_beans[effectiveQualifierName] case final DDIBaseFactory<BeanT> factory?) {
      factory.addInterceptor(interceptors ?? {});
    } else {
      throw BeanNotFoundException(effectiveQualifierName.toString());
    }
  }

  @override
  void addChildModules<BeanT extends Object>({required Object child, Object? qualifier}) {
    addChildrenModules<BeanT>(child: {child}, qualifier: qualifier);
  }

  @override
  void addChildrenModules<BeanT extends Object>({
    required Set<Object> child,
    Object? qualifier,
  }) {
    final Object effectiveQualifierName = qualifier ?? BeanT;

    if (_beans[effectiveQualifierName] case final DDIBaseFactory<BeanT> factory?) {
      factory.addChildrenModules(child);
    } else {
      throw BeanNotFoundException(effectiveQualifierName.toString());
    }
  }

  @override
  Set<Object> getChildren<BeanT extends Object>({Object? qualifier}) {
    return _beans[qualifier ?? BeanT]?.children ?? {};
  }
}
