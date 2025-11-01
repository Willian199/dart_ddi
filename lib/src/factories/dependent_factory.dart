import 'dart:async';

import 'package:dart_ddi/dart_ddi.dart';
import 'package:dart_ddi/src/exception/bean_destroyed.dart';
import 'package:dart_ddi/src/exception/concurrent_creation.dart';
import 'package:dart_ddi/src/typedef/typedef.dart';
import 'package:dart_ddi/src/utils/instance_destroy_utils.dart';

/// Create a new instance every time it is requested.
///
/// This scope defines its behavior on the [getWith] or [getAsyncWith] methods.
///
/// It will do the following:
/// * Create the instance.
/// * Run the Interceptor for create process.
/// * Apply all Decorators to the instance.
/// * Run the PostConstruct for the instance.
/// * Run the Interceptor for get process.
///
/// `Note`: `PreDispose` and `PreDestroy` mixins will only be called if the instance is in use. Use `Interceptor` if you want to call them regardless.
class DependentFactory<BeanT extends Object> extends DDIScopeFactory<BeanT> {
  DependentFactory({
    required CustomBuilder<FutureOr<BeanT>> builder,
    bool canDestroy = true,
    ListDecorator<BeanT> decorators = const [],
    Set<Object> interceptors = const {},
    Set<Object> children = const {},
    super.selector,
  })  : _builder = builder,
        _canDestroy = canDestroy,
        _decorators = decorators,
        _interceptors = interceptors,
        _children = children;

  /// The factory builder responsible for creating the Bean.
  final CustomBuilder<FutureOr<BeanT>> _builder;

  /// A list of decorators that are applied during the Bean creation process.
  ListDecorator<BeanT> _decorators;

  /// A list of interceptors that are called at various stages of the Bean usage.
  Set<Object> _interceptors;

  /// A flag that indicates whether the Bean can be destroyed after its usage.
  final bool _canDestroy;

  /// The child objects associated with the Bean, acting as a module.
  Set<Object> _children;

  /// The current _state of this factory in its lifecycle.
  BeanStateEnum _state = BeanStateEnum.none;

  // Prevents Circular Dependency Injection during Instance Creation
  static const _resolutionKey = #_resolutionKey;

  static Set<Object> _getResolutionMap() {
    return Zone.current[_resolutionKey] as Set<Object>? ?? {};
  }

  @override
  BeanStateEnum get state => _state;

  /// Verify if this factory is a Future.
  @override
  bool get isFuture => _builder.isFuture || BeanT is Future;

  /// Verify if this factory is ready (Created).
  @override
  bool get isReady => false;

  @override
  bool get isRegistered => BeanStateEnum.registered == _state;

  @override
  Set<Object> get children => _children;

  /// Register the instance in [DDI].
  /// When the instance is ready, must call apply function.
  @override
  Future<void> register({required Object qualifier}) async {
    _state = BeanStateEnum.registered;
  }

  /// Gets or creates this instance.
  ///
  /// - `parameter`: Optional parameter to pass during the instance creation.
  ///
  /// **Note:** The `parameter` will be ignored: If the instance is already created or the constructor doesn't match with the parameter type.
  @override
  BeanT getWith<ParameterT extends Object>({
    required Object qualifier,
    ParameterT? parameter,
  }) {
    _checkState(qualifier);

    // If resolutionMap doesn't exist in the current zone, create a new zone with a new map
    if (Zone.current[_resolutionKey] == null) {
      return runZoned(
        () => _runner<ParameterT>(qualifier: qualifier, parameter: parameter),
        zoneValues: {_resolutionKey: <Object>{}},
      );
    } else {
      return _runner<ParameterT>(qualifier: qualifier, parameter: parameter);
    }
  }

  BeanT _runner<ParameterT extends Object>({
    required Object qualifier,
    ParameterT? parameter,
  }) {
    final resolutionMap = _getResolutionMap();

    if (resolutionMap.contains(qualifier)) {
      throw ConcurrentCreationException(qualifier.toString());
    }

    resolutionMap.add(qualifier);

    try {
      BeanT dependentClazz = createInstance<BeanT, ParameterT>(
        builder: _builder,
        parameter: parameter,
      );

      if (_interceptors.isNotEmpty) {
        for (final interceptor in _interceptors) {
          dependentClazz = ddi
              .get<DDIInterceptor>(qualifier: interceptor)
              .onCreate(dependentClazz) as BeanT;
        }
      }

      assert(
        dependentClazz is! PreDispose || dependentClazz is! Future<PreDispose>,
        'Dependent instances dont support PreDispose. Use Interceptors instead.',
      );
      assert(
        dependentClazz is! PreDestroy || dependentClazz is! Future<PreDestroy>,
        'Dependent instances dont support PreDestroy. Use Interceptors instead.',
      );

      if (_decorators.isNotEmpty) {
        for (final decorator in _decorators) {
          dependentClazz = decorator(dependentClazz);
        }
      }

      if (dependentClazz is DDIModule) {
        dependentClazz.moduleQualifier = qualifier;
      }

      if (dependentClazz is PostConstruct) {
        dependentClazz.onPostConstruct();
      } else if (dependentClazz is Future<PostConstruct>) {
        dependentClazz.then(
          (PostConstruct postConstruct) => postConstruct.onPostConstruct(),
        );
      }

      /// Run the Interceptors for the GET process.
      /// Must run everytime
      if (_interceptors.isNotEmpty) {
        for (final interceptor in _interceptors) {
          dependentClazz = ddi
              .get<DDIInterceptor>(qualifier: interceptor)
              .onGet(dependentClazz) as BeanT;
        }
      }
      return dependentClazz;
    } finally {
      resolutionMap.remove(qualifier);
    }
  }

  /// Gets or create this instance as Future.
  ///
  /// - `parameter`: Optional parameter to pass during the instance creation.
  ///
  /// **Note:** The `parameter` will be ignored: If the instance is already created or the constructor doesn't match with the parameter type.
  @override
  Future<BeanT> getAsyncWith<ParameterT extends Object>({
    required Object qualifier,
    ParameterT? parameter,
  }) async {
    _checkState(qualifier);

    // If resolutionMap doesn't exist in the current zone, create a new zone with a new map
    if (Zone.current[_resolutionKey] == null) {
      return runZoned(
        () => _runnerAsync<ParameterT>(
            qualifier: qualifier, parameter: parameter),
        zoneValues: {_resolutionKey: <Object>{}},
      );
    } else {
      return _runnerAsync<ParameterT>(
          qualifier: qualifier, parameter: parameter);
    }
  }

  Future<BeanT> _runnerAsync<ParameterT extends Object>({
    required Object qualifier,
    ParameterT? parameter,
  }) async {
    final resolutionMap = _getResolutionMap();

    if (resolutionMap.contains(qualifier)) {
      throw ConcurrentCreationException(qualifier.toString());
    }

    resolutionMap.add(qualifier);

    try {
      BeanT dependentClazz = await createInstanceAsync<BeanT, ParameterT>(
        builder: _builder,
        parameter: parameter,
      );

      /// Run the Interceptor for create process
      for (final interceptor in _interceptors) {
        final inter =
            (await ddi.getAsync(qualifier: interceptor)) as DDIInterceptor;

        final exec = inter.onCreate(dependentClazz);

        dependentClazz = (exec is Future ? await exec : exec) as BeanT;
      }

      assert(
        dependentClazz is! PreDispose || dependentClazz is! Future<PreDispose>,
        'Dependent instances dont support PreDispose. Use Interceptors instead.',
      );
      assert(
        dependentClazz is! PreDestroy || dependentClazz is! Future<PreDestroy>,
        'Dependent instances dont support PreDestroy. Use Interceptors instead.',
      );

      if (_decorators.isNotEmpty) {
        for (final decorator in _decorators) {
          dependentClazz = decorator(dependentClazz);
        }
      }

      /// Refresh the qualifier for the Module
      if (dependentClazz is DDIModule) {
        dependentClazz.moduleQualifier = qualifier;
      }

      if (dependentClazz is PostConstruct) {
        await dependentClazz.onPostConstruct();
      } else if (dependentClazz is Future<PostConstruct>) {
        final PostConstruct postConstruct =
            await (dependentClazz as Future<PostConstruct>);

        await postConstruct.onPostConstruct();
      }

      /// Run the Interceptors for the GET process.
      /// Must run everytime
      for (final interceptor in _interceptors) {
        final inter =
            (await ddi.getAsync(qualifier: interceptor)) as DDIInterceptor;

        final exec = inter.onGet(dependentClazz);

        dependentClazz = (exec is Future ? await exec : exec) as BeanT;
      }

      return dependentClazz;
    } finally {
      resolutionMap.remove(qualifier);
    }
  }

  /// Removes the instance of the registered class in [DDI].
  ///
  /// - `qualifier`: Optional qualifier name to distinguish between different instances of the same type.
  @override
  FutureOr<void> destroy(void Function() apply) {
    // Only destroy if canDestroy was registered with true
    if (!_canDestroy) {
      return null;
    }

    if (_state == BeanStateEnum.beingDestroyed ||
        _state == BeanStateEnum.destroyed) {
      return null;
    }

    _state = BeanStateEnum.beingDestroyed;

    return InstanceDestroyUtils.destroyInstance<BeanT>(
      apply: apply,
      instance: null,
      interceptors: _interceptors,
      children: _children,
    );
  }

  /// Disposes of the instance of the registered class in [DDI].
  @override
  Future<void> dispose() {
    if (_state == BeanStateEnum.beingDestroyed ||
        _state == BeanStateEnum.destroyed) {
      return Future.value();
    }

    if (children.isNotEmpty) {
      final List<Future<void>> futures = [];
      for (final Object child in children) {
        futures.add(ddi.dispose(qualifier: child));
      }

      return Future.wait(futures);
    }

    return Future.value();
  }

  /// Allows to dynamically add a Decorators.
  ///
  /// When using this method, consider the following:
  ///
  /// - **Order of Execution:** Decorators are applied in the order they are provided.
  /// - **Instaces Already Gets:** No changes any Instances that have been get.
  @override
  void addDecorator(ListDecorator<BeanT> newDecorators) {
    if (newDecorators.isEmpty) {
      return;
    }

    _checkState(type);

    if (_decorators.isEmpty) {
      _decorators = newDecorators;
      return;
    }

    _decorators.addAll(newDecorators);
  }

  @override
  void addInterceptor(Set<Object> newInterceptors) {
    if (newInterceptors.isEmpty) {
      return;
    }

    _checkState(type);

    if (_interceptors.isEmpty) {
      _interceptors = newInterceptors;
      return;
    }

    _interceptors.addAll(newInterceptors);
  }

  @override
  void addChildrenModules(Set<Object> child) {
    if (child.isEmpty) {
      return;
    }

    _checkState(type);

    if (_children.isEmpty) {
      _children = child;
      return;
    }

    _children.addAll(child);
  }

  void _checkState(Object qualifier) {
    if (_state == BeanStateEnum.beingDestroyed ||
        _state == BeanStateEnum.destroyed) {
      throw BeanDestroyedException(qualifier.toString());
    }
  }
}
