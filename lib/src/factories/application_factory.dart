import 'dart:async';

import 'package:dart_ddi/dart_ddi.dart';
import 'package:dart_ddi/src/exception/future_not_accept.dart';
import 'package:dart_ddi/src/typedef/typedef.dart';
import 'package:dart_ddi/src/utils/instance_destroy_utils.dart';
import 'package:dart_ddi/src/utils/intance_decorators_utils.dart';

/// Create an instance when first used and reuses it for all subsequent requests during the application's execution.
///
/// This Scopes defines is behavior on the [getWith] or [getAsyncWith] methods.
///
/// First will verify if the instance is ready and return it. If not, it will do:
/// * Create the instance.
/// * Run the Interceptor for create process.
/// * Apply all Decorators to the instance.
/// * Refresh the qualifier for the Module.
/// * Make the instance ready.
/// * Run the PostConstruct for the instance.
///
/// `Note`: `PreDispose` and `PreDestroy` mixins will only be called if the instance is in use. Use `Interceptor` if you want to call them regardless.

class ApplicationFactory<BeanT extends Object> extends DDIBaseFactory<BeanT> {
  ApplicationFactory({
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
  ListDecorator<BeanT> _decorators;

  /// A list of interceptors that are called at various stages of the Bean usage.
  Set<Object> _interceptors;

  /// A flag that indicates whether the Bean can be destroyed after its usage.
  final bool _canDestroy;

  /// The child objects associated with the Bean, acting as a module.
  Set<Object> _children;

  bool _runningCreateProcess = false;
  Completer<void> _created = Completer<void>();

  /// Register the instance in [DDI].
  /// When the instance is ready, must call apply function.
  @override
  Future<void> register(void Function(DDIBaseFactory) apply) async {
    return apply(this);
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
      if (isFuture || _runningCreateProcess) {
        throw const FutureNotAcceptException();
      }

      _runningCreateProcess = true;

      try {
        _instance = createInstance<BeanT, ParameterT>(
          builder: _builder,
          parameter: parameter,
        );

        for (final interceptor in _interceptors) {
          final ins = ddi.get(qualifier: interceptor) as DDIInterceptor;

          _instance = ins.onCreate(_instance!) as BeanT;
        }

        _instance = InstanceDecoratorsUtils.executarDecorators<BeanT>(_instance!, _decorators);

        if (_instance is DDIModule) {
          (_instance as DDIModule).moduleQualifier = qualifier;
        }

        _created.complete();
        _runningCreateProcess = false;
        if (_instance is PostConstruct) {
          (_instance as PostConstruct).onPostConstruct();
        } else if (_instance is Future<PostConstruct>) {
          (_instance as Future<PostConstruct>).then((PostConstruct postConstruct) => postConstruct.onPostConstruct());
        }
      } catch (e) {
        _created.complete();
        rethrow;
      }
    }

    /// Run the Interceptors for the GET process.
    /// Must run everytime
    for (final interceptor in _interceptors) {
      final ins = ddi.get(qualifier: interceptor) as DDIInterceptor;

      _instance = ins.onGet(_instance!) as BeanT;
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
    if (_runningCreateProcess) {
      await _created.future;
    }

    if (!isReady) {
      try {
        _runningCreateProcess = true;

        /// Create the Instance class
        final execInstance = createInstanceAsync<BeanT, ParameterT>(
          builder: _builder,
          parameter: parameter,
        );

        /// Verify if the Instance class is Future, and await for it
        _instance = execInstance is Future ? await execInstance : execInstance;

        /// Run the Interceptor for create process

        for (final interceptor in _interceptors) {
          final ins = (await ddi.getAsync(qualifier: interceptor)) as DDIInterceptor;

          final exec = ins.onCreate(_instance!);

          _instance = (exec is Future ? await exec : exec) as BeanT;
        }

        /// Apply all Decorators to the instance
        _instance = InstanceDecoratorsUtils.executarDecorators<BeanT>(_instance!, _decorators);

        /// Refresh the qualifier for the Module
        if (_instance is DDIModule) {
          (_instance as DDIModule).moduleQualifier = qualifier;
        }

        _runningCreateProcess = false;

        if (_instance is PostConstruct) {
          await (_instance as PostConstruct).onPostConstruct();
        } else if (_instance is Future<PostConstruct>) {
          final PostConstruct postConstruct = await (_instance as Future<PostConstruct>);

          await postConstruct.onPostConstruct();
        }

        _created.complete();
      } catch (e) {
        _created.complete();
        rethrow;
      }
    }

    /// Run the Interceptors for the GET process.
    /// Must run everytime
    for (final interceptor in _interceptors) {
      final ins = (await ddi.getAsync(qualifier: interceptor)) as DDIInterceptor;

      final exec = ins.onGet(_instance!);

      _instance = (exec is Future ? await exec : exec) as BeanT;
    }

    return _instance!;
  }

  /// Verify if this factory is a Future.
  @override
  bool get isFuture => _builder.isFuture || BeanT is Future;

  /// Verify if this factory is ready.
  @override
  bool get isReady => _instance != null && _created.isCompleted;

  /// Removes the instance of the registered class in [DDI].
  ///
  /// - `qualifier`: Optional qualifier name to distinguish between different instances of the same type.
  @override
  FutureOr<void> destroy(void Function() apply) {
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
  Future<void> dispose() async {
    if (!_created.isCompleted) {
      _created.complete();
    }
    _created = Completer<void>();

    for (final interceptor in _interceptors) {
      if (ddi.isFuture(qualifier: interceptor)) {
        final instance = (await ddi.getAsync(qualifier: interceptor)) as DDIInterceptor;

        final exec = instance.onDispose(instance);
        if (exec is Future) {
          await exec;
        }
      } else {
        final instance = ddi.get(qualifier: interceptor) as DDIInterceptor;

        instance.onDispose(instance);
      }
    }

    if (_instance case final clazz? when clazz is PreDispose) {
      return _runFutureOrPreDispose(clazz);
    }

    if (_instance is DDIModule && (_children.isNotEmpty)) {
      await disposeChildrenAsync();
      _instance = null;
    } else {
      final disposed = disposeChildrenAsync();
      _instance = null;

      return disposed;
    }
  }

  Future<void> _runFutureOrPreDispose(PreDispose clazz) async {
    await clazz.onPreDispose();

    await disposeChildrenAsync();

    _instance = null;

    return Future.value();
  }

  Future<void> disposeChildrenAsync() async {
    if (_children.isNotEmpty) {
      final List<Future<void>> futures = [];
      for (final Object child in _children) {
        futures.add(ddi.dispose(qualifier: child));
      }

      return Future.wait(futures).ignore();
    }
  }

  /// Allows to dynamically add a Decorators.
  ///
  /// When using this method, consider the following:
  ///
  /// - **Order of Execution:** Decorators are applied in the order they are provided.
  /// - **Instaces Already Gets:** No changes any Instances that have been get.
  @override
  FutureOr<void> addDecorator(ListDecorator<BeanT> newDecorators) {
    if (isReady) {
      _instance = InstanceDecoratorsUtils.executarDecorators<BeanT>(_instance!, newDecorators);
    }

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
