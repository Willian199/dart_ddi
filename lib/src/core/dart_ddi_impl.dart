part of 'dart_ddi.dart';

class _DDIImpl implements DDI {
  final Map<Object, FactoryClazz> _beans = {};
  static const _resolutionKey = #_resolutionKey;

  final Map<Object, List<Object>> _resolutionMap =
      Zone.current[_resolutionKey] as Map<Object, List<Object>>? ?? {};

  @override
  void registerSingleton<T extends Object>(
    T Function() clazzRegister, {
    Object? qualifier,
    void Function()? postConstruct,
    List<T Function(T)>? decorators,
    List<DDIInterceptor<T> Function()>? interceptors,
    bool Function()? registerIf,
    bool destroyable = true,
  }) {
    if (registerIf?.call() ?? true) {
      final Object effectiveQualifierName = qualifier ?? T;

      assert(_beans[effectiveQualifierName] == null,
          'Is already registered a instance with Type ${effectiveQualifierName.toString()}');

      T clazz = clazzRegister.call();

      if (interceptors != null) {
        for (final interceptor in interceptors) {
          clazz = interceptor.call().aroundConstruct(clazz);
        }
      }

      clazz = _executarDecorators(clazz, decorators);

      postConstruct?.call();

      _beans[effectiveQualifierName] = FactoryClazz<T>(
        clazzInstance: clazz,
        type: T,
        scopeType: Scopes.singleton,
        interceptors: interceptors,
        destroyable: destroyable,
      );
    }
  }

  @override
  void registerApplication<T extends Object>(
    T Function() clazzRegister, {
    Object? qualifier,
    void Function()? postConstruct,
    List<T Function(T)>? decorators,
    List<DDIInterceptor<T> Function()>? interceptors,
    bool Function()? registerIf,
    bool destroyable = true,
  }) {
    if (registerIf?.call() ?? true) {
      _register<T>(
        clazzRegister: clazzRegister,
        scopeType: Scopes.application,
        qualifier: qualifier,
        postConstruct: postConstruct,
        decorators: decorators,
        interceptors: interceptors,
        destroyable: destroyable,
      );
    }
  }

  @override
  void registerSession<T extends Object>(
    T Function() clazzRegister, {
    Object? qualifier,
    void Function()? postConstruct,
    List<T Function(T)>? decorators,
    List<DDIInterceptor<T> Function()>? interceptors,
    bool Function()? registerIf,
    bool destroyable = true,
  }) {
    if (registerIf?.call() ?? true) {
      _register<T>(
        clazzRegister: clazzRegister,
        scopeType: Scopes.session,
        qualifier: qualifier,
        postConstruct: postConstruct,
        decorators: decorators,
        interceptors: interceptors,
        destroyable: destroyable,
      );
    }
  }

  @override
  void registerDependent<T extends Object>(
    T Function() clazzRegister, {
    Object? qualifier,
    void Function()? postConstruct,
    List<T Function(T)>? decorators,
    List<DDIInterceptor<T> Function()>? interceptors,
    bool Function()? registerIf,
    bool destroyable = true,
  }) {
    if (registerIf?.call() ?? true) {
      _register<T>(
        clazzRegister: clazzRegister,
        scopeType: Scopes.dependent,
        qualifier: qualifier,
        postConstruct: postConstruct,
        decorators: decorators,
        interceptors: interceptors,
        destroyable: destroyable,
      );
    }
  }

  void _register<T extends Object>({
    required T Function() clazzRegister,
    required Scopes scopeType,
    required bool destroyable,
    Object? qualifier,
    void Function()? postConstruct,
    List<T Function(T)>? decorators,
    List<DDIInterceptor<T> Function()>? interceptors,
  }) {
    final Object effectiveQualifierName = qualifier ?? T;

    assert(_beans[effectiveQualifierName] == null,
        'Is already registered a instance with Type ${effectiveQualifierName.toString()}');

    _beans[effectiveQualifierName] = FactoryClazz<T>(
      clazzRegister: clazzRegister,
      type: T,
      postConstruct: postConstruct,
      decorators: decorators,
      interceptors: interceptors,
      scopeType: scopeType,
      destroyable: destroyable,
    );
  }

  @override
  void registerObject<T extends Object>({
    required Object qualifier,
    required T register,
    void Function()? postConstruct,
    List<T Function(T)>? decorators,
    List<DDIInterceptor<T> Function()>? interceptors,
    bool Function()? registerIf,
    bool destroyable = true,
  }) {
    if (registerIf?.call() ?? true) {
      assert(_beans[qualifier] == null,
          'Is already registered a instance with Type ${qualifier.toString()}');

      if (interceptors != null) {
        for (final interceptor in interceptors) {
          register = interceptor.call().aroundConstruct(register);
        }
      }

      register = _executarDecorators(register, decorators);

      postConstruct?.call();

      _beans[qualifier] = FactoryClazz<T>(
        clazzInstance: register,
        type: T,
        scopeType: Scopes.object,
        interceptors: interceptors,
        destroyable: destroyable,
      );
    }
  }

  @override
  T call<T extends Object>() {
    return get();
  }

  T _getSingleton<T extends Object>(FactoryClazz<T> factoryClazz) {
    assert(factoryClazz.clazzInstance != null,
        'The Singleton Type ${T.runtimeType.toString()} is destroyed');

    if (factoryClazz.interceptors != null) {
      for (final interceptor in factoryClazz.interceptors!) {
        factoryClazz.clazzInstance =
            interceptor.call().aroundGet(factoryClazz.clazzInstance!);
      }
    }

    return factoryClazz.clazzInstance!;
  }

  T _getAplication<T extends Object>(
      FactoryClazz<T> factoryClazz, effectiveQualifierName) {
    T? applicationClazz = factoryClazz.clazzInstance;

    if (factoryClazz.clazzInstance == null) {
      applicationClazz = factoryClazz.clazzRegister!.call();

      if (factoryClazz.interceptors != null) {
        for (final interceptor in factoryClazz.interceptors!) {
          applicationClazz =
              interceptor.call().aroundConstruct(applicationClazz!);
        }
      }

      applicationClazz =
          _executarDecorators<T>(applicationClazz!, factoryClazz.decorators);

      factoryClazz.postConstruct?.call();

      factoryClazz.clazzInstance = applicationClazz;
    }

    if (factoryClazz.interceptors != null) {
      for (final interceptor in factoryClazz.interceptors!) {
        applicationClazz = interceptor.call().aroundGet(applicationClazz!);
      }
    }

    return applicationClazz!;
  }

  T _getDependent<T extends Object>(FactoryClazz<T> factoryClazz) {
    T dependentClazz = factoryClazz.clazzRegister!.call();

    if (factoryClazz.interceptors != null) {
      for (final interceptor in factoryClazz.interceptors!) {
        dependentClazz = interceptor.call().aroundConstruct(dependentClazz);
      }
    }

    dependentClazz =
        _executarDecorators<T>(dependentClazz, factoryClazz.decorators);

    factoryClazz.postConstruct?.call();

    if (factoryClazz.interceptors != null) {
      for (final interceptor in factoryClazz.interceptors!) {
        dependentClazz = interceptor.call().aroundGet(dependentClazz);
      }
    }

    return dependentClazz;
  }

  @override
  T get<T extends Object>({Object? qualifier}) {
    final Object effectiveQualifierName = qualifier ?? T;

    final FactoryClazz<T>? factoryClazz =
        _beans[effectiveQualifierName] as FactoryClazz<T>?;

    assert(factoryClazz != null,
        'No Instance with Type ${effectiveQualifierName.toString()} is found');

    return runZoned(
      () {
        return _getScoped<T>(factoryClazz!, effectiveQualifierName);
      },
      zoneValues: {_resolutionKey: <Object, List<Object>>{}},
    );
  }

  T _getScoped<T extends Object>(
      FactoryClazz<T> factoryClazz, Object effectiveQualifierName) {
    assert(_resolutionMap[effectiveQualifierName]?.isEmpty ?? true,
        'Circular Detection found for Instance Type ${effectiveQualifierName.toString()}!!!');

    _resolutionMap[effectiveQualifierName] = [
      ..._resolutionMap[effectiveQualifierName] ?? [],
      effectiveQualifierName
    ];

    T result;
    try {
      result = switch (factoryClazz.scopeType) {
        Scopes.singleton || Scopes.object => _getSingleton<T>(factoryClazz),
        Scopes.dependent => _getDependent<T>(factoryClazz),
        Scopes.application ||
        Scopes.session =>
          _getAplication<T>(factoryClazz, effectiveQualifierName)
      };
    } finally {
      _resolutionMap[effectiveQualifierName]?.removeLast();
    }

    return result;
  }

  @override
  List<Object> getByType<T extends Object>() {
    final Type type = T;

    return _beans.entries
        .where((element) => element.value.type == type)
        .map((e) => e.key)
        .toList();
  }

  T _executarDecorators<T extends Object>(
      T clazz, List<T Function(T)>? decorators) {
    if (decorators != null) {
      for (final decorator in decorators) {
        clazz = decorator(clazz);
      }
    }

    return clazz;
  }

  @override
  void destroy<T>({Object? qualifier}) {
    final Object effectiveQualifierName = qualifier ?? T;

    _destroy<T>(effectiveQualifierName);
  }

  void _destroy<T>(effectiveQualifierName) {
    final FactoryClazz<T>? factoryClazz =
        _beans[effectiveQualifierName] as FactoryClazz<T>?;

    if (factoryClazz != null && factoryClazz.destroyable) {
      if (factoryClazz.clazzInstance != null &&
          factoryClazz.interceptors != null) {
        for (final interceptor in factoryClazz.interceptors!) {
          interceptor.call().aroundDestroy(factoryClazz.clazzInstance as T);
        }
      }

      _beans.remove(effectiveQualifierName);
    }
  }

  @override
  void destroyAllSession() {
    _destroyAll(Scopes.session);
  }

  void _destroyAll(Scopes scope) {
    final keys = _beans.entries
        .where((element) =>
            element.value.scopeType == scope && element.value.destroyable)
        .map((e) => e.key)
        .toList();

    for (final key in keys) {
      _destroy(key);
    }
  }

  @override
  void destroyByType<T extends Object>() {
    final keys = getByType<T>();

    for (final key in keys) {
      _destroy(key);
    }
  }

  @override
  void dispose<T>({Object? qualifier}) {
    final Object effectiveQualifierName = qualifier ?? T;

    final FactoryClazz<T>? factoryClazz =
        _beans[effectiveQualifierName] as FactoryClazz<T>?;

    if (factoryClazz != null) {
      switch (factoryClazz.scopeType) {
        case Scopes.application:
        case Scopes.session:
          _disposeBean<T>(factoryClazz, effectiveQualifierName);
          break;
        default:
          break;
      }
    }
  }

  /// Dispose only clean the class Instance
  void _disposeBean<T>(
      FactoryClazz<T>? factoryClazz, Object effectiveQualifierName) {
    if (factoryClazz != null) {
      if (factoryClazz.clazzInstance != null &&
          factoryClazz.interceptors != null) {
        for (final interceptor in factoryClazz.interceptors!) {
          interceptor.call().aroundDispose(factoryClazz.clazzInstance as T);
        }
      }

      factoryClazz.clazzInstance = null;
    }
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
  void disposeByType<T extends Object>() {
    final Type type = T;

    final clazz =
        _beans.entries.where((element) => element.value.type == type).toList();

    for (final c in clazz) {
      _disposeBean(c.value, c.key);
    }
  }

  @override
  void addDecorator<T extends Object>(List<T Function(T)> decorators,
      {Object? qualifier}) {
    final Object effectiveQualifierName = qualifier ?? T;

    final FactoryClazz<T>? factoryClazz =
        _beans[effectiveQualifierName] as FactoryClazz<T>?;

    assert(factoryClazz != null,
        'No Instance with Type ${effectiveQualifierName.toString()} is found');

    switch (factoryClazz!.scopeType) {
      //Singleton Scopes already have a instance
      case Scopes.singleton:
      case Scopes.object:
        factoryClazz.clazzInstance =
            _executarDecorators<T>(factoryClazz.clazzInstance!, decorators);
        break;
      //Application and Session Scopes may  have a instance created
      case Scopes.application:
      case Scopes.session:
        if (factoryClazz.clazzInstance != null) {
          factoryClazz.clazzInstance =
              _executarDecorators<T>(factoryClazz.clazzInstance!, decorators);
        }

        factoryClazz.decorators = _orderDecorator(decorators, factoryClazz);

        break;
      //Dependent Scopes always require a new instance
      case Scopes.dependent:
        factoryClazz.decorators = _orderDecorator(decorators, factoryClazz);
        break;
    }
  }

  List<T Function(T p1)> _orderDecorator<T extends Object>(
      List<T Function(T p1)> decorators, FactoryClazz<T> factoryClazz) {
    List<T Function(T p1)> updatedDecorators = [];

    if (factoryClazz.decorators != null) {
      updatedDecorators = decorators.reversed.toList();

      updatedDecorators.addAll(factoryClazz.decorators!.reversed.toList());

      updatedDecorators = updatedDecorators.reversed.toList();
    } else {
      updatedDecorators = decorators;
    }

    return updatedDecorators;
  }

  @override
  void addInterceptor<T extends Object>(
      List<DDIInterceptor<T> Function()> interceptors,
      {Object? qualifier}) {
    final Object effectiveQualifierName = qualifier ?? T;

    final FactoryClazz<T>? factoryClazz =
        _beans[effectiveQualifierName] as FactoryClazz<T>?;

    assert(factoryClazz != null,
        'No Instance with Type ${effectiveQualifierName.toString()} is found');

    if (factoryClazz!.interceptors == null) {
      factoryClazz.interceptors = interceptors;
    } else {
      factoryClazz.interceptors?.addAll(interceptors);
    }
  }

  @override
  void refreshObject<T extends Object>({
    required Object qualifier,
    required T register,
  }) {
    final FactoryClazz<T>? factoryClazz = _beans[qualifier] as FactoryClazz<T>?;

    assert(factoryClazz != null && factoryClazz.scopeType == Scopes.object,
        'No Object registered with Type ${qualifier.toString()}');

    if (factoryClazz!.interceptors != null) {
      for (final interceptor in factoryClazz.interceptors!) {
        register = interceptor.call().aroundConstruct(register);
      }
    }

    factoryClazz.clazzInstance =
        _executarDecorators(register, factoryClazz.decorators);
  }
}
