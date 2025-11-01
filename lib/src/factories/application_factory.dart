import 'dart:async';

import 'package:dart_ddi/dart_ddi.dart';
import 'package:dart_ddi/src/exception/bean_destroyed.dart';
import 'package:dart_ddi/src/exception/concurrent_creation.dart';
import 'package:dart_ddi/src/exception/future_not_accept.dart';
import 'package:dart_ddi/src/typedef/typedef.dart';
import 'package:dart_ddi/src/utils/instance_destroy_utils.dart';

/// Create an instance when first used and reuses it for all subsequent requests during the application's execution.
///
/// This scope defines its behavior on the [getWith] or [getAsyncWith] methods.
///
/// First, it will verify if the instance is ready and return it. If not, it will do:
/// * Create the instance.
/// * Run the Interceptor for create process.
/// * Apply all Decorators to the instance.
/// * Refresh the qualifier for the Module.
/// * Make the instance ready.
/// * Run the PostConstruct for the instance.
/// * Run the Interceptor for get process.
///
/// `Note`: `PreDispose` and `PreDestroy` mixins will only be called if the instance is in use. Use `Interceptor` if you want to call them regardless.
class ApplicationFactory<BeanT extends Object> extends DDIScopeFactory<BeanT> {
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

  /// The current _state of this factory in its lifecycle.
  BeanStateEnum _state = BeanStateEnum.none;

  bool _runningCreateProcess = false;
  Completer<void> _created = Completer();

  // Prevents Circular Dependency Injection during Instance Creation
  static const _resolutionKey = #_resolutionKey;

  static Set<Object> _getResolutionMap() {
    return Zone.current[_resolutionKey] as Set<Object>? ?? {};
  }

  @override
  BeanStateEnum get state => _state;

  /// Register the instance in [DDI].
  /// When the instance is ready, must call apply function.
  @override
  Future<void> register({required Object qualifier}) async {
    _state = BeanStateEnum.registered;
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
    _checkState(type);

    if (!isReady) {
      if (isFuture) {
        throw const FutureNotAcceptException();
      }

      if (_runningCreateProcess) {
        throw ConcurrentCreationException(qualifier.toString());
      }

      _state = BeanStateEnum.beingCreated;
      _runningCreateProcess = true;

      // If resolutionMap doesn't exist in the current zone, create a new zone with a new map
      if (Zone.current[_resolutionKey] == null) {
        runZoned(
          () => _runner<ParameterT>(qualifier: qualifier, parameter: parameter),
          zoneValues: {_resolutionKey: <Object>{}},
        );
      } else {
        _runner<ParameterT>(qualifier: qualifier, parameter: parameter);
      }
    }

    // Run the Interceptors for the GET process.
    // Must run everytime
    if (_interceptors.isNotEmpty) {
      for (final interceptor in _interceptors) {
        _instance = ddi
            .get<DDIInterceptor>(qualifier: interceptor)
            .onGet(_instance!) as BeanT;
      }
    }

    return _instance!;
  }

  void _runner<ParameterT extends Object>({
    required Object qualifier,
    ParameterT? parameter,
  }) {
    final resolutionMap = _getResolutionMap();

    if (resolutionMap.contains(qualifier)) {
      throw ConcurrentCreationException(qualifier.toString());
    }

    resolutionMap.add(qualifier);

    try {
      BeanT ins = createInstance<BeanT, ParameterT>(
        builder: _builder,
        parameter: parameter,
      );

      if (_interceptors.isNotEmpty) {
        for (final interceptor in _interceptors) {
          ins = ddi.get<DDIInterceptor>(qualifier: interceptor).onCreate(ins)
              as BeanT;
        }
      }

      if (_decorators.isNotEmpty) {
        for (final decorator in _decorators) {
          ins = decorator(ins);
        }
      }

      _instance = ins;

      if (_instance is DDIModule) {
        (_instance as DDIModule).moduleQualifier = qualifier;
      }

      if (_instance is PostConstruct) {
        (_instance as PostConstruct).onPostConstruct();
      } else if (_instance is Future<PostConstruct>) {
        (_instance as Future<PostConstruct>).then(
          (PostConstruct postConstruct) => postConstruct.onPostConstruct(),
        );
      }

      _state = BeanStateEnum.created;
      _created.complete();
    } catch (e) {
      if (!_created.isCompleted) {
        _created.complete();
      }

      // Reset the instance to null in case of error on creation
      // When the instance is null, the next getWith will try to create again
      _instance = null;
      if (state != BeanStateEnum.beingDestroyed &&
          state != BeanStateEnum.destroyed) {
        _state = BeanStateEnum.registered;
        _created = Completer();
      }
      rethrow;
    } finally {
      _runningCreateProcess = false;
      resolutionMap.remove(qualifier);
    }
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
    _checkState(type);

    if (isReady) {
      // Instance is already ready, proceed to interceptor phase
      return _runGetInterceptors();
    }

    if (_runningCreateProcess) {
      final resolutionMap = _getResolutionMap();

      if (resolutionMap.contains(qualifier)) {
        throw ConcurrentCreationException(qualifier.toString());
      }

      // Wait for any ongoing creation process to complete
      await _created.future;
      // After waiting, check if instance is ready
      if (isReady) {
        // Instance was created by another process, proceed to interceptor phase
        return _runGetInterceptors();
      }
    }

    // If resolutionMap doesn't exist in the current zone, create a new zone with a new map
    if (Zone.current[_resolutionKey] == null) {
      return runZoned(
        () => _runnerAsync<ParameterT>(
            qualifier: qualifier, parameter: parameter),
        zoneValues: {_resolutionKey: <Object>{}},
      );
    }

    return _runnerAsync<ParameterT>(qualifier: qualifier, parameter: parameter);
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

    // We are the first process, start creation
    try {
      _state = BeanStateEnum.beingCreated;
      _runningCreateProcess = true;

      /// Create the Instance class
      final execInstance = createInstanceAsync<BeanT, ParameterT>(
        builder: _builder,
        parameter: parameter,
      );

      /// Verify if the Instance class is Future, and await for it
      BeanT instance =
          execInstance is Future ? await execInstance : execInstance;

      // Double-check: another process might have completed creation
      if (_created.isCompleted) {
        // Another process completed creation, use that instance
        if (isReady) {
          _runningCreateProcess = false;
          return _runGetInterceptors();
        } else {
          throw StateError(
            'Another process completed creation but instance is not ready',
          );
        }
      }

      /// Run the Interceptor for create process
      for (final interceptor in _interceptors) {
        final ins =
            (await ddi.getAsync(qualifier: interceptor)) as DDIInterceptor;

        final exec = ins.onCreate(instance);

        instance = (exec is Future ? await exec : exec) as BeanT;
      }

      /// Apply all Decorators to the instance
      if (_decorators.isNotEmpty) {
        for (final decorator in _decorators) {
          instance = decorator(instance);
        }
      }

      _instance = instance;

      /// Refresh the qualifier for the Module
      if (_instance is DDIModule) {
        (_instance as DDIModule).moduleQualifier = qualifier;
      }

      _state = BeanStateEnum.created;
      _created.complete();

      if (_instance is PostConstruct) {
        await (_instance as PostConstruct).onPostConstruct();
      } else if (_instance is Future<PostConstruct>) {
        final PostConstruct postConstruct =
            await (_instance as Future<PostConstruct>);

        await postConstruct.onPostConstruct();
      }

      return _runGetInterceptors();
    } catch (e) {
      if (!_created.isCompleted) {
        _created.complete();
      }

      // Reset the instance to null in case of error on creation
      // When the instance is null, the next getAsyncWith will try to create again
      _instance = null;
      if (state != BeanStateEnum.beingDestroyed &&
          state != BeanStateEnum.destroyed) {
        _state = BeanStateEnum.registered;
        _created = Completer();
      }
      rethrow;
    } finally {
      _runningCreateProcess = false;
      resolutionMap.remove(qualifier);
    }
  }

  /// Runs the interceptors for the GET process.
  /// This method is extracted to avoid code duplication.
  Future<BeanT> _runGetInterceptors() async {
    if (_interceptors.isEmpty) {
      return _instance!;
    }

    /// Run the Interceptors for the GET process.
    /// Must run everytime
    for (final interceptor in _interceptors) {
      final exec = (await ddi.getAsync<DDIInterceptor>(qualifier: interceptor))
          .onGet(_instance!);

      _instance = (exec is Future ? await exec : exec) as BeanT;
    }

    return _instance!;
  }

  /// Verify if this factory is a Future.
  @override
  bool get isFuture => _builder.isFuture || BeanT is Future;

  /// Verify if this factory is ready (Created).
  @override
  bool get isReady =>
      _instance != null &&
      _created.isCompleted &&
      _state == BeanStateEnum.created;

  @override
  bool get isRegistered => [
        BeanStateEnum.registered,
        BeanStateEnum.created,
        BeanStateEnum.beingCreated,
        BeanStateEnum.beingDisposed,
        BeanStateEnum.disposed,
      ].contains(_state);

  /// Removes this instance of the registered class in [DDI].
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

    if (_canDestroy && _runningCreateProcess && !_created.isCompleted) {
      _created.complete();
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
  Future<void> dispose() async {
    if (_state == BeanStateEnum.beingDestroyed ||
        _state == BeanStateEnum.destroyed ||
        _state == BeanStateEnum.beingDisposed ||
        _state == BeanStateEnum.disposed) {
      return;
    }

    _state = BeanStateEnum.beingDisposed;

    // Wait for any ongoing creation process to complete
    if (_runningCreateProcess) {
      try {
        await _created.future;
      } catch (e) {
        // Ignore errors from creation process during dispose
        // The creation process might have failed, which is fine during dispose
      }
    }

    // Ensure completer is properly handled
    if (!_created.isCompleted) {
      _created.complete();
    }

    // Run interceptors for dispose
    for (final interceptor in _interceptors) {
      if (ddi.isFuture(qualifier: interceptor)) {
        final instance =
            (await ddi.getAsync(qualifier: interceptor)) as DDIInterceptor;

        final exec = instance.onDispose(_instance);
        if (exec is Future) {
          await exec;
        }
      } else {
        final instance = ddi.get(qualifier: interceptor) as DDIInterceptor;

        instance.onDispose(_instance);
      }
    }

    // Handle PreDispose lifecycle
    if (_instance case final clazz? when clazz is PreDispose) {
      return _runFutureOrPreDispose(clazz);
    }

    // Handle DDIModule cleanup
    if (_instance is DDIModule && _children.isNotEmpty) {
      await _disposeChildrenAsync();
      _instance = null;
      _state = BeanStateEnum.disposed;
      _created = Completer();
      _runningCreateProcess = false;
    } else {
      final disposed = _disposeChildrenAsync();
      _instance = null;
      _state = BeanStateEnum.disposed;
      _created = Completer();
      _runningCreateProcess = false;

      return disposed;
    }
  }

  Future<void> _runFutureOrPreDispose(PreDispose clazz) async {
    await clazz.onPreDispose();

    await _disposeChildrenAsync();

    _instance = null;
    _state = BeanStateEnum.disposed;
    _created = Completer();
    _runningCreateProcess = false;
    return Future.value();
  }

  Future<void> _disposeChildrenAsync() async {
    if (_children.isEmpty) {
      return;
    }

    final List<Future<void>> futures = [
      for (final Object child in _children) ddi.dispose(qualifier: child),
    ];

    return Future.wait(futures).ignore();
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

    if (isReady) {
      if (newDecorators.isNotEmpty) {
        for (final decorator in newDecorators) {
          _instance = decorator(_instance!);
        }
      }
    }

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

  @override
  Set<Object> get children => _children;

  void _checkState(Object qualifier) {
    if (_state == BeanStateEnum.beingDestroyed ||
        _state == BeanStateEnum.destroyed) {
      throw BeanDestroyedException(qualifier.toString());
    }
  }
}
