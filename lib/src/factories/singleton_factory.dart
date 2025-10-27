import 'dart:async';

import 'package:dart_ddi/dart_ddi.dart';
import 'package:dart_ddi/src/exception/bean_not_ready.dart';
import 'package:dart_ddi/src/exception/factory_already_created.dart';
import 'package:dart_ddi/src/typedef/typedef.dart';
import 'package:dart_ddi/src/utils/instance_destroy_utils.dart';
import 'package:dart_ddi/src/utils/instance_decorators_utils.dart';

///  Creates a unique instance during registration and reuses it in all subsequent requests.
///
/// This scope defines its behavior on the [register] methods.
/// * It will create the instance.
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
  })  : _builder = builder,
        _canDestroy = canDestroy,
        _decorators = decorators,
        _interceptors = interceptors,
        _children = children;

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

  final Completer<void> _created = Completer<void>();

  /// Register the instance in [DDI].
  /// When the instance is ready, must call apply function.
  @override
  Future<void> register({required Object qualifier}) async {
    if (_created.isCompleted) {
      throw FactoryAlreadyCreatedException(BeanT.toString());
    }

    try {
      state = BeanStateEnum.beingCreated;

      final FutureOr<BeanT> execInstance = createInstance(builder: _builder);

      BeanT clazz = /*builder!.isFuture &&*/
          execInstance is Future ? await execInstance : execInstance;

      for (final interceptor in _interceptors) {
        if (ddi.isFuture(qualifier: interceptor)) {
          final inter =
              await ddi.getAsync(qualifier: interceptor) as DDIInterceptor;

          clazz = (await inter.onCreate(clazz)) as BeanT;
        } else {
          final inter = ddi.get(qualifier: interceptor) as DDIInterceptor;

          final newInstance = inter.onCreate(clazz);
          if (newInstance is Future) {
            clazz = (await newInstance) as BeanT;
          } else {
            clazz = newInstance as BeanT;
          }
        }
      }

      clazz =
          InstanceDecoratorsUtils.executeDecorators<BeanT>(clazz, _decorators);

      if (clazz is DDIModule) {
        (clazz as DDIModule).moduleQualifier = qualifier;
      }

      _instance = clazz;

      final FutureOr<void> result;

      if (clazz is PostConstruct) {
        result = clazz.onPostConstruct();
      } else if (clazz is Future<PostConstruct>) {
        result = (clazz as Future<PostConstruct>)
            .then((value) => value.onPostConstruct());
      } else {
        result = Future.value();
      }

      state = BeanStateEnum.created;

      _created.complete();

      return result;
    } catch (e) {
      state = BeanStateEnum.none;
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
    if (!isReady) {
      throw BeanNotReadyException(qualifier.toString());
    }

    if (_interceptors.isNotEmpty) {
      for (final interceptor in _interceptors) {
        final ins = ddi.get(qualifier: interceptor) as DDIInterceptor;

        _instance = ins.onGet(_instance!) as BeanT;
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
    ParameterT? parameter,
  }) async {
    if (!isReady) {
      await _created.future;
    }

    if (_instance != null) {
      if (_interceptors.isNotEmpty) {
        for (final interceptor in _interceptors) {
          final ins =
              (await ddi.getAsync(qualifier: interceptor)) as DDIInterceptor;

          final exec = ins.onGet(_instance!);

          _instance = (exec is Future ? await exec : exec) as BeanT;
        }
      }

      return _instance!;
    }

    throw BeanNotReadyException(qualifier.toString());
  }

  /// Verify if this factory is a Future.
  @override
  bool get isFuture => _builder.isFuture || BeanT is Future;

  /// Verify if this factory is ready.
  @override
  bool get isReady => _instance != null && _created.isCompleted;

  /// Removes this instance from [DDI].
  @override
  FutureOr<void> destroy(void Function() apply) {
    state = BeanStateEnum.beingDestroyed;
    return InstanceDestroyUtils.destroyInstance<BeanT>(
      apply: apply,
      canDestroy: _canDestroy,
      instance: _instance,
      interceptors: _interceptors,
      children: _children,
    );
  }

  /// Disposes of the instance of the registered class in [DDI].
  @override
  Future<void> dispose() {
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
    if (!isReady) {
      throw BeanNotReadyException(BeanT.toString());
    }

    _instance = InstanceDecoratorsUtils.executeDecorators<BeanT>(
        _instance!, newDecorators);
  }

  @override
  void addInterceptor(Set<Object> newInterceptors) {
    _interceptors = {..._interceptors, ...newInterceptors};
  }

  @override
  void addChildrenModules(Set<Object> child) {
    _children = {..._children, ...child};
  }

  @override
  Set<Object> get children => _children;
}
