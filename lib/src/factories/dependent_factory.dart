import 'dart:async';

import 'package:dart_ddi/dart_ddi.dart';
import 'package:dart_ddi/src/typedef/typedef.dart';
import 'package:dart_ddi/src/utils/instance_destroy_utils.dart';
import 'package:dart_ddi/src/utils/intance_decorators_utils.dart';

/// Create a new instance every time it is requested.
///
/// This Scopes defines is behavior on the [getWith] or [getAsyncWith] methods.
///
/// It will do:
/// * Create the instance.
/// * Run the Interceptor for create process.
/// * Apply all Decorators to the instance.
/// * Run the PostConstruct for the instance.
/// * Run the Interceptor for get process.
///
/// `Note`: `PreDispose` and `PreDestroy` mixins will only be called if the instance is in use. Use `Interceptor` if you want to call them regardless.
class DependentFactory<BeanT extends Object> extends DDIBaseFactory<BeanT> {
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

  /// Register the instance in [DDI].
  /// When the instance is ready, must call apply function.
  @override
  Future<void> register(void Function(DDIBaseFactory<BeanT>) apply) async {
    return apply(this);
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
    BeanT dependentClazz = createInstance<BeanT, ParameterT>(
      builder: _builder,
      parameter: parameter,
    );

    for (final interceptor in _interceptors) {
      final inter = ddi.get(qualifier: interceptor) as DDIInterceptor;

      dependentClazz = inter.onCreate(dependentClazz) as BeanT;
    }

    assert(dependentClazz is! PreDispose || dependentClazz is! Future<PreDispose>,
        'Dependent instances dont support PreDispose. Use Interceptors instead.');
    assert(dependentClazz is! PreDestroy || dependentClazz is! Future<PreDestroy>,
        'Dependent instances dont support PreDestroy. Use Interceptors instead.');

    dependentClazz = InstanceDecoratorsUtils.executarDecorators<BeanT>(dependentClazz, _decorators);

    if (dependentClazz is DDIModule) {
      dependentClazz.moduleQualifier = qualifier;
    }

    if (dependentClazz is PostConstruct) {
      dependentClazz.onPostConstruct();
    } else if (dependentClazz is Future<PostConstruct>) {
      dependentClazz.then((PostConstruct postConstruct) => postConstruct.onPostConstruct());
    }

    /// Run the Interceptors for the GET process.
    /// Must run everytime
    for (final interceptor in _interceptors) {
      final inter = ddi.get(qualifier: interceptor) as DDIInterceptor;

      dependentClazz = inter.onGet(dependentClazz) as BeanT;
    }

    return dependentClazz;
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
    BeanT dependentClazz = await createInstanceAsync<BeanT, ParameterT>(
      builder: _builder,
      parameter: parameter,
    );

    /// Run the Interceptor for create process
    for (final interceptor in _interceptors) {
      final inter = (await ddi.getAsync(qualifier: interceptor)) as DDIInterceptor;

      final exec = inter.onCreate(dependentClazz);

      dependentClazz = (exec is Future ? await exec : exec) as BeanT;
    }

    assert(dependentClazz is! PreDispose || dependentClazz is! Future<PreDispose>,
        'Dependent instances dont support PreDispose. Use Interceptors instead.');
    assert(dependentClazz is! PreDestroy || dependentClazz is! Future<PreDestroy>,
        'Dependent instances dont support PreDestroy. Use Interceptors instead.');

    /// Apply all Decorators to the instance
    dependentClazz = InstanceDecoratorsUtils.executarDecorators<BeanT>(dependentClazz, _decorators);

    /// Refresh the qualifier for the Module
    if (dependentClazz is DDIModule) {
      dependentClazz.moduleQualifier = qualifier;
    }

    if (dependentClazz is PostConstruct) {
      await dependentClazz.onPostConstruct();
    } else if (dependentClazz is Future<PostConstruct>) {
      final PostConstruct postConstruct = await (dependentClazz as Future<PostConstruct>);

      await postConstruct.onPostConstruct();
    }

    /// Run the Interceptors for the GET process.
    /// Must run everytime
    for (final interceptor in _interceptors) {
      final inter = (await ddi.getAsync(qualifier: interceptor)) as DDIInterceptor;

      final exec = inter.onGet(dependentClazz);

      dependentClazz = (exec is Future ? await exec : exec) as BeanT;
    }

    return dependentClazz;
  }

  /// Verify if this factory is a Future.
  @override
  bool get isFuture => _builder.isFuture || BeanT is Future;

  /// Verify if this factory is ready.
  @override
  bool get isReady => false;

  /// Removes the instance of the registered class in [DDI].
  ///
  /// - `qualifier`: Optional qualifier name to distinguish between different instances of the same type.
  @override
  FutureOr<void> destroy(void Function() apply) {
    return InstanceDestroyUtils.destroyInstance<BeanT>(
        apply: apply, canDestroy: _canDestroy, instance: null, interceptors: _interceptors, children: _children);
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
  FutureOr<void> addDecorator(ListDecorator<BeanT> newDecorators) {
    _decorators = [..._decorators, ...newDecorators];
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
