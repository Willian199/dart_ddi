import 'dart:async';

import 'package:dart_ddi/dart_ddi.dart';
import 'package:dart_ddi/src/exception/bean_destroyed.dart';
import 'package:dart_ddi/src/exception/bean_not_ready.dart';
import 'package:dart_ddi/src/exception/factory_already_created.dart';
import 'package:dart_ddi/src/typedef/typedef.dart';
import 'package:dart_ddi/src/utils/instance_destroy_utils.dart';

/// Creates a unique instance during registration and reuses it in all subsequent requests.
///
/// This scope defines its behavior on the [register] methods.
/// * It will process the provided instance during registration.
/// * Run the Interceptor for create process.
/// * Apply all Decorators to the instance.
/// * Refresh the qualifier for the Module.
/// * Make the instance ready.
/// * Run the PostConstruct for the instance.
///
/// `Note`:
/// * `Interceptor.onDispose` and `PreDispose` mixin are not supported. You can just destroy the instance.
/// * If you call dispose, only the Application children will be disposed.
class ObjectFactory<BeanT extends Object> extends DDIScopeFactory<BeanT> {
  ObjectFactory({
    required BeanT instance,
    bool canDestroy = true,
    ListDecorator<BeanT> decorators = const [],
    Set<Object> interceptors = const {},
    Set<Object> children = const {},
    super.selector,
  })  : _instance = instance,
        _canDestroy = canDestroy,
        _decorators = decorators,
        _interceptors = interceptors,
        _children = children;

  /// The instance of the Bean created by the factory.
  BeanT _instance;

  /// A list of decorators that are applied during the Bean creation process.
  final ListDecorator<BeanT> _decorators;

  /// A list of interceptors that are called at various stages of the Bean usage.
  Set<Object> _interceptors;

  /// A flag that indicates whether the Bean can be destroyed after its usage.
  final bool _canDestroy;

  /// The child objects associated with the Bean, acting as a module.
  Set<Object> _children;

  /// The current _state of this factory in its lifecycle.
  BeanStateEnum _state = BeanStateEnum.none;

  final Completer<void> _created = Completer<void>();

  @override
  BeanStateEnum get state => _state;

  /// Register the instance in [DDI].
  /// When the instance is ready, must call apply function.
  @override
  Future<void> register({required Object qualifier}) async {
    if (_created.isCompleted) {
      throw FactoryAlreadyCreatedException(BeanT.toString());
    }

    try {
      _state = BeanStateEnum.beingCreated;
      if (_interceptors.isNotEmpty) {
        for (final interceptor in _interceptors) {
          if (ddi.isFuture(qualifier: interceptor)) {
            final inter =
                await ddi.getAsync(qualifier: interceptor) as DDIInterceptor;

            _instance = (await inter.onCreate(_instance)) as BeanT;
          } else {
            final inter = ddi.get(qualifier: interceptor) as DDIInterceptor;

            final newInstance = inter.onCreate(_instance);
            if (newInstance is Future) {
              _instance = (await newInstance) as BeanT;
            } else {
              _instance = newInstance as BeanT;
            }
          }
        }
      }

      if (_decorators.isNotEmpty) {
        for (final decorator in _decorators) {
          _instance = decorator(_instance);
        }

        // Free memory
        _decorators.clear();
      }

      if (_instance is DDIModule) {
        (_instance as DDIModule).moduleQualifier = qualifier;
      }

      final FutureOr<void> result;
      if (_instance is PostConstruct) {
        result = (_instance as PostConstruct).onPostConstruct();
      } else if (_instance is Future<PostConstruct>) {
        result = (_instance as Future<PostConstruct>).then(
          (postConstruct) => postConstruct.onPostConstruct(),
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
    ParameterT? parameter,
  }) {
    _checkState(qualifier);

    if (!isReady) {
      throw BeanNotReadyException(qualifier.toString());
    }

    if (_interceptors.isNotEmpty) {
      for (final interceptor in _interceptors) {
        final ins = ddi.get(qualifier: interceptor) as DDIInterceptor;

        _instance = ins.onGet(_instance) as BeanT;
      }
    }
    return _instance;
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
    ParameterT? parameter,
  }) async {
    _checkState(qualifier);

    if (!isReady) {
      await _created.future;
    }

    if (_interceptors.isNotEmpty) {
      for (final interceptor in _interceptors) {
        final ins =
            (await ddi.getAsync(qualifier: interceptor)) as DDIInterceptor;

        final exec = ins.onGet(_instance);

        _instance = (exec is Future ? await exec : exec) as BeanT;
      }
    }

    return _instance;
  }

  /// Verify if this factory is a Future.
  @override
  bool get isFuture => BeanT is Future;

  /// Verify if this factory is ready (Created).
  @override
  bool get isReady => _created.isCompleted && _state == BeanStateEnum.created;

  @override
  bool get isRegistered => [
        BeanStateEnum.registered,
        BeanStateEnum.created,
        BeanStateEnum.beingCreated,
      ].contains(_state);

  /// Removes this instance from [DDI].
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
      instance: _instance,
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
      final List<Future<void>> futures = [
        for (final Object child in children) ddi.dispose(qualifier: child)
      ];

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

    if (!isReady) {
      throw BeanNotReadyException(BeanT.toString());
    }

    if (newDecorators.isNotEmpty) {
      for (final decorator in newDecorators) {
        _instance = decorator(_instance);
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
  Set<Object> get children => _children;

  void _checkState(Object qualifier) {
    if (_state == BeanStateEnum.beingDestroyed ||
        _state == BeanStateEnum.destroyed) {
      throw BeanDestroyedException(qualifier.toString());
    }
  }
}
