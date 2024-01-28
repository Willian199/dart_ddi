part of 'dart_ddi.dart';

const _debug = false;

class _DDIImpl implements DDI {
  final Map<Object, FactoryClazz> _beans = {};
  static const _resolutionKey = #_resolutionKey;

  final Map<Object, List<Object>> _resolutionMap =
      Zone.current[_resolutionKey] as Map<Object, List<Object>>? ?? {};

  @override
  FutureOr<void> registerSingleton<BeanT extends Object>(
    BeanT Function() clazzRegister, {
    Object? qualifier,
    void Function()? postConstruct,
    List<BeanT Function(BeanT)>? decorators,
    List<DDIInterceptor<BeanT> Function()>? interceptors,
    FutureOr<bool> Function()? registerIf,
    bool destroyable = true,
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

      BeanT clazz = clazzRegister.call();

      if (interceptors != null) {
        for (final interceptor in interceptors) {
          clazz = interceptor.call().aroundConstruct(clazz);
        }
      }

      clazz = _executarDecorators(clazz, decorators);

      postConstruct?.call();

      if (clazz is PostConstruct) {
        clazz.onPostConstruct();
      } else if (clazz is Future<PostConstruct>) {
        _runFutureOrPostConstruct(clazz);
      }

      _beans[effectiveQualifierName] = FactoryClazz<BeanT>(
        clazzInstance: clazz,
        type: BeanT,
        scopeType: Scopes.singleton,
        interceptors: interceptors,
        destroyable: destroyable,
      );
    }
  }

  @override
  FutureOr<void> registerApplication<BeanT extends Object>(
    BeanT Function() clazzRegister, {
    Object? qualifier,
    void Function()? postConstruct,
    List<BeanT Function(BeanT)>? decorators,
    List<DDIInterceptor<BeanT> Function()>? interceptors,
    FutureOr<bool> Function()? registerIf,
    bool destroyable = true,
  }) {
    _register<BeanT>(
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
  FutureOr<void> registerSession<BeanT extends Object>(
    BeanT Function() clazzRegister, {
    Object? qualifier,
    void Function()? postConstruct,
    List<BeanT Function(BeanT)>? decorators,
    List<DDIInterceptor<BeanT> Function()>? interceptors,
    FutureOr<bool> Function()? registerIf,
    bool destroyable = true,
  }) {
    _register<BeanT>(
      clazzRegister: clazzRegister,
      scopeType: Scopes.session,
      qualifier: qualifier,
      postConstruct: postConstruct,
      decorators: decorators,
      interceptors: interceptors,
      destroyable: destroyable,
      registerIf: registerIf,
    );
  }

  @override
  FutureOr<void> registerDependent<BeanT extends Object>(
    BeanT Function() clazzRegister, {
    Object? qualifier,
    void Function()? postConstruct,
    List<BeanT Function(BeanT)>? decorators,
    List<DDIInterceptor<BeanT> Function()>? interceptors,
    FutureOr<bool> Function()? registerIf,
    bool destroyable = true,
  }) {
    _register<BeanT>(
      clazzRegister: clazzRegister,
      scopeType: Scopes.dependent,
      qualifier: qualifier,
      postConstruct: postConstruct,
      decorators: decorators,
      interceptors: interceptors,
      destroyable: destroyable,
      registerIf: registerIf,
    );
  }

  FutureOr<void> _register<BeanT extends Object>({
    required BeanT Function() clazzRegister,
    required Scopes scopeType,
    required bool destroyable,
    Object? qualifier,
    void Function()? postConstruct,
    List<BeanT Function(BeanT)>? decorators,
    List<DDIInterceptor<BeanT> Function()>? interceptors,
    FutureOr<bool> Function()? registerIf,
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
      );
    }
  }

  void _validateDuplicated(Object effectiveQualifierName) {
    if (!_debug) {
      throw DuplicatedBean(effectiveQualifierName.toString());
    } else {
      // ignore: avoid_print
      print(
          'Is already registered a instance with Type ${effectiveQualifierName.toString()}');
    }
  }

  @override
  void registerObject<BeanT extends Object>(
    BeanT register, {
    Object? qualifier,
    void Function()? postConstruct,
    List<BeanT Function(BeanT)>? decorators,
    List<DDIInterceptor<BeanT> Function()>? interceptors,
    FutureOr<bool> Function()? registerIf,
    bool destroyable = true,
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

      register = _executarDecorators(register, decorators);

      postConstruct?.call();

      if (register is PostConstruct) {
        register.onPostConstruct();
      } else if (register is Future<PostConstruct>) {
        _runFutureOrPostConstruct(register);
      }

      _beans[effectiveQualifierName] = FactoryClazz<BeanT>(
        clazzInstance: register,
        type: BeanT,
        scopeType: Scopes.object,
        interceptors: interceptors,
        destroyable: destroyable,
      );
    }
  }

  @override
  FutureOr<void> registerAsync<BeanT extends Object>(
    FutureOr<BeanT> Function() clazzRegister, {
    FutureOr<Object>? qualifier,
    FutureOr<void> Function()? postConstruct,
    FutureOr<List<BeanT Function(BeanT)>>? decorators,
    FutureOr<List<DDIInterceptor<BeanT> Function()>>? interceptors,
    FutureOr<bool> Function()? registerIf,
    FutureOr<bool> destroyable = true,
    Scopes scope = Scopes.application,
  }) async {
    if (registerIf != null && await registerIf()) {
      late Object? effectiveQualifierName;

      if (qualifier != null) {
        effectiveQualifierName = await qualifier;
      }

      effectiveQualifierName ??= BeanT;

      if (_beans[effectiveQualifierName] != null) {
        final cause =
            'Is already registered a instance with Type ${effectiveQualifierName.toString()}';
        if (!_debug) {
          throw DuplicatedBean(cause);
        }
        // ignore: avoid_print
        print(cause);
        return;
      }

      BeanT clazz = await clazzRegister.call();

      List<DDIInterceptor<BeanT> Function()>? inter;

      if (interceptors != null) {
        inter = await interceptors;
        for (final interceptor in inter) {
          clazz = interceptor.call().aroundConstruct(clazz);
        }
      }

      List<BeanT Function(BeanT)> dec;
      if (decorators != null) {
        dec = await decorators;
        for (final decorator in dec) {
          clazz = decorator(clazz);
        }
      }

      postConstruct?.call();

      if (clazz is PostConstruct) {
        clazz.onPostConstruct();
      }

      _beans[effectiveQualifierName] = FactoryClazz<BeanT>(
        clazzInstance: clazz,
        type: BeanT,
        scopeType: scope,
        interceptors: inter,
        destroyable: await destroyable,
      );
    }
  }

  @override
  BeanT call<BeanT extends Object>() {
    return get();
  }

  BeanT _getSingleton<BeanT extends Object>(
      FactoryClazz<BeanT> factoryClazz, Object effectiveQualifierName) {
    if (factoryClazz.clazzInstance case var clazz?) {
      if (factoryClazz.interceptors case final inter?) {
        for (final interceptor in inter) {
          clazz = interceptor.call().aroundGet(clazz);
        }
      }

      return clazz;
    }

    throw BeanDestroyed(effectiveQualifierName.toString());
  }

  BeanT _getAplication<BeanT extends Object>(
      FactoryClazz<BeanT> factoryClazz, Object effectiveQualifierName) {
    late BeanT applicationClazz;

    if (factoryClazz.clazzInstance == null) {
      applicationClazz = factoryClazz.clazzRegister!.call();

      if (factoryClazz.interceptors case final inter?) {
        for (final interceptor in inter) {
          applicationClazz =
              interceptor.call().aroundConstruct(applicationClazz);
        }
      }

      applicationClazz =
          _executarDecorators<BeanT>(applicationClazz, factoryClazz.decorators);

      factoryClazz.postConstruct?.call();

      if (applicationClazz is PostConstruct) {
        applicationClazz.onPostConstruct();
      } else if (applicationClazz is Future<PostConstruct>) {
        _runFutureOrPostConstruct(applicationClazz);
      }

      factoryClazz.clazzInstance = applicationClazz;
    } else {
      applicationClazz = factoryClazz.clazzInstance!;
    }

    if (factoryClazz.interceptors case final inter?) {
      for (final interceptor in inter) {
        applicationClazz = interceptor.call().aroundGet(applicationClazz);
      }
    }

    return applicationClazz;
  }

  BeanT _getDependent<BeanT extends Object>(FactoryClazz<BeanT> factoryClazz) {
    BeanT dependentClazz = factoryClazz.clazzRegister!.call();

    if (factoryClazz.interceptors case final inter?) {
      for (final interceptor in inter) {
        dependentClazz = interceptor.call().aroundConstruct(dependentClazz);
      }
    }

    dependentClazz =
        _executarDecorators<BeanT>(dependentClazz, factoryClazz.decorators);

    factoryClazz.postConstruct?.call();

    if (dependentClazz is PostConstruct) {
      dependentClazz.onPostConstruct();
    } else if (dependentClazz is Future<PostConstruct>) {
      _runFutureOrPostConstruct(dependentClazz);
    }

    if (factoryClazz.interceptors case final inter?) {
      for (final interceptor in inter) {
        dependentClazz = interceptor.call().aroundGet(dependentClazz);
      }
    }

    return dependentClazz;
  }

  @override
  BeanT get<BeanT extends Object>({Object? qualifier}) {
    final Object effectiveQualifierName = qualifier ?? BeanT;

    if (_beans[effectiveQualifierName]
        case final FactoryClazz<BeanT> factory?) {
      return runZoned(
        () {
          return _getScoped<BeanT>(factory, effectiveQualifierName);
        },
        zoneValues: {_resolutionKey: <Object, List<Object>>{}},
      );
    }

    throw BeanNotFound(effectiveQualifierName.toString());
  }

  BeanT _getScoped<BeanT extends Object>(
      FactoryClazz<BeanT> factoryClazz, Object effectiveQualifierName) {
    if (_resolutionMap[effectiveQualifierName]?.isNotEmpty ?? false) {
      throw CircularDetection(effectiveQualifierName.toString());
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
  void destroy<BeanT extends Object>({Object? qualifier}) {
    final Object effectiveQualifierName = qualifier ?? BeanT;

    _destroy<BeanT>(effectiveQualifierName);
  }

  void _destroy<BeanT>(Object effectiveQualifierName) {
    if (_beans[effectiveQualifierName] case final factoryClazz?
        when factoryClazz.destroyable) {
      //Only destroy if destroyable was registered with true
      if (factoryClazz.clazzInstance case final clazz?) {
        if (factoryClazz.interceptors case final inter?) {
          for (final interceptor in inter) {
            interceptor.call().aroundDestroy(clazz);
          }
        }

        if (clazz is FutureOr<PreDestroy>) {
          _runFutureOrPreDestroy(clazz, effectiveQualifierName);
          //Should return because the _runFutureOrPreDestroy apply the remove
          return;
        }
      }

      _beans.remove(effectiveQualifierName);
    }
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
  void dispose<BeanT>({Object? qualifier}) {
    final Object effectiveQualifierName = qualifier ?? BeanT;

    if (_beans[effectiveQualifierName]
        case final FactoryClazz<BeanT> factoryClazz?) {
      //Singleton e Object only can destroy
      //Dependent doesn't have instance
      switch (factoryClazz.scopeType) {
        case Scopes.application:
        case Scopes.session:
          _disposeBean<BeanT>(factoryClazz, effectiveQualifierName);
          break;
        default:
          break;
      }
    }
  }

  /// Dispose only clean the class Instance
  void _disposeBean<BeanT>(
    FactoryClazz<BeanT> factoryClazz,
    Object effectiveQualifierName,
  ) {
    if (factoryClazz.clazzInstance != null &&
        factoryClazz.interceptors != null) {
      //Call aroundDispose before reset the clazzInstance
      for (final interceptor in factoryClazz.interceptors!) {
        interceptor().aroundDispose(factoryClazz.clazzInstance as BeanT);
      }
    }

    factoryClazz.clazzInstance = null;
  }

  @override
  void disposeAllSession() {
    for (final MapEntry(:key, :value) in _beans.entries) {
      if (value.scopeType != Scopes.session) {
        continue;
      }

      _disposeBean(value, key);
    }
  }

  @override
  void disposeByType<BeanT extends Object>() {
    final Type type = BeanT;

    final clazz =
        _beans.entries.where((element) => element.value.type == type).toList();

    for (final c in clazz) {
      _disposeBean(c.value, c.key);
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
      throw BeanNotFound(effectiveQualifierName.toString());
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
  FutureOr<void> addInterceptor<BeanT extends Object>(
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
      throw BeanNotFound(effectiveQualifierName.toString());
    }
  }

  @override
  FutureOr<void> refreshObject<BeanT extends Object>(
    BeanT register, {
    Object? qualifier,
  }) {
    final Object effectiveQualifierName = qualifier ?? BeanT;
    final FactoryClazz<BeanT>? factoryClazz =
        _beans[effectiveQualifierName] as FactoryClazz<BeanT>?;

    if (factoryClazz == null) {
      throw BeanNotFound(effectiveQualifierName.toString());
    }

    if (factoryClazz.interceptors != null) {
      for (final interceptor in factoryClazz.interceptors!) {
        register = interceptor.call().aroundConstruct(register);
      }
    }

    factoryClazz.clazzInstance =
        _executarDecorators(register, factoryClazz.decorators);
  }

  void _runFutureOrPostConstruct(Future<PostConstruct> register) async {
    final PostConstruct clazz = await register;

    clazz.onPostConstruct();
  }

  Future<void> _runFutureOrPreDestroy(
      FutureOr<PreDestroy> register, Object effectiveQualifierName) async {
    final PreDestroy clazz = await register;

    clazz.onPreDestroy();

    _beans.remove(effectiveQualifierName);
  }
}
