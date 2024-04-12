part of 'dart_ddi.dart';

bool _debug = !const bool.fromEnvironment('dart.vm.product') &&
    !const bool.fromEnvironment('dart.vm.profile');

class _DDIImpl implements DDI {
  final Map<Object, FactoryClazz> _beans = {};
  static const _resolutionKey = #_resolutionKey;

  final Map<Object, List<Object>> _resolutionMap =
      Zone.current[_resolutionKey] as Map<Object, List<Object>>? ?? {};

  @override
  Future<void> registerSingleton<BeanT extends Object>(
    FutureOr<BeanT> Function() clazzRegister, {
    Object? qualifier,
    void Function()? postConstruct,
    List<BeanT Function(BeanT)>? decorators,
    List<DDIInterceptor<BeanT> Function()>? interceptors,
    FutureOr<bool> Function()? registerIf,
    bool destroyable = true,
    List<Object>? children,
  }) async {
    bool shouldRegister = true;

    if (registerIf != null) {
      if (registerIf is bool Function()) {
        shouldRegister = registerIf();
      } else {
        shouldRegister = await registerIf();
      }
    }

    if (shouldRegister) {
      final Object effectiveQualifierName = qualifier ?? BeanT;

      if (_beans[effectiveQualifierName] != null) {
        _validateDuplicated(effectiveQualifierName);

        return;
      }

      late BeanT clazz;

      if (clazzRegister is BeanT Function()) {
        clazz = clazzRegister.call();
      } else {
        clazz = await clazzRegister.call();
      }

      if (interceptors != null) {
        for (final interceptor in interceptors) {
          clazz = interceptor().aroundConstruct(clazz);
        }
      }

      clazz = _executarDecorators<BeanT>(clazz, decorators);

      postConstruct?.call();

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
        return _runFutureOrPostConstruct(clazz);
      }
    }
  }

  @override
  Future<void> registerApplication<BeanT extends Object>(
    FutureOr<BeanT> Function() clazzRegister, {
    Object? qualifier,
    void Function()? postConstruct,
    List<BeanT Function(BeanT)>? decorators,
    List<DDIInterceptor<BeanT> Function()>? interceptors,
    FutureOr<bool> Function()? registerIf,
    bool destroyable = true,
    List<Object>? children,
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
    FutureOr<BeanT> Function() clazzRegister, {
    Object? qualifier,
    void Function()? postConstruct,
    List<BeanT Function(BeanT)>? decorators,
    List<DDIInterceptor<BeanT> Function()>? interceptors,
    FutureOr<bool> Function()? registerIf,
    bool destroyable = true,
    List<Object>? children,
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
    FutureOr<BeanT> Function() clazzRegister, {
    Object? qualifier,
    void Function()? postConstruct,
    List<BeanT Function(BeanT)>? decorators,
    List<DDIInterceptor<BeanT> Function()>? interceptors,
    FutureOr<bool> Function()? registerIf,
    bool destroyable = true,
    List<Object>? children,
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
    required FutureOr<BeanT> Function() clazzRegister,
    required Scopes scopeType,
    required bool destroyable,
    Object? qualifier,
    void Function()? postConstruct,
    List<BeanT Function(BeanT)>? decorators,
    List<DDIInterceptor<BeanT> Function()>? interceptors,
    FutureOr<bool> Function()? registerIf,
    List<Object>? children,
  }) async {
    bool shouldRegister = true;

    if (registerIf != null) {
      if (registerIf is bool Function()) {
        shouldRegister = registerIf();
      } else {
        shouldRegister = await registerIf();
      }
    }

    if (shouldRegister) {
      final Object effectiveQualifierName = qualifier ?? BeanT;

      if (_beans[effectiveQualifierName] != null) {
        _validateDuplicated(effectiveQualifierName);
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

  void _validateDuplicated(Object effectiveQualifierName) {
    if (!_debug) {
      throw DuplicatedBeanException(effectiveQualifierName.toString());
    } else {
      // ignore: avoid_print
      print(
          'Is already registered a instance with Type ${effectiveQualifierName.toString()}');
    }
  }

  @override
  Future<void> registerObject<BeanT extends Object>(
    BeanT register, {
    Object? qualifier,
    void Function()? postConstruct,
    List<BeanT Function(BeanT)>? decorators,
    List<DDIInterceptor<BeanT> Function()>? interceptors,
    FutureOr<bool> Function()? registerIf,
    bool destroyable = true,
    List<Object>? children,
  }) async {
    bool shouldRegister = true;

    if (registerIf != null) {
      if (registerIf is bool Function()) {
        shouldRegister = registerIf();
      } else {
        shouldRegister = await registerIf();
      }
    }

    if (shouldRegister) {
      final Object effectiveQualifierName = qualifier ?? BeanT;

      if (_beans[effectiveQualifierName] != null) {
        _validateDuplicated(effectiveQualifierName);
        return;
      }

      if (interceptors != null) {
        for (final interceptor in interceptors) {
          register = interceptor.call().aroundConstruct(register);
        }
      }

      register = _executarDecorators<BeanT>(register, decorators);

      postConstruct?.call();

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
        return _runFutureOrPostConstruct(register);
      }
    }
  }

  @override
  bool isRegistered<BeanT extends Object>({Object? qualifier}) {
    return _beans.containsKey(qualifier ?? BeanT);
  }

  @override
  BeanT call<BeanT extends Object>() {
    return get<BeanT>();
  }

  BeanT _getSingleton<BeanT extends Object>(
      FactoryClazz<BeanT> factoryClazz, Object effectiveQualifierName) {
    if (factoryClazz.clazzInstance case var clazz?) {
      if (factoryClazz.interceptors case final inter? when inter.isNotEmpty) {
        for (final interceptor in inter) {
          clazz = interceptor().aroundGet(clazz);
        }
      }

      return clazz;
    }

    throw BeanDestroyedException(effectiveQualifierName.toString());
  }

  BeanT _getAplication<BeanT extends Object>(
      FactoryClazz<BeanT> factoryClazz, Object effectiveQualifierName) {
    late BeanT applicationClazz;

    if (factoryClazz.clazzInstance == null) {
      applicationClazz = _applyApplication<BeanT>(
          factoryClazz, (factoryClazz.clazzRegister as BeanT Function())());

      if (applicationClazz is PostConstruct) {
        applicationClazz.onPostConstruct();
      } else if (applicationClazz is Future<PostConstruct>) {
        _runFutureOrPostConstruct(applicationClazz);
      }
    } else {
      applicationClazz = factoryClazz.clazzInstance!;
    }

    if (factoryClazz.interceptors case final inter? when inter.isNotEmpty) {
      for (final interceptor in inter) {
        applicationClazz = interceptor().aroundGet(applicationClazz);
      }
    }

    return applicationClazz;
  }

  Future<BeanT> _getAplicationAsync<BeanT extends Object>(
      FactoryClazz<BeanT> factoryClazz, Object effectiveQualifierName) async {
    late BeanT applicationClazz;

    if (factoryClazz.clazzInstance == null) {
      applicationClazz = _applyApplication<BeanT>(
          factoryClazz, await factoryClazz.clazzRegister!.call());

      if (applicationClazz is PostConstruct) {
        await applicationClazz.onPostConstruct();
      } else if (applicationClazz is Future<PostConstruct>) {
        await _runFutureOrPostConstruct(applicationClazz);
      }
    } else {
      applicationClazz = factoryClazz.clazzInstance!;
    }

    if (factoryClazz.interceptors case final inter? when inter.isNotEmpty) {
      for (final interceptor in inter) {
        applicationClazz = interceptor().aroundGet(applicationClazz);
      }
    }

    return applicationClazz;
  }

  BeanT _applyApplication<BeanT extends Object>(
    FactoryClazz<BeanT> factoryClazz,
    BeanT applicationClazz,
  ) {
    if (factoryClazz.interceptors case final inter? when inter.isNotEmpty) {
      for (final interceptor in inter) {
        applicationClazz = interceptor().aroundConstruct(applicationClazz);
      }
    }

    applicationClazz =
        _executarDecorators<BeanT>(applicationClazz, factoryClazz.decorators);

    factoryClazz.postConstruct?.call();

    factoryClazz.clazzInstance = applicationClazz;

    return applicationClazz;
  }

  BeanT _getDependent<BeanT extends Object>(FactoryClazz<BeanT> factoryClazz) {
    BeanT dependentClazz = _applyDependent<BeanT>(
        factoryClazz, (factoryClazz.clazzRegister as BeanT Function())());

    if (factoryClazz.interceptors case final inter? when inter.isNotEmpty) {
      for (final interceptor in inter) {
        dependentClazz = interceptor().aroundGet(dependentClazz);
      }
    }

    if (dependentClazz is PostConstruct) {
      dependentClazz.onPostConstruct();
    } else if (dependentClazz is Future<PostConstruct>) {
      _runFutureOrPostConstruct(dependentClazz);
    }

    return dependentClazz;
  }

  Future<BeanT> _getDependentAsync<BeanT extends Object>(
      FactoryClazz<BeanT> factoryClazz) async {
    BeanT dependentClazz = _applyDependent<BeanT>(
        factoryClazz, await factoryClazz.clazzRegister!.call());

    if (dependentClazz is PostConstruct) {
      await dependentClazz.onPostConstruct();
    } else if (dependentClazz is Future<PostConstruct>) {
      await _runFutureOrPostConstruct(dependentClazz);
    }

    if (factoryClazz.interceptors case final inter? when inter.isNotEmpty) {
      for (final interceptor in inter) {
        dependentClazz = interceptor().aroundGet(dependentClazz);
      }
    }

    return dependentClazz;
  }

  BeanT _applyDependent<BeanT extends Object>(
    FactoryClazz<BeanT> factoryClazz,
    BeanT dependentClazz,
  ) {
    if (factoryClazz.interceptors case final inter? when inter.isNotEmpty) {
      for (final interceptor in inter) {
        dependentClazz = interceptor().aroundConstruct(dependentClazz);
      }
    }

    dependentClazz =
        _executarDecorators<BeanT>(dependentClazz, factoryClazz.decorators);

    factoryClazz.postConstruct?.call();

    return dependentClazz;
  }

  @override
  BeanT get<BeanT extends Object>({Object? qualifier}) {
    final Object effectiveQualifierName = qualifier ?? BeanT;

    if (_beans[effectiveQualifierName]
        case final FactoryClazz<BeanT> factoryClazz?) {
      if (factoryClazz.clazzRegister is FutureOr<BeanT> Function() &&
          BeanT is Future) {
        throw const FutureNotAcceptException();
      }

      return runZoned(
        () {
          return _getScoped<BeanT>(factoryClazz, effectiveQualifierName);
        },
        zoneValues: {_resolutionKey: <Object, List<Object>>{}},
      );
    }

    throw BeanNotFoundException(effectiveQualifierName.toString());
  }

  @override
  Future<BeanT> getAsync<BeanT extends Object>({Object? qualifier}) {
    final Object effectiveQualifierName = qualifier ?? BeanT;

    if (_beans[effectiveQualifierName]
        case final FactoryClazz<BeanT> factory?) {
      return runZoned(
        () {
          return _getScopedAsync<BeanT>(factory, effectiveQualifierName);
        },
        zoneValues: {_resolutionKey: <Object, List<Object>>{}},
      );
    }

    throw BeanNotFoundException(effectiveQualifierName.toString());
  }

  BeanT _getScoped<BeanT extends Object>(
      FactoryClazz<BeanT> factoryClazz, Object effectiveQualifierName) {
    if (_resolutionMap[effectiveQualifierName]?.isNotEmpty ?? false) {
      throw CircularDetectionException(effectiveQualifierName.toString());
    }

    _resolutionMap[effectiveQualifierName] = [
      ..._resolutionMap[effectiveQualifierName] ?? [],
      effectiveQualifierName
    ];

    try {
      return switch (factoryClazz.scopeType) {
        Scopes.singleton ||
        Scopes.object =>
          _getSingleton<BeanT>(factoryClazz, effectiveQualifierName),
        Scopes.dependent => _getDependent<BeanT>(factoryClazz),
        Scopes.application ||
        Scopes.session =>
          _getAplication<BeanT>(factoryClazz, effectiveQualifierName)
      };
    } finally {
      _resolutionMap[effectiveQualifierName]?.removeLast();
    }
  }

  Future<BeanT> _getScopedAsync<BeanT extends Object>(
      FactoryClazz<BeanT> factoryClazz, Object effectiveQualifierName) {
    if (_resolutionMap[effectiveQualifierName]?.isNotEmpty ?? false) {
      throw CircularDetectionException(effectiveQualifierName.toString());
    }

    _resolutionMap[effectiveQualifierName] = [
      ..._resolutionMap[effectiveQualifierName] ?? [],
      effectiveQualifierName
    ];

    try {
      return switch (factoryClazz.scopeType) {
        Scopes.singleton || Scopes.object => Future.value(
            _getSingleton<BeanT>(factoryClazz, effectiveQualifierName)),
        Scopes.dependent => _getDependentAsync<BeanT>(factoryClazz),
        Scopes.application ||
        Scopes.session =>
          _getAplicationAsync<BeanT>(factoryClazz, effectiveQualifierName)
      };
    } finally {
      _resolutionMap[effectiveQualifierName]?.removeLast();
    }
  }

  @override
  List<Object> getByType<BeanT extends Object>() {
    final Type type = BeanT;

    return _beans.entries
        .where((element) => element.value.type == type)
        .map((e) => e.key)
        .toList();
  }

  BeanT _executarDecorators<BeanT extends Object>(
    BeanT clazz,
    List<BeanT Function(BeanT)>? decorators,
  ) {
    if (decorators != null) {
      for (final decorator in decorators) {
        clazz = decorator(clazz);
      }
    }

    return clazz;
  }

  @override
  Future<void> destroy<BeanT extends Object>({Object? qualifier}) {
    final Object effectiveQualifierName = qualifier ?? BeanT;

    return _destroy<BeanT>(effectiveQualifierName);
  }

  void _destroyChildren(FactoryClazz factoryClazz) {
    if (factoryClazz.children case final List<Object> children?
        when children.isNotEmpty) {
      for (final Object child in children) {
        _destroy(child);
      }
    }
  }

  Future<void> _destroy<BeanT>(Object effectiveQualifierName) {
    if (_beans[effectiveQualifierName] case final factoryClazz?
        when factoryClazz.destroyable) {
      //Only destroy if destroyable was registered with true
      if (factoryClazz.clazzInstance case final clazz?) {
        if (factoryClazz.interceptors case final inter? when inter.isNotEmpty) {
          for (final interceptor in inter) {
            interceptor().aroundDestroy(clazz);
          }
        }

        if (clazz is PreDestroy) {
          return _runFutureOrPreDestroy(
              factoryClazz, clazz, effectiveQualifierName);
        }
      }

      _destroyChildren(factoryClazz);
      _beans.remove(effectiveQualifierName);
    }

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
          return _disposeBean<BeanT>(factoryClazz, effectiveQualifierName);
        default:
          break;
      }
    }

    return Future.value();
  }

  /// Dispose only clean the class Instance
  Future<void> _disposeBean<BeanT>(
    FactoryClazz<BeanT> factoryClazz,
    Object effectiveQualifierName,
  ) {
    if (factoryClazz.clazzInstance case final clazz?) {
      if (factoryClazz.interceptors case final inter? when inter.isNotEmpty) {
        //Call aroundDispose before reset the clazzInstance
        for (final interceptor in inter) {
          interceptor().aroundDispose(clazz);
        }
      }

      if (clazz is PreDispose) {
        return _runFutureOrPreDispose(
            factoryClazz, clazz, effectiveQualifierName);
      }
    }

    _disposeChildren(factoryClazz);
    return Future.value();
  }

  @override
  void disposeAllSession() {
    for (final MapEntry(:key, :value) in _beans.entries) {
      if (value.scopeType == Scopes.session) {
        _disposeBean(value, key);
      }
    }
  }

  @override
  void disposeByType<BeanT extends Object>() {
    final Type type = BeanT;

    final clazz =
        _beans.entries.where((element) => element.value.type == type).toList();

    for (final MapEntry(:key, :value) in clazz) {
      _disposeBean(value, key);
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
        factoryClazz.clazzInstance =
            _executarDecorators<BeanT>(factoryClazz.clazzInstance!, decorators);
        break;
      //Application and Session Scopes may  have a instance created
      case Scopes.application:
      case Scopes.session:
        if (factoryClazz.clazzInstance case final clazz?) {
          factoryClazz.clazzInstance =
              _executarDecorators<BeanT>(clazz, decorators);
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

    factoryClazz.clazzInstance =
        _executarDecorators<BeanT>(register, factoryClazz.decorators);
  }

  Future<void> _runFutureOrPostConstruct(Future<PostConstruct> register) async {
    final PostConstruct clazz = await register;

    return clazz.onPostConstruct();
  }

  Future<void> _runFutureOrPreDestroy(FactoryClazz factoryClazz,
      PreDestroy clazz, Object effectiveQualifierName) async {
    await clazz.onPreDestroy();

    _destroyChildren(factoryClazz);

    _beans.remove(effectiveQualifierName);

    return Future.value();
  }

  Future<void> _runFutureOrPreDispose(FactoryClazz factoryClazz,
      PreDispose clazz, Object effectiveQualifierName) async {
    await clazz.onPreDispose();

    _disposeChildren(factoryClazz);
  }

  void _disposeChildren(FactoryClazz factoryClazz) {
    if (factoryClazz.children case final List<Object> children?
        when children.isNotEmpty) {
      for (final Object child in children) {
        dispose(qualifier: child);
      }
    }

    factoryClazz.clazzInstance = null;
  }

  @override
  void addChildModules<BeanT extends Object>(
      {required Object child, Object? qualifier}) {
    addChildrenModules<BeanT>(child: [child], qualifier: qualifier);
  }

  @override
  void addChildrenModules<BeanT extends Object>(
      {required List<Object> child, Object? qualifier}) {
    final Object effectiveQualifierName = qualifier ?? BeanT;

    if (_beans[effectiveQualifierName]
        case final FactoryClazz<BeanT> factoryClazz?) {
      factoryClazz.children = [...factoryClazz.children ?? [], ...child];
    } else {
      throw BeanNotFoundException(effectiveQualifierName.toString());
    }
  }

  @override
  void setDebugMode(bool debug) {
    _debug = debug;
  }
}
