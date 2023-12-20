part of 'dart_di.dart';

class _DDIImpl implements DDI {
  final Map<Object, FactoryClazz> _beans = {};

  @override
  void registerSingleton<T extends Object>(
    T Function() clazzRegister, {
    Object? qualifierName,
    void Function()? postConstruct,
    List<T Function(T)>? decorators,
    DDIInterceptor<T> Function()? interceptor,
    bool Function()? registerIf,
  }) {
    if (registerIf?.call() ?? true) {
      Object effectiveQualifierName = qualifierName ?? T;

      assert(_beans[effectiveQualifierName] == null, 'Is already registered a bean with Type ${effectiveQualifierName.toString()}');

      debugPrint('Registered the Singleton bean ${effectiveQualifierName.toString()}');

      T clazz = clazzRegister.call();

      if (interceptor != null) {
        clazz = interceptor.call().aroundConstruct(clazz);
      }

      clazz = _executarDecorators(clazz, decorators);

      postConstruct?.call();

      _beans[effectiveQualifierName] = FactoryClazz<T>(
        clazzInstance: clazz,
        scopeType: Scopes.singleton,
        interceptor: interceptor,
      );
    }
  }

  @override
  void registerApplication<T extends Object>(
    T Function() clazzRegister, {
    Object? qualifierName,
    void Function()? postConstruct,
    List<T Function(T)>? decorators,
    DDIInterceptor<T> Function()? interceptor,
    bool Function()? registerIf,
  }) {
    if (registerIf?.call() ?? true) {
      _register<T>(
        clazzRegister: clazzRegister,
        scopeType: Scopes.application,
        qualifierName: qualifierName,
        postConstruct: postConstruct,
        decorators: decorators,
        interceptor: interceptor,
      );
    }
  }

  @override
  void registerSession<T extends Object>(
    T Function() clazzRegister, {
    Object? qualifierName,
    void Function()? postConstruct,
    List<T Function(T)>? decorators,
    DDIInterceptor<T> Function()? interceptor,
    bool Function()? registerIf,
  }) {
    if (registerIf?.call() ?? true) {
      _register<T>(
        clazzRegister: clazzRegister,
        scopeType: Scopes.session,
        qualifierName: qualifierName,
        postConstruct: postConstruct,
        decorators: decorators,
        interceptor: interceptor,
      );
    }
  }

  @override
  void registerDependent<T extends Object>(
    T Function() clazzRegister, {
    Object? qualifierName,
    void Function()? postConstruct,
    List<T Function(T)>? decorators,
    DDIInterceptor<T> Function()? interceptor,
    bool Function()? registerIf,
  }) {
    if (registerIf?.call() ?? true) {
      _register<T>(
        clazzRegister: clazzRegister,
        scopeType: Scopes.dependent,
        qualifierName: qualifierName,
        postConstruct: postConstruct,
        decorators: decorators,
        interceptor: interceptor,
      );
    }
  }

  @override
  void registerWidget<T extends Widget>(
    T Function() clazzRegister, {
    Object? qualifierName,
    void Function()? postConstruct,
    List<T Function(T)>? decorators,
    DDIInterceptor<T> Function()? interceptor,
    bool Function()? registerIf,
  }) {
    if (registerIf?.call() ?? true) {
      _register<T>(
        clazzRegister: clazzRegister,
        scopeType: Scopes.widget,
        qualifierName: qualifierName,
        postConstruct: postConstruct,
        decorators: decorators,
        interceptor: interceptor,
      );
    }
  }

  void _register<T extends Object>({
    required T Function() clazzRegister,
    required Scopes scopeType,
    Object? qualifierName,
    void Function()? postConstruct,
    List<T Function(T)>? decorators,
    DDIInterceptor<T> Function()? interceptor,
  }) {
    Object effectiveQualifierName = qualifierName ?? T;

    assert(_beans[effectiveQualifierName] == null, 'Is already registered a bean with Type ${effectiveQualifierName.toString()}');

    debugPrint('Registered the bean ${effectiveQualifierName.toString()}');

    _beans[effectiveQualifierName] = FactoryClazz<T>(
      clazzRegister: clazzRegister,
      postConstruct: postConstruct,
      decorators: decorators,
      interceptor: interceptor,
      scopeType: scopeType,
    );
  }

  @override
  T call<T extends Object>() {
    return get();
  }

  T _getSingleton<T extends Object>(FactoryClazz<T> factoryClazz) {
    assert(factoryClazz.clazzInstance != null, 'The Singleton Type ${T.runtimeType.toString()} is destroyed');

    if (factoryClazz.interceptor == null) {
      return factoryClazz.clazzInstance!;
    }

    return factoryClazz.interceptor!.call().aroundGet(factoryClazz.clazzInstance!);
  }

  T _getAplication<T extends Object>(FactoryClazz<T> factoryClazz, effectiveQualifierName) {
    T? applicationClazz = factoryClazz.clazzInstance;

    if (applicationClazz == null) {
      applicationClazz = factoryClazz.clazzRegister!.call();

      if (factoryClazz.interceptor != null) {
        applicationClazz = factoryClazz.interceptor!.call().aroundConstruct(applicationClazz);
      }

      applicationClazz = _executarDecorators<T>(applicationClazz, factoryClazz.decorators);

      factoryClazz.postConstruct?.call();

      _beans[effectiveQualifierName] = factoryClazz.copyWith(clazzInstance: applicationClazz);
    } else {
      debugPrint('Instância reaproveitada');
    }

    return factoryClazz.interceptor?.call().aroundGet(applicationClazz) ?? applicationClazz;
  }

  T _getDependent<T extends Object>(FactoryClazz<T> factoryClazz) {
    T dependentClazz = factoryClazz.clazzRegister!.call();

    dependentClazz = _executarDecorators<T>(dependentClazz, factoryClazz.decorators);

    factoryClazz.postConstruct?.call();

    dependentClazz = factoryClazz.interceptor?.call().aroundConstruct(dependentClazz) ?? dependentClazz;

    return factoryClazz.interceptor?.call().aroundGet(dependentClazz) ?? dependentClazz;
  }

  @override
  T get<T extends Object>({Object? qualifierName}) {
    Object effectiveQualifierName = qualifierName ?? T;

    debugPrint('Get the bean ${effectiveQualifierName.toString()}');

    FactoryClazz<T>? factoryClazz = _beans[effectiveQualifierName] as FactoryClazz<T>?;

    assert(factoryClazz != null, 'No Bean with Type ${effectiveQualifierName.toString()} is found');

    return switch (factoryClazz!.scopeType) {
      Scopes.singleton => _getSingleton(factoryClazz),
      Scopes.dependent => _getDependent(factoryClazz),
      Scopes.application => _getAplication(factoryClazz, effectiveQualifierName),
      Scopes.session => _getAplication(factoryClazz, effectiveQualifierName),
      Scopes.widget => _getDependent(factoryClazz)
    };
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
  void dispose<T>({Object? qualifierName}) {
    Object effectiveQualifierName = qualifierName ?? T;
    debugPrint('Dispose the bean ${effectiveQualifierName.toString()}');

    FactoryClazz<T>? factoryClazz = _beans[effectiveQualifierName] as FactoryClazz<T>?;

    if (factoryClazz != null) {
      switch (factoryClazz.scopeType) {
        case Scopes.singleton:
          destroy<T>(qualifierName: qualifierName);
          break;
        default:
          _disposeScope<T>(factoryClazz, effectiveQualifierName);
          break;
      }
    }
  }

  void _disposeScope<T>(FactoryClazz<T>? factoryClazz, Object effectiveQualifierName) {
    if (factoryClazz != null) {
      if (factoryClazz.clazzInstance != null) {
        factoryClazz.interceptor?.call().aroundDispose(factoryClazz.clazzInstance as T);
      }

      _beans[effectiveQualifierName] = FactoryClazz<T>(
        clazzRegister: factoryClazz.clazzRegister,
        postConstruct: factoryClazz.postConstruct,
        decorators: factoryClazz.decorators,
        interceptor: factoryClazz.interceptor,
        scopeType: factoryClazz.scopeType,
      );
    }
  }

  @override
  void destroy<T>({Object? qualifierName}) {
    Object effectiveQualifierName = qualifierName ?? T;
    debugPrint('Removed the bean ${effectiveQualifierName.toString()}');

    FactoryClazz<T>? factoryClazz = _beans[effectiveQualifierName] as FactoryClazz<T>?;

    if (factoryClazz != null) {
      if (factoryClazz.clazzInstance != null) {
        factoryClazz.interceptor?.call().aroundDestroy(factoryClazz.clazzInstance as T);
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
    final widgetDestroy = _beans.entries.where((element) => element.value.scopeType == scope);

    for (var clazz in widgetDestroy) {
      clazz.value.interceptor?.call().aroundDestroy(clazz.value.clazzRegister);
      _beans.remove(clazz.key);
    }
  }

  @override
  void disposeAllSession() {
    _disposeAll(Scopes.session);
  }

  @override
  void disposeAllWidget() {
    _disposeAll(Scopes.widget);
  }

  void _disposeAll(Scopes scope) {
    final widgetDestroy = _beans.entries.where((element) => element.value.scopeType == scope);

    for (var clazz in widgetDestroy) {
      clazz.value.interceptor?.call().aroundDispose(clazz.value.clazzInstance);

      _beans[clazz.key] = FactoryClazz(
        clazzRegister: clazz.value.clazzRegister,
        postConstruct: clazz.value.postConstruct,
        decorators: clazz.value.decorators,
        interceptor: clazz.value.interceptor,
        scopeType: clazz.value.scopeType,
      );
    }
  }

  @override
  void addDecorator<T extends Object>(List<T Function(T p1)> decorators, {Object? qualifierName}) {
    Object effectiveQualifierName = qualifierName ?? T;

    debugPrint('Add Decorator to the bean ${effectiveQualifierName.toString()}');

    FactoryClazz<T>? factoryClazz = _beans[effectiveQualifierName] as FactoryClazz<T>?;

    assert(factoryClazz != null, 'No Bean with Type ${effectiveQualifierName.toString()} is found');

    switch (factoryClazz!.scopeType) {
      //Singleton Scopes already have a instance
      case Scopes.singleton:
        var clazz = _executarDecorators<T>(factoryClazz.clazzInstance!, decorators);
        _beans[effectiveQualifierName] = factoryClazz.copyWith(clazzInstance: clazz);
        break;
      //Application and Session Scopes may  have a instance created
      case Scopes.application:
      case Scopes.session:
        List<T Function(T p1)> updatedDecorators = _orderDecorator(decorators, factoryClazz);

        if (factoryClazz.clazzInstance != null) {
          var clazz = _executarDecorators<T>(factoryClazz.clazzInstance!, decorators);
          _beans[effectiveQualifierName] = factoryClazz.copyWith(clazzInstance: clazz, decorators: updatedDecorators);
        } else {
          _beans[effectiveQualifierName] = factoryClazz.copyWith(decorators: updatedDecorators);
        }

        break;
      //Dependent and Widget Scopes always require a new instance
      case Scopes.dependent:
      case Scopes.widget:
        List<T Function(T p1)> updatedDecorators = _orderDecorator(decorators, factoryClazz);
        _beans[effectiveQualifierName] = factoryClazz.copyWith(decorators: updatedDecorators);
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
