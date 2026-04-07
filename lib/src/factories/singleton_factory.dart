import 'dart:async';

import 'package:dart_ddi/dart_ddi.dart';
import 'package:dart_ddi/src/typedef/typedef.dart';
import 'package:dart_ddi/src/utils/interceptor_resolver.dart';
import 'package:dart_ddi/src/utils/instance_destroy_utils.dart';

/// Creates a unique instance during registration and reuses it in all subsequent requests.
///
/// This scope defines its behavior on the [register] methods.
/// * It will create the instance during registration
/// * Run the Interceptor for create process.
/// * Apply all Decorators to the instance.
/// * Refresh the qualifier for the Module.
/// * Make the instance ready.
/// * Run the PostConstruct for the instance.
///
/// `Note`:
/// * `Interceptor.onDispose` and `PreDispose` mixin are not supported. You can just destroy the instance.
/// * If you call dispose, only the Application children will be disposed.
class SingletonFactory<BeanT extends Object> extends DDIScopeFactory<BeanT> {
  SingletonFactory({
    required CustomBuilder<FutureOr<BeanT>> builder,
    bool canDestroy = true,
    ListDecorator<BeanT> decorators = const [],
    Set<Object> interceptors = const {},
    Set<Object> children = const {},
    super.selector,
    Set<Object>? requires,
  })  : _builder = builder,
        _canDestroy = canDestroy,
        _decorators = decorators,
        _interceptors = interceptors,
        _children = children,
        _requires = requires;

  /// The instance of the Bean created by the factory.
  BeanT? _instance;

  /// The factory builder responsible for creating the Bean.
  final CustomBuilder<FutureOr<BeanT>> _builder;

  /// A list of decorators that are applied during the Bean creation process.
  final ListDecorator<BeanT> _decorators;

  /// A list of interceptors that are called at various stages of the Bean usage.
  Set<Object> _interceptors;

  /// A flag that indicates whether the Bean can be destroyed after its usage.
  final bool _canDestroy;

  /// The child objects associated with the Bean, acting as a module.
  Set<Object> _children;

  /// requires qualifiers or types that must be registered before creating an instance.
  final Set<Object>? _requires;

  /// Flag to track if dependencies have been validated.
  bool _dependenciesValidated = false;

  /// The current _state of this factory in its lifecycle.
  BeanStateEnum _state = BeanStateEnum.none;

  final Completer<void> _created = Completer<void>();

  @override
  @pragma('vm:prefer-inline')
  BeanStateEnum get state => _state;

  /// Register the instance in [DDI].
  /// When the instance is ready, must call apply function.
  @override
  Future<void> register({
    required Object qualifier,
    required DDI ddiInstance,
  }) async {
    if (_created.isCompleted) {
      throw FactoryAlreadyCreatedException(BeanT.toString());
    }

    _checkState(type);

    try {
      if (!_dependenciesValidated &&
          _requires != null &&
          _requires.isNotEmpty) {
        for (final dep in _requires) {
          if (!ddiInstance.isRegistered(qualifier: dep)) {
            throw MissingDependenciesException(
              'Required dependency "${dep.toString()}" is not registered',
            );
          }

          if (!ddiInstance.isReady(qualifier: dep)) {
            if (ddiInstance.isFuture(qualifier: dep)) {
              await ddiInstance.getAsyncWith(qualifier: dep);
            } else {
              ddiInstance.getWith(qualifier: dep);
            }
          }
        }
        _dependenciesValidated = true;
      }

      _state = BeanStateEnum.beingCreated;

      final FutureOr<BeanT> execInstance = createInstance(
        builder: _builder,
        ddiInstance: ddiInstance,
      );

      BeanT clazz = /*builder!.isFuture &&*/
          execInstance is Future ? await execInstance : execInstance;

      if (_interceptors.isNotEmpty) {
        for (final interceptor in _interceptors) {
          final resolved = InterceptorResolver.resolveAsync(
            ddiInstance: ddiInstance,
            qualifier: interceptor,
          );
          final DDIInterceptor inter =
              resolved is Future ? await resolved : resolved;

          final newInstance = inter.onCreate(clazz);
          if (newInstance is Future) {
            clazz = (await newInstance) as BeanT;
          } else {
            clazz = newInstance as BeanT;
          }
        }
      }

      if (_decorators.isNotEmpty) {
        for (final decorator in _decorators) {
          clazz = decorator(clazz);
        }

        // Clean the decorators list after applying
        _decorators.clear();
      }

      if (clazz is DDIModule) {
        (clazz as DDIModule).moduleQualifier = qualifier;

        final Object? moduleContext = clazz.contextQualifier;
        if (moduleContext != null &&
            !ddiInstance.contextExists(moduleContext)) {
          ddiInstance.createContext(moduleContext);
        }
      }

      _instance = clazz;

      final FutureOr<void> result;

      if (clazz is PostConstruct) {
        result = clazz.onPostConstruct();
      } else if (clazz is Future<PostConstruct>) {
        result = (clazz as Future<PostConstruct>).then(
          (value) => value.onPostConstruct(),
        );
      } else {
        result = Future.value();
      }

      _state = BeanStateEnum.created;

      _created.complete();

      return result;
    } catch (e) {
      _state = BeanStateEnum.none;
      if (!_created.isCompleted) {
        _created.complete();
      }
      rethrow;
    }
  }

  /// Gets or creates this instance.
  ///
  /// - `qualifier`: Qualifier name to identify the object.
  /// - `parameter`: Optional parameter to pass during the instance creation.
  ///
  /// **Note:** The `parameter` will be ignored: If the instance is already created or the constructor doesn't match with the parameter type.
  @override
  BeanT getWith<ParameterT extends Object>({
    required Object qualifier,
    required DDI ddiInstance,
    ParameterT? parameter,
  }) {
    _checkState(type);

    if (!isReady) {
      throw BeanNotReadyException(qualifier.toString());
    }

    if (_interceptors.isNotEmpty) {
      for (final interceptor in _interceptors) {
        final inter = InterceptorResolver.resolveSync(
          ddiInstance: ddiInstance,
          qualifier: interceptor,
        );
        final current = _instance!;
        final next = inter.onGet(current) as BeanT;
        if (!identical(current, next)) {
          _instance = next;
        }
      }
    }
    return _instance!;
  }

  /// Gets or create this instance as Future.
  ///
  /// - `qualifier`: Qualifier name to identify the object.
  /// - `parameter`: Optional parameter to pass during the instance creation.
  ///
  /// **Note:** The `parameter` will be ignored: If the instance is already created or the constructor doesn't match with the parameter type.
  @override
  Future<BeanT> getAsyncWith<ParameterT extends Object>({
    required Object qualifier,
    required DDI ddiInstance,
    ParameterT? parameter,
  }) async {
    _checkState(type);

    if (!isReady) {
      await _created.future;
    }

    if (_instance == null) {
      throw BeanNotReadyException(qualifier.toString());
    }

    if (_interceptors.isNotEmpty) {
      for (final interceptor in _interceptors) {
        final ins = await InterceptorResolver.resolveAsync(
          ddiInstance: ddiInstance,
          qualifier: interceptor,
        );

        final current = _instance!;
        final exec = ins.onGet(current);
        final next = (exec is Future ? await exec : exec) as BeanT;
        if (!identical(current, next)) {
          _instance = next;
        }
      }
    }

    return _instance!;
  }

  /// Verify if this factory is a Future.
  @override
  @pragma('vm:prefer-inline')
  bool get isFuture => _builder.isFuture || BeanT is Future;

  /// Verify if this factory is ready (Created).
  @override
  @pragma('vm:prefer-inline')
  bool get isReady =>
      _instance != null &&
      _created.isCompleted &&
      _state == BeanStateEnum.created;

  static const _registeredState = {
    BeanStateEnum.registered,
    BeanStateEnum.created,
    BeanStateEnum.beingCreated,
  };

  @override
  @pragma('vm:prefer-inline')
  bool get isRegistered => _registeredState.contains(_state);

  @override
  @pragma('vm:prefer-inline')
  bool get canDestroy => _canDestroy;

  /// Removes this instance from [DDI].
  @override
  FutureOr<void> destroy({
    required void Function() apply,
    required DDI ddiInstance,
  }) {
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
      instance: _instance,
      interceptors: _interceptors,
      children: _children,
      ddiInstance: ddiInstance,
    );
  }

  /// Disposes of the instance of the registered class in [DDI].
  @override
  Future<void> dispose({required DDI ddiInstance}) {
    if (_state == BeanStateEnum.beingDestroyed ||
        _state == BeanStateEnum.destroyed) {
      return Future.value();
    }

    final Object? context = _instance is DDIModule
        ? (_instance as DDIModule).contextQualifier
        : null;

    final localChildren = children;
    if (localChildren.isNotEmpty) {
      final List<Future<void>> futures = [
        for (final Object child in localChildren)
          ddiInstance.dispose(qualifier: child, context: context)
      ];

      return Future.wait(futures).then((_) => _destroyContextIfExists(
            ddiInstance: ddiInstance,
            context: context,
          ));
    }

    return _destroyContextIfExists(ddiInstance: ddiInstance, context: context);
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

    if (!isReady) {
      throw BeanNotReadyException(BeanT.toString());
    }

    if (newDecorators.isNotEmpty) {
      for (final decorator in newDecorators) {
        _instance = decorator(_instance!);
      }
    }
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

  @override
  @pragma('vm:prefer-inline')
  Set<Object> get children => _children;

  Future<void> _destroyContextIfExists({
    required DDI ddiInstance,
    required Object? context,
  }) async {
    if (context == null || !ddiInstance.contextExists(context)) {
      return;
    }

    final destroyResult = ddiInstance.destroyContext(context);
    if (destroyResult is Future) {
      await destroyResult;
    }
  }

  void _checkState(Object qualifier) {
    if (_state == BeanStateEnum.beingDestroyed ||
        _state == BeanStateEnum.destroyed) {
      throw BeanDestroyedException(qualifier.toString());
    }
  }
}
