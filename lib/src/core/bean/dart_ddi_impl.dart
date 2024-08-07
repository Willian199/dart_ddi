part of 'dart_ddi.dart';

bool _debug = !const bool.fromEnvironment('dart.vm.product') &&
    !const bool.fromEnvironment('dart.vm.profile');

class _DDIImpl implements DDI {
  final Map<Object, FactoryClazz<Object>> _beans = {};

  @override
  Future<void> registerSingleton<BeanT extends Object>(
    BeanRegister<BeanT> clazzRegister, {
    Object? qualifier,
    VoidCallback? postConstruct,
    ListDecorator<BeanT>? decorators,
    ListDDIInterceptor<BeanT>? interceptors,
    FutureOrBoolCallback? registerIf,
    bool destroyable = true,
    Set<Object>? children,
  }) async {
    bool shouldRegister = true;

    if (registerIf != null) {
      if (registerIf is BoolCallback) {
        shouldRegister = registerIf();
      } else {
        shouldRegister = await registerIf();
      }
    }

    if (shouldRegister) {
      final Object effectiveQualifierName = qualifier ?? BeanT;

      if (_beans[effectiveQualifierName] != null) {
        DartDDIUtils.validateDuplicated(effectiveQualifierName, _debug);

        return;
      }

      late BeanT clazz;

      if (clazzRegister is BeanT Function()) {
        clazz = clazzRegister();
      } else {
        clazz = await clazzRegister();
      }

      if (interceptors != null) {
        for (final interceptor in interceptors) {
          clazz = interceptor().aroundConstruct(clazz);
        }
      }

      clazz = DartDDIUtils.executarDecorators<BeanT>(clazz, decorators);

      postConstruct?.call();

      if (clazz is DDIModule) {
        clazz.moduleQualifier = effectiveQualifierName;
      }

      _beans[effectiveQualifierName] = FactoryClazz<BeanT>(
        clazzInstance: clazz,
        type: BeanT,
        scopeType: Scopes.singleton,
        interceptors: interceptors,
        destroyable: destroyable,
        children: children,
      );

      if (clazz is PostConstruct) {
        return clazz.onPostConstruct();
      } else if (clazz is Future<PostConstruct>) {
        return DartDDIUtils.runFutureOrPostConstruct(clazz);
      }
    }
  }

  @override
  Future<void> registerApplication<BeanT extends Object>(
    BeanRegister<BeanT> clazzRegister, {
    Object? qualifier,
    VoidCallback? postConstruct,
    ListDecorator<BeanT>? decorators,
    ListDDIInterceptor<BeanT>? interceptors,
    FutureOrBoolCallback? registerIf,
    bool destroyable = true,
    Set<Object>? children,
  }) {
    return _register<BeanT>(
      clazzRegister: clazzRegister,
      scopeType: Scopes.application,
      qualifier: qualifier,
      postConstruct: postConstruct,
      decorators: decorators,
      interceptors: interceptors,
      destroyable: destroyable,
      registerIf: registerIf,
    );
  }

  @override
  Future<void> registerSession<BeanT extends Object>(
    BeanRegister<BeanT> clazzRegister, {
    Object? qualifier,
    VoidCallback? postConstruct,
    ListDecorator<BeanT>? decorators,
    ListDDIInterceptor<BeanT>? interceptors,
    FutureOrBoolCallback? registerIf,
    bool destroyable = true,
    Set<Object>? children,
  }) {
    return _register<BeanT>(
      clazzRegister: clazzRegister,
      scopeType: Scopes.session,
      qualifier: qualifier,
      postConstruct: postConstruct,
      decorators: decorators,
      interceptors: interceptors,
      destroyable: destroyable,
      registerIf: registerIf,
      children: children,
    );
  }

  @override
  Future<void> registerDependent<BeanT extends Object>(
    BeanRegister<BeanT> clazzRegister, {
    Object? qualifier,
    VoidCallback? postConstruct,
    ListDecorator<BeanT>? decorators,
    ListDDIInterceptor<BeanT>? interceptors,
    FutureOrBoolCallback? registerIf,
    bool destroyable = true,
    Set<Object>? children,
  }) {
    return _register<BeanT>(
      clazzRegister: clazzRegister,
      scopeType: Scopes.dependent,
      qualifier: qualifier,
      postConstruct: postConstruct,
      decorators: decorators,
      interceptors: interceptors,
      destroyable: destroyable,
      registerIf: registerIf,
      children: children,
    );
  }

  Future<void> _register<BeanT extends Object>({
    required BeanRegister<BeanT> clazzRegister,
    required Scopes scopeType,
    required bool destroyable,
    Object? qualifier,
    VoidCallback? postConstruct,
    ListDecorator<BeanT>? decorators,
    ListDDIInterceptor<BeanT>? interceptors,
    FutureOrBoolCallback? registerIf,
    Set<Object>? children,
  }) async {
    bool shouldRegister = true;

    if (registerIf != null) {
      if (registerIf is BoolCallback) {
        shouldRegister = registerIf();
      } else {
        shouldRegister = await registerIf();
      }
    }

    if (shouldRegister) {
      final Object effectiveQualifierName = qualifier ?? BeanT;

      if (_beans[effectiveQualifierName] != null) {
        DartDDIUtils.validateDuplicated(effectiveQualifierName, _debug);
        return;
      }

      _beans[effectiveQualifierName] = FactoryClazz<BeanT>(
        clazzRegister: clazzRegister,
        type: BeanT,
        postConstruct: postConstruct,
        decorators: decorators,
        interceptors: interceptors,
        scopeType: scopeType,
        destroyable: destroyable,
        children: children,
      );
    }
  }

  @override
  Future<void> registerObject<BeanT extends Object>(
    BeanT register, {
    Object? qualifier,
    VoidCallback? postConstruct,
    ListDecorator<BeanT>? decorators,
    ListDDIInterceptor<BeanT>? interceptors,
    FutureOrBoolCallback? registerIf,
    bool destroyable = true,
    Set<Object>? children,
  }) async {
    bool shouldRegister = true;

    if (registerIf != null) {
      if (registerIf is BoolCallback) {
        shouldRegister = registerIf();
      } else {
        shouldRegister = await registerIf();
      }
    }

    if (shouldRegister) {
      final Object effectiveQualifierName = qualifier ?? BeanT;

      if (_beans[effectiveQualifierName] != null) {
        DartDDIUtils.validateDuplicated(effectiveQualifierName, _debug);
        return;
      }

      if (interceptors != null) {
        for (final interceptor in interceptors) {
          register = interceptor().aroundConstruct(register);
        }
      }

      register = DartDDIUtils.executarDecorators<BeanT>(register, decorators);

      postConstruct?.call();

      if (register is DDIModule) {
        register.moduleQualifier = effectiveQualifierName;
      }

      _beans[effectiveQualifierName] = FactoryClazz<BeanT>(
        clazzInstance: register,
        type: BeanT,
        scopeType: Scopes.object,
        interceptors: interceptors,
        destroyable: destroyable,
        children: children,
      );

      if (register is PostConstruct) {
        return register.onPostConstruct();
      } else if (register is Future<PostConstruct>) {
        return DartDDIUtils.runFutureOrPostConstruct(register);
      }
    }
  }

  @override
  Future<void> registerComponent<BeanT extends Object>({
    required BeanRegister<BeanT> clazzRegister,
    required Object moduleQualifier,
    Object? qualifier,
    VoidCallback? postConstruct,
    ListDecorator<BeanT>? decorators,
    ListDDIInterceptor<BeanT>? interceptors,
    FutureOrBoolCallback? registerIf,
    bool destroyable = true,
    Set<Object>? children,
  }) {
    final Object effectiveQualifierName =
        '$moduleQualifier${qualifier ?? BeanT}';

    if (_beans[moduleQualifier] case final FactoryClazz<DDIModule> _?) {
      addChildModules(
          child: effectiveQualifierName, qualifier: moduleQualifier);

      return registerApplication<BeanT>(
        clazzRegister,
        qualifier: effectiveQualifierName,
        postConstruct: postConstruct,
        decorators: decorators,
        interceptors: interceptors,
        destroyable: destroyable,
        registerIf: registerIf,
        children: children,
      );
    }

    throw ModuleNotFoundException(moduleQualifier.toString());
  }

  @override
  bool isRegistered<BeanT extends Object>({Object? qualifier}) {
    return _beans.containsKey(qualifier ?? BeanT);
  }

  @override
  BeanT call<BeanT extends Object>() {
    return get<BeanT>();
  }

  @override
  BeanT get<BeanT extends Object>({Object? qualifier}) {
    final Object effectiveQualifierName = qualifier ?? BeanT;

    if (_beans[effectiveQualifierName]
        case final FactoryClazz<BeanT> factoryClazz?) {
      if (factoryClazz.clazzRegister is BeanRegister<BeanT> &&
          BeanT is Future) {
        throw const FutureNotAcceptException();
      }

      return ScopeUtils.executar<BeanT>(factoryClazz, effectiveQualifierName);
    }

    throw BeanNotFoundException(effectiveQualifierName.toString());
  }

  @override
  BeanT getComponent<BeanT extends Object>({
    required Object module,
    Object? qualifier,
  }) {
    final Object effectiveQualifierName = '$module${qualifier ?? BeanT}';
    if (_beans[module] case final FactoryClazz<DDIModule> factoryModuleClazz?
        when factoryModuleClazz.children?.contains(effectiveQualifierName) ??
            false) {
      return get<BeanT>(qualifier: effectiveQualifierName);
    }

    throw ModuleNotFoundException(module.toString());
  }

  @override
  Future<BeanT> getAsync<BeanT extends Object>({Object? qualifier}) {
    final Object effectiveQualifierName = qualifier ?? BeanT;

    if (_beans[effectiveQualifierName]
        case final FactoryClazz<BeanT> factory?) {
      return ScopeUtils.executarAsync<BeanT>(factory, effectiveQualifierName);
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
  FutureOr<void> destroy<BeanT extends Object>({Object? qualifier}) {
    final Object effectiveQualifierName = qualifier ?? BeanT;

    return _destroy<BeanT>(effectiveQualifierName);
  }

  FutureOr<void> _destroyChildren<BeanT>(Set<Object>? children) {
    if (children?.isNotEmpty ?? false) {
      for (final Object child in children!) {
        _destroy(child);
      }
    }
  }

  Future<void> _destroyChildrenAsync<BeanT>(Set<Object>? children) async {
    if (children?.isNotEmpty ?? false) {
      for (final Object child in children!) {
        await _destroy(child);
      }
    }
  }

  FutureOr<void> _destroy<BeanT>(Object effectiveQualifierName) {
    if (_beans[effectiveQualifierName] case final factoryClazz?
        when factoryClazz.destroyable) {
      // Only destroy if destroyable was registered with true
      // Should call interceptors even if the instance is null
      if (factoryClazz.interceptors case final inter? when inter.isNotEmpty) {
        for (final interceptor in inter) {
          interceptor().aroundDestroy(factoryClazz.clazzInstance);
        }
      }

      if (factoryClazz.clazzInstance case final clazz?
          when clazz is PreDestroy) {
        return _runFutureOrPreDestroy(
            factoryClazz, clazz, effectiveQualifierName);
      }

      _destroyChildren(factoryClazz.children);
      _beans.remove(effectiveQualifierName);
    }
  }

  Future<void> _runFutureOrPreDestroy<BeanT>(FactoryClazz<BeanT> factoryClazz,
      PreDestroy clazz, Object effectiveQualifierName) async {
    await _destroyChildrenAsync(factoryClazz.children);

    await clazz.onPreDestroy();

    _beans.remove(effectiveQualifierName);

    return Future.value();
  }

  @override
  void destroyAllSession() {
    final keys = _beans.entries
        .where((element) =>
            element.value.scopeType == Scopes.session &&
            element.value.destroyable)
        .map((e) => e.key)
        .toList();

    for (final key in keys) {
      _destroy(key);
    }
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

    if (_beans[effectiveQualifierName]
        case final FactoryClazz<BeanT> factoryClazz?) {
      //Singleton e Object only can destroy
      //Dependent doesn't have instance
      switch (factoryClazz.scopeType) {
        case Scopes.application:
        case Scopes.session:
          return DisposeUtils.disposeBean<BeanT>(factoryClazz);
        default:
          return DisposeUtils.disposeChildrenAsync<BeanT>(factoryClazz);
      }
    }

    return Future.value();
  }

  @override
  void disposeAllSession() {
    for (final MapEntry(key: _, :value) in _beans.entries) {
      if (value.scopeType == Scopes.session) {
        DisposeUtils.disposeBean(value);
      }
    }
  }

  @override
  void disposeByType<BeanT extends Object>() {
    final Type type = BeanT;

    final clazz =
        _beans.entries.where((element) => element.value.type == type).toList();

    for (final MapEntry(key: _, :value) in clazz) {
      DisposeUtils.disposeBean(value);
    }
  }

  @override
  FutureOr<void> addDecorator<BeanT extends Object>(
    List<BeanT Function(BeanT)> decorators, {
    Object? qualifier,
  }) {
    final Object effectiveQualifierName = qualifier ?? BeanT;

    final FactoryClazz<BeanT>? factoryClazz =
        _beans[effectiveQualifierName] as FactoryClazz<BeanT>?;

    if (factoryClazz == null) {
      throw BeanNotFoundException(effectiveQualifierName.toString());
    }

    switch (factoryClazz.scopeType) {
      //Singleton Scopes already have a instance
      case Scopes.singleton:
      case Scopes.object:
        factoryClazz.clazzInstance = DartDDIUtils.executarDecorators<BeanT>(
            factoryClazz.clazzInstance!, decorators);
        break;
      //Application and Session Scopes may  have a instance created
      case Scopes.application:
      case Scopes.session:
        if (factoryClazz.clazzInstance case final clazz?) {
          factoryClazz.clazzInstance =
              DartDDIUtils.executarDecorators<BeanT>(clazz, decorators);
        }

      //Dependent Scopes always require a new instance
      case Scopes.dependent:
        factoryClazz.decorators = [
          ...factoryClazz.decorators ?? [],
          ...decorators
        ];

        break;
    }
  }

  @override
  void addInterceptor<BeanT extends Object>(
    List<DDIInterceptor<BeanT> Function()> interceptors, {
    Object? qualifier,
  }) {
    final Object effectiveQualifierName = qualifier ?? BeanT;

    if (_beans[effectiveQualifierName]
        case final FactoryClazz<BeanT> factoryClazz?) {
      factoryClazz.interceptors = [
        ...factoryClazz.interceptors ?? [],
        ...interceptors
      ];
    } else {
      throw BeanNotFoundException(effectiveQualifierName.toString());
    }
  }

  @override
  void refreshObject<BeanT extends Object>(
    BeanT register, {
    Object? qualifier,
  }) {
    final Object effectiveQualifierName = qualifier ?? BeanT;
    final FactoryClazz<BeanT>? factoryClazz =
        _beans[effectiveQualifierName] as FactoryClazz<BeanT>?;

    if (factoryClazz == null) {
      throw BeanNotFoundException(effectiveQualifierName.toString());
    }

    if (factoryClazz.interceptors != null) {
      for (final interceptor in factoryClazz.interceptors!) {
        register = interceptor().aroundConstruct(register);
      }
    }

    factoryClazz.clazzInstance = DartDDIUtils.executarDecorators<BeanT>(
        register, factoryClazz.decorators);
  }

  @override
  void addChildModules<BeanT extends Object>(
      {required Object child, Object? qualifier}) {
    addChildrenModules<BeanT>(child: {child}, qualifier: qualifier);
  }

  @override
  void addChildrenModules<BeanT extends Object>(
      {required Set<Object> child, Object? qualifier}) {
    final Object effectiveQualifierName = qualifier ?? BeanT;

    if (_beans[effectiveQualifierName]
        case final FactoryClazz<BeanT> factoryClazz?) {
      factoryClazz.children = {...factoryClazz.children ?? {}, ...child};
    } else {
      throw BeanNotFoundException(effectiveQualifierName.toString());
    }
  }

  @override
  Set<Object> getChildren<BeanT extends Object>({Object? qualifier}) {
    return _beans[qualifier ?? BeanT]?.children ?? {};
  }

  @override
  void setDebugMode(bool debug) {
    _debug = debug;
  }
}
