part of 'dart_di.dart';

class _DDIImpl implements DDI {
  final Map<Object, FactoryClazz> _beans = {};
  static const _resolutionKey = #_resolutionKey;

  final Map<Object, List<Object>> _resolutionMap = Zone.current[_resolutionKey] as Map<Object, List<Object>>? ?? {};

  @override
  void registerSingleton<T extends Object>(
    T Function() clazzRegister, {
    Object? qualifierName,
    void Function()? postConstruct,
    List<T Function(T)>? decorators,
    List<DDIInterceptor<T> Function()>? interceptors,
    bool Function()? registerIf,
  }) {
    if (registerIf?.call() ?? true) {
      final Object effectiveQualifierName = qualifierName ?? T;

      assert(_beans[effectiveQualifierName] == null, 'Is already registered a instance with Type ${effectiveQualifierName.toString()}');

      debugPrint('Registered ${effectiveQualifierName.toString()}');

      T clazz = clazzRegister.call();

      if (interceptors != null) {
        for (var interceptor in interceptors) {
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
      );
    }
  }

  @override
  void registerApplication<T extends Object>(
    T Function() clazzRegister, {
    Object? qualifierName,
    void Function()? postConstruct,
    List<T Function(T)>? decorators,
    List<DDIInterceptor<T> Function()>? interceptors,
    bool Function()? registerIf,
  }) {
    if (registerIf?.call() ?? true) {
      _register<T>(
        clazzRegister: clazzRegister,
        scopeType: Scopes.application,
        qualifierName: qualifierName,
        postConstruct: postConstruct,
        decorators: decorators,
        interceptors: interceptors,
      );
    }
  }

  @override
  void registerSession<T extends Object>(
    T Function() clazzRegister, {
    Object? qualifierName,
    void Function()? postConstruct,
    List<T Function(T)>? decorators,
    List<DDIInterceptor<T> Function()>? interceptors,
    bool Function()? registerIf,
  }) {
    if (registerIf?.call() ?? true) {
      _register<T>(
        clazzRegister: clazzRegister,
        scopeType: Scopes.session,
        qualifierName: qualifierName,
        postConstruct: postConstruct,
        decorators: decorators,
        interceptors: interceptors,
      );
    }
  }

  @override
  void registerDependent<T extends Object>(
    T Function() clazzRegister, {
    Object? qualifierName,
    void Function()? postConstruct,
    List<T Function(T)>? decorators,
    List<DDIInterceptor<T> Function()>? interceptors,
    bool Function()? registerIf,
  }) {
    if (registerIf?.call() ?? true) {
      _register<T>(
        clazzRegister: clazzRegister,
        scopeType: Scopes.dependent,
        qualifierName: qualifierName,
        postConstruct: postConstruct,
        decorators: decorators,
        interceptors: interceptors,
      );
    }
  }

  @override
  void registerWidget<T extends Widget>(
    T Function() clazzRegister, {
    Object? qualifierName,
    void Function()? postConstruct,
    List<T Function(T)>? decorators,
    List<DDIInterceptor<T> Function()>? interceptors,
    bool Function()? registerIf,
  }) {
    if (registerIf?.call() ?? true) {
      _register<T>(
        clazzRegister: clazzRegister,
        scopeType: Scopes.widget,
        qualifierName: qualifierName,
        postConstruct: postConstruct,
        decorators: decorators,
        interceptors: interceptors,
      );
    }
  }

  void _register<T extends Object>({
    required T Function() clazzRegister,
    required Scopes scopeType,
    Object? qualifierName,
    void Function()? postConstruct,
    List<T Function(T)>? decorators,
    List<DDIInterceptor<T> Function()>? interceptors,
  }) {
    final Object effectiveQualifierName = qualifierName ?? T;

    assert(_beans[effectiveQualifierName] == null, 'Is already registered a instance with Type ${effectiveQualifierName.toString()}');

    debugPrint('Registered ${effectiveQualifierName.toString()}');

    _beans[effectiveQualifierName] = FactoryClazz<T>(
      clazzRegister: clazzRegister,
      type: T,
      postConstruct: postConstruct,
      decorators: decorators,
      interceptors: interceptors,
      scopeType: scopeType,
    );
  }

  @override
  T call<T extends Object>() {
    return get();
  }

  T _getSingleton<T extends Object>(FactoryClazz<T> factoryClazz) {
    assert(factoryClazz.clazzInstance != null, 'The Singleton Type ${T.runtimeType.toString()} is destroyed');

    if (factoryClazz.interceptors != null) {
      for (var interceptor in factoryClazz.interceptors!) {
        factoryClazz.clazzInstance = interceptor.call().aroundGet(factoryClazz.clazzInstance!);
      }
    }

    return factoryClazz.clazzInstance!;
  }

  T _getAplication<T extends Object>(FactoryClazz<T> factoryClazz, effectiveQualifierName) {
    T? applicationClazz = factoryClazz.clazzInstance;

    if (factoryClazz.clazzInstance == null) {
      applicationClazz = factoryClazz.clazzRegister!.call();

      if (factoryClazz.interceptors != null) {
        for (final interceptor in factoryClazz.interceptors!) {
          applicationClazz = interceptor.call().aroundConstruct(applicationClazz!);
        }
      }

      applicationClazz = _executarDecorators<T>(applicationClazz!, factoryClazz.decorators);

      factoryClazz.postConstruct?.call();

      factoryClazz.clazzInstance = applicationClazz;
    } else {
      debugPrint('Instância reaproveitada');
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

    dependentClazz = _executarDecorators<T>(dependentClazz, factoryClazz.decorators);

    factoryClazz.postConstruct?.call();

    if (factoryClazz.interceptors != null) {
      for (final interceptor in factoryClazz.interceptors!) {
        dependentClazz = interceptor.call().aroundGet(dependentClazz);
      }
    }

    return dependentClazz;
  }

  @override
  T get<T extends Object>({Object? qualifierName}) {
    final Object effectiveQualifierName = qualifierName ?? T;

    debugPrint('Get ${effectiveQualifierName.toString()}');

    final FactoryClazz<T>? factoryClazz = _beans[effectiveQualifierName] as FactoryClazz<T>?;

    assert(factoryClazz != null, 'No Instance with Type ${effectiveQualifierName.toString()} is found');

    return runZoned(
      () {
        return _getScoped<T>(factoryClazz!, effectiveQualifierName);
      },
      zoneValues: {_resolutionKey: <Object, List<Object>>{}},
    );
  }

  T _getScoped<T extends Object>(FactoryClazz<T> factoryClazz, Object effectiveQualifierName) {
    assert(_resolutionMap[effectiveQualifierName]?.isEmpty ?? true, 'Circular Detection found for Instance Type ${effectiveQualifierName.toString()}!!!');

    _resolutionMap[effectiveQualifierName] = [..._resolutionMap[effectiveQualifierName] ?? [], effectiveQualifierName];

    T result;
    try {
      result = switch (factoryClazz.scopeType) {
        Scopes.singleton => _getSingleton<T>(factoryClazz),
        Scopes.dependent || Scopes.widget => _getDependent<T>(factoryClazz),
        Scopes.application || Scopes.session => _getAplication<T>(factoryClazz, effectiveQualifierName)
      };
    } finally {
      _resolutionMap[effectiveQualifierName]?.removeLast();
    }

    return result;
  }

  @override
  List<Object> getByType<T extends Object>() {
    final Type type = T;

    return _beans.entries.where((element) => element.value.type == type).map((e) => e.key).toList();
  }

  T _executarDecorators<T extends Object>(T clazz, List<T Function(T)>? decorators) {
    if (decorators != null) {
      for (var decorator in decorators) {
        clazz = decorator(clazz);
      }
    }

    return clazz;
  }

  @override
  void destroy<T>({Object? qualifierName}) {
    final Object effectiveQualifierName = qualifierName ?? T;

    _destroy<T>(effectiveQualifierName);
  }

  void _destroy<T>(effectiveQualifierName) {
    debugPrint('Removed ${effectiveQualifierName.toString()}');

    final FactoryClazz<T>? factoryClazz = _beans[effectiveQualifierName] as FactoryClazz<T>?;

    if (factoryClazz != null) {
      if (factoryClazz.clazzInstance != null && factoryClazz.interceptors != null) {
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

  @override
  void destroyAllWidget() {
    _destroyAll(Scopes.widget);
  }

  void _destroyAll(Scopes scope) {
    final keys = _beans.entries.where((element) => element.value.scopeType == scope).map((e) => e.key).toList();

    for (var key in keys) {
      _destroy(key);
    }
  }

  @override
  void destroyByType<T extends Object>() {
    final keys = getByType<T>();

    for (var key in keys) {
      _destroy(key);
    }
  }

  @override
  void dispose<T>({Object? qualifierName}) {
    final Object effectiveQualifierName = qualifierName ?? T;

    final FactoryClazz<T>? factoryClazz = _beans[effectiveQualifierName] as FactoryClazz<T>?;

    if (factoryClazz != null) {
      switch (factoryClazz.scopeType) {
        case Scopes.application:
        case Scopes.session:
          _disposeBean<T>(factoryClazz, effectiveQualifierName);
          break;
        default:
          debugPrint('Only Application and Session can be disposed.');
          break;
      }
    }
  }

  /// Dispose only clean the class Instance
  void _disposeBean<T>(FactoryClazz<T>? factoryClazz, Object effectiveQualifierName) {
    debugPrint('Dispose ${effectiveQualifierName.toString()}');

    if (factoryClazz != null) {
      if (factoryClazz.clazzInstance != null && factoryClazz.interceptors != null) {
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

    final clazz = _beans.entries.where((element) => element.value.type == type).toList();

    for (var c in clazz) {
      _disposeBean(c.value, c.key);
    }
  }

  @override
  void addDecorator<T extends Object>(List<T Function(T p1)> decorators, {Object? qualifierName}) {
    final Object effectiveQualifierName = qualifierName ?? T;

    debugPrint('Add Decorator to ${effectiveQualifierName.toString()}');

    final FactoryClazz<T>? factoryClazz = _beans[effectiveQualifierName] as FactoryClazz<T>?;

    assert(factoryClazz != null, 'No Instance with Type ${effectiveQualifierName.toString()} is found');

    switch (factoryClazz!.scopeType) {
      //Singleton Scopes already have a instance
      case Scopes.singleton:
        factoryClazz.clazzInstance = _executarDecorators<T>(factoryClazz.clazzInstance!, decorators);
        break;
      //Application and Session Scopes may  have a instance created
      case Scopes.application:
      case Scopes.session:
        if (factoryClazz.clazzInstance != null) {
          factoryClazz.clazzInstance = _executarDecorators<T>(factoryClazz.clazzInstance!, decorators);
        }

        factoryClazz.decorators = _orderDecorator(decorators, factoryClazz);

        break;
      //Dependent and Widget Scopes always require a new instance
      case Scopes.dependent:
      case Scopes.widget:
        factoryClazz.decorators = _orderDecorator(decorators, factoryClazz);
        break;
    }
  }

  List<T Function(T p1)> _orderDecorator<T extends Object>(List<T Function(T p1)> decorators, FactoryClazz<T> factoryClazz) {
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
}
