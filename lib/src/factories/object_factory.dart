import 'dart:async';

import 'package:dart_ddi/dart_ddi.dart';
import 'package:dart_ddi/src/exception/bean_not_ready.dart';
import 'package:dart_ddi/src/exception/bean_timeout.dart';
import 'package:dart_ddi/src/exception/factory_already_created.dart';
import 'package:dart_ddi/src/typedef/typedef.dart';
import 'package:dart_ddi/src/utils/instance_destroy_utils.dart';
import 'package:dart_ddi/src/utils/intance_decorators_utils.dart';

///  Create an unique instance during registration and reuses it in all subsequent requests.
///
/// This Scopes defines is behavior on the [register] methods.
/// * It will create the instance.
/// * Run the Interceptor for create process.
/// * Apply all Decorators to the instance.
/// * Refresh the qualifier for the Module.
/// * Make the instance ready.
/// * Run the PostConstruct for the instance.
///
/// `Note`:
/// * `Interceptor.onDipose` and `PreDispose` mixin are not supported. You can just destroy the instance.
/// * If you call dispose, only the Application or Session childrens will be disposed.
class ObjectFactory<BeanT extends Object> extends DDIBaseFactory<BeanT> {
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

  final Completer<void> _created = Completer<void>();

  /// Register the instance in [DDI].
  /// When the instance is ready, must call apply function.
  @override
  Future<void> register({
    required Object qualifier,
    required void Function(DDIBaseFactory<BeanT>) apply,
  }) async {
    if (_created.isCompleted) {
      throw FactoryAlreadyCreatedException(BeanT.toString());
    }

    try {
      apply(this);

      state = BeanStateEnum.beingRegistered;

      for (final interceptor in _interceptors) {
        if (ddi.isFuture(qualifier: interceptor)) {
          final inter = await ddi.getAsync(qualifier: interceptor) as DDIInterceptor;

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

      _instance = InstanceDecoratorsUtils.executarDecorators<BeanT>(_instance, _decorators);

      if (_instance is DDIModule) {
        (_instance as DDIModule).moduleQualifier = qualifier;
      }

      state = BeanStateEnum.registered;
      _created.complete();

      if (_instance is PostConstruct) {
        return (_instance as PostConstruct).onPostConstruct();
      } else if (_instance is Future<PostConstruct>) {
        final PostConstruct postConstruct = await (_instance as Future<PostConstruct>);

        return postConstruct.onPostConstruct();
      }
    } catch (e) {
      _created.complete();
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
    if (!isReady) {
      // Await for 20 seconds to the instance to be created
      await _created.future.timeout(
        const Duration(seconds: 20),
        onTimeout: () {
          throw BeanTimeoutException(qualifier.toString());
        },
      );
    }

    if (_interceptors.isNotEmpty) {
      for (final interceptor in _interceptors) {
        final ins = (await ddi.getAsync(qualifier: interceptor)) as DDIInterceptor;

        final exec = ins.onGet(_instance);

        _instance = (exec is Future ? await exec : exec) as BeanT;
      }
    }

    return _instance;
  }

  /// Verify if this factory is a Future.
  @override
  bool get isFuture => BeanT is Future;

  /// Verify if this factory is ready.
  @override
  bool get isReady => _created.isCompleted;

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

    _instance = InstanceDecoratorsUtils.executarDecorators<BeanT>(_instance, newDecorators);
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
