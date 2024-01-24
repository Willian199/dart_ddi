part of 'dart_ddi.dart';

const _debug = !bool.fromEnvironment('dart.vm.product') &&
    !bool.fromEnvironment('dart.vm.profile');

class _DDIImpl implements DDI {
  final Map<Object, FactoryClazz> _beans = {};
  static const _resolutionKey = #_resolutionKey;

  final Map<Object, List<Object>> _resolutionMap =
      Zone.current[_resolutionKey] as Map<Object, List<Object>>? ?? {};

  @override
  void registerSingleton<BeanT extends Object>(
    BeanT Function() clazzRegister, {
    Object? qualifier,
    void Function()? postConstruct,
    List<BeanT Function(BeanT)>? decorators,
    List<DDIInterceptor<BeanT> Function()>? interceptors,
    bool Function()? registerIf,
    bool destroyable = true,
  }) {
    if (registerIf?.call() ?? true) {
      final Object effectiveQualifierName = qualifier ?? BeanT;

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
  void registerApplication<BeanT extends Object>(
    BeanT Function() clazzRegister, {
    Object? qualifier,
    void Function()? postConstruct,
    List<BeanT Function(BeanT)>? decorators,
    List<DDIInterceptor<BeanT> Function()>? interceptors,
    bool Function()? registerIf,
    bool destroyable = true,
  }) {
    if (registerIf?.call() ?? true) {
      _register<BeanT>(
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
  void registerSession<BeanT extends Object>(
    BeanT Function() clazzRegister, {
    Object? qualifier,
    void Function()? postConstruct,
    List<BeanT Function(BeanT)>? decorators,
    List<DDIInterceptor<BeanT> Function()>? interceptors,
    bool Function()? registerIf,
    bool destroyable = true,
  }) {
    if (registerIf?.call() ?? true) {
      _register<BeanT>(
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
  void registerDependent<BeanT extends Object>(
    BeanT Function() clazzRegister, {
    Object? qualifier,
    void Function()? postConstruct,
    List<BeanT Function(BeanT)>? decorators,
    List<DDIInterceptor<BeanT> Function()>? interceptors,
    bool Function()? registerIf,
    bool destroyable = true,
  }) {
    if (registerIf?.call() ?? true) {
      _register<BeanT>(
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

  void _register<BeanT extends Object>({
    required BeanT Function() clazzRegister,
    required Scopes scopeType,
    required bool destroyable,
    Object? qualifier,
    void Function()? postConstruct,
    List<BeanT Function(BeanT)>? decorators,
    List<DDIInterceptor<BeanT> Function()>? interceptors,
  }) {
    final Object effectiveQualifierName = qualifier ?? BeanT;

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

  @override
  void registerObject<BeanT extends Object>(
    BeanT register, {
    Object? qualifier,
    void Function()? postConstruct,
    List<BeanT Function(BeanT)>? decorators,
    List<DDIInterceptor<BeanT> Function()>? interceptors,
    bool Function()? registerIf,
    bool destroyable = true,
  }) {
    if (registerIf?.call() ?? true) {
      final Object effectiveQualifierName = qualifier ?? BeanT;

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

      if (interceptors != null) {
        for (final interceptor in interceptors) {
          register = interceptor.call().aroundConstruct(register);
        }
      }

      register = _executarDecorators(register, decorators);

      postConstruct?.call();

      if (register is PostConstruct) {
        register.onPostConstruct();
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

  BeanT _getSingleton<BeanT extends Object>(FactoryClazz<BeanT> factoryClazz) {
    assert(factoryClazz.clazzInstance != null,
        'The Singleton Type ${BeanT.runtimeType.toString()} is destroyed');

    if (factoryClazz.interceptors != null) {
      for (final interceptor in factoryClazz.interceptors!) {
        factoryClazz.clazzInstance =
            interceptor.call().aroundGet(factoryClazz.clazzInstance!);
      }
    }

    return factoryClazz.clazzInstance!;
  }

  BeanT _getAplication<BeanT extends Object>(
      FactoryClazz<BeanT> factoryClazz, effectiveQualifierName) {
    BeanT? applicationClazz = factoryClazz.clazzInstance;

    if (factoryClazz.clazzInstance == null) {
      applicationClazz = factoryClazz.clazzRegister!.call();

      if (factoryClazz.interceptors != null) {
        for (final interceptor in factoryClazz.interceptors!) {
          applicationClazz =
              interceptor.call().aroundConstruct(applicationClazz!);
        }
      }

      applicationClazz = _executarDecorators<BeanT>(
          applicationClazz!, factoryClazz.decorators);

      factoryClazz.postConstruct?.call();

      if (applicationClazz is PostConstruct) {
        applicationClazz.onPostConstruct();
      }

      factoryClazz.clazzInstance = applicationClazz;
    }

    if (factoryClazz.interceptors != null) {
      for (final interceptor in factoryClazz.interceptors!) {
        applicationClazz = interceptor.call().aroundGet(applicationClazz!);
      }
    }

    return applicationClazz!;
  }

  BeanT _getDependent<BeanT extends Object>(FactoryClazz<BeanT> factoryClazz) {
    BeanT dependentClazz = factoryClazz.clazzRegister!.call();

    if (factoryClazz.interceptors != null) {
      for (final interceptor in factoryClazz.interceptors!) {
        dependentClazz = interceptor.call().aroundConstruct(dependentClazz);
      }
    }

    dependentClazz =
        _executarDecorators<BeanT>(dependentClazz, factoryClazz.decorators);

    factoryClazz.postConstruct?.call();

    if (dependentClazz is PostConstruct) {
      dependentClazz.onPostConstruct();
    }

    if (factoryClazz.interceptors != null) {
      for (final interceptor in factoryClazz.interceptors!) {
        dependentClazz = interceptor.call().aroundGet(dependentClazz);
      }
    }

    return dependentClazz;
  }

  @override
  BeanT get<BeanT extends Object>({Object? qualifier}) {
    final Object effectiveQualifierName = qualifier ?? BeanT;

    final FactoryClazz<BeanT>? factoryClazz =
        _beans[effectiveQualifierName] as FactoryClazz<BeanT>?;

    if (factoryClazz == null) {
      throw BeanNotFound(
          'No Instance with Type ${effectiveQualifierName.toString()} is found.');
    }

    return runZoned(
      () {
        return _getScoped<BeanT>(factoryClazz, effectiveQualifierName);
      },
      zoneValues: {_resolutionKey: <Object, List<Object>>{}},
    );
  }

  BeanT _getScoped<BeanT extends Object>(
      FactoryClazz<BeanT> factoryClazz, Object effectiveQualifierName) {
    if (_resolutionMap[effectiveQualifierName]?.isNotEmpty ?? false) {
      throw CircularDetection(
          'Circular Detection found for Instance Type ${effectiveQualifierName.toString()}!!!');
    }

    _resolutionMap[effectiveQualifierName] = [
      ..._resolutionMap[effectiveQualifierName] ?? [],
      effectiveQualifierName
    ];

    BeanT result;
    try {
      result = switch (factoryClazz.scopeType) {
        Scopes.singleton || Scopes.object => _getSingleton<BeanT>(factoryClazz),
        Scopes.dependent => _getDependent<BeanT>(factoryClazz),
        Scopes.application ||
        Scopes.session =>
          _getAplication<BeanT>(factoryClazz, effectiveQualifierName)
      };
    } finally {
      _resolutionMap[effectiveQualifierName]?.removeLast();
    }

    return result;
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
      BeanT clazz, List<BeanT Function(BeanT)>? decorators) {
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

  void _destroy<BeanT>(effectiveQualifierName) {
    final FactoryClazz<BeanT>? factoryClazz =
        _beans[effectiveQualifierName] as FactoryClazz<BeanT>?;

    if (factoryClazz != null && factoryClazz.destroyable) {
      if (factoryClazz.clazzInstance != null) {
        if (factoryClazz.interceptors != null) {
          for (final interceptor in factoryClazz.interceptors!) {
            interceptor
                .call()
                .aroundDestroy(factoryClazz.clazzInstance as BeanT);
          }
        }

        if (factoryClazz.clazzInstance is PreDestroy) {
          (factoryClazz.clazzInstance as PreDestroy).onPreDestroy();
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
  void destroyByType<BeanT extends Object>() {
    final keys = getByType<BeanT>();

    for (final key in keys) {
      _destroy(key);
    }
  }

  @override
  void dispose<BeanT>({Object? qualifier}) {
    final Object effectiveQualifierName = qualifier ?? BeanT;

    final FactoryClazz<BeanT>? factoryClazz =
        _beans[effectiveQualifierName] as FactoryClazz<BeanT>?;

    if (factoryClazz != null) {
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
      FactoryClazz<BeanT>? factoryClazz, Object effectiveQualifierName) {
    if (factoryClazz != null) {
      if (factoryClazz.clazzInstance != null &&
          factoryClazz.interceptors != null) {
        for (final interceptor in factoryClazz.interceptors!) {
          interceptor.call().aroundDispose(factoryClazz.clazzInstance as BeanT);
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
  void disposeByType<BeanT extends Object>() {
    final Type type = BeanT;

    final clazz =
        _beans.entries.where((element) => element.value.type == type).toList();

    for (final c in clazz) {
      _disposeBean(c.value, c.key);
    }
  }

  @override
  void addDecorator<BeanT extends Object>(
      List<BeanT Function(BeanT)> decorators,
      {Object? qualifier}) {
    final Object effectiveQualifierName = qualifier ?? BeanT;

    final FactoryClazz<BeanT>? factoryClazz =
        _beans[effectiveQualifierName] as FactoryClazz<BeanT>?;

    if (factoryClazz == null) {
      throw BeanNotFound(
          'No Instance with Type ${effectiveQualifierName.toString()} is found.');
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
        if (factoryClazz.clazzInstance != null) {
          factoryClazz.clazzInstance = _executarDecorators<BeanT>(
              factoryClazz.clazzInstance!, decorators);
        }

        factoryClazz.decorators = _orderDecorator(decorators, factoryClazz);

        break;
      //Dependent Scopes always require a new instance
      case Scopes.dependent:
        factoryClazz.decorators = _orderDecorator(decorators, factoryClazz);
        break;
    }
  }

  List<BeanT Function(BeanT p1)> _orderDecorator<BeanT extends Object>(
      List<BeanT Function(BeanT p1)> decorators,
      FactoryClazz<BeanT> factoryClazz) {
    List<BeanT Function(BeanT p1)> updatedDecorators = [];

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
  void addInterceptor<BeanT extends Object>(
      List<DDIInterceptor<BeanT> Function()> interceptors,
      {Object? qualifier}) {
    final Object effectiveQualifierName = qualifier ?? BeanT;

    final FactoryClazz<BeanT>? factoryClazz =
        _beans[effectiveQualifierName] as FactoryClazz<BeanT>?;

    if (factoryClazz == null) {
      throw BeanNotFound(
          'No Instance with Type ${effectiveQualifierName.toString()} is found.');
    }

    if (factoryClazz.interceptors == null) {
      factoryClazz.interceptors = interceptors;
    } else {
      factoryClazz.interceptors?.addAll(interceptors);
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
      throw BeanNotFound(
          'No registered with Type ${effectiveQualifierName.toString()} is found.');
    }

    if (factoryClazz.interceptors != null) {
      for (final interceptor in factoryClazz.interceptors!) {
        register = interceptor.call().aroundConstruct(register);
      }
    }

    factoryClazz.clazzInstance =
        _executarDecorators(register, factoryClazz.decorators);
  }
}
