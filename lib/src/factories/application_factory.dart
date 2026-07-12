import 'dart:async';

import 'package:dart_ddi/dart_ddi.dart';
import 'package:dart_ddi/src/typedef/typedef.dart';
import 'package:dart_ddi/src/utils/dependency_validator.dart';
import 'package:dart_ddi/src/utils/interceptor_result_validator.dart';
import 'package:dart_ddi/src/utils/interceptor_resolver.dart';
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
    bool useWeakReference = false,
    Set<Object>? requires,
  })  : _builder = builder,
        _canDestroy = canDestroy,
        _decorators = List.of(decorators),
        _interceptors = Set.of(interceptors),
        _children = Set.of(children),
        _useWeakReference = useWeakReference,
        _requires = requires == null ? null : Set.of(requires);

  /// The instance of the Bean created by the factory.
  BeanT? _instance;

  /// Whether to use weak reference for the instance.
  final bool _useWeakReference;

  /// Weak reference to the instance (used when _useWeakReference is true).
  WeakReference<BeanT>? _weakInstance;

  /// Last context created for a module instance.
  ///
  /// `dispose()` clears the instance so it can be recreated later, but a later
  /// `destroy()` still needs this context to remove contextual children and the
  /// context registry itself.
  Object? _moduleContext;

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

  /// Required qualifiers or types that must be registered before creating an instance.
  final Set<Object>? _requires;

  /// The current _state of this factory in its lifecycle.
  BeanStateEnum _state = BeanStateEnum.none;

  bool _runningCreateProcess = false;
  Completer<void> _created = Completer();
  Future<BeanT>? _activeAsyncCreation;
  Completer<void>? _disposeCompleter;

  // Prevents Circular Dependency Injection during Instance Creation
  static const _resolutionKey = #_resolutionKey;

  static Set<Object> _getResolutionMap() {
    return Zone.current[_resolutionKey] as Set<Object>? ?? {};
  }

  @override
  @pragma('vm:prefer-inline')
  BeanStateEnum get state => _state;

  /// Register the instance in [DDI].
  /// When the instance is ready, must call apply function.
  @override
  @pragma('vm:prefer-inline')
  Future<void> register({
    required Object qualifier,
    required DDI ddiInstance,
  }) async {
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
    required DDI ddiInstance,
    ParameterT? parameter,
  }) {
    _checkState(type);

    // Hot path for ApplicationScope in steady state:
    // strong reference enabled, already created, and no creation flow needed.
    if (!_useWeakReference &&
        _instance != null &&
        _created.isCompleted &&
        _state == BeanStateEnum.created) {
      if (_interceptors.isEmpty) {
        return _instance!;
      }

      BeanT current = _instance!;

      for (final interceptor in _interceptors) {
        final inter = InterceptorResolver.resolveSync(
          ddiInstance: ddiInstance,
          qualifier: interceptor,
        );
        current = InterceptorResultValidator.ensureCompatible<BeanT>(
          value: inter.onGet(current),
          interceptor: interceptor,
          lifecycle: 'onGet',
        );
      }

      if (!identical(_instance, current)) {
        _instance = current;
      }
      return current;
    }

    // Check if instance was garbage collected (weak reference)
    if (_useWeakReference && isReady) {
      final weakInst = _weakInstance?.target;
      if (weakInst == null) {
        // Instance was garbage collected, reset state to allow re-creation
        _weakInstance = null;
        _instance = null;
        _state = BeanStateEnum.registered;
        _created = Completer();
        _runningCreateProcess = false;
        // Continue with normal creation flow
      }
    }

    if (!isReady) {
      if (_requires != null && _requires.isNotEmpty) {
        DependencyValidator.validateDependencies(
          requires: _requires,
          ddiInstance: ddiInstance,
        );
      }

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
          () => _runner<ParameterT>(
            qualifier: qualifier,
            parameter: parameter,
            ddiInstance: ddiInstance,
          ),
          zoneValues: {_resolutionKey: <Object>{}},
        );
      } else {
        _runner<ParameterT>(
          qualifier: qualifier,
          parameter: parameter,
          ddiInstance: ddiInstance,
        );
      }
    }

    // Run the Interceptors for the GET process.
    // Must run everytime
    BeanT? instanceToReturn;
    if (_useWeakReference) {
      // Get instance from weak reference if enabled
      // Note: We already checked at the beginning of the method, so this should not be null
      instanceToReturn = _weakInstance?.target;
      // If null here, it means GC occurred between checks - this should not happen
      // The initial check should have caught it and recreate the instance
      if (instanceToReturn == null) {
        // Instance was garbage collected between checks, reset state
        _weakInstance = null;
        _instance = null;
        _state = BeanStateEnum.registered;
        _created = Completer();
        _runningCreateProcess = false;
        // Throw specific exception - the state is reset, so the next call will recreate
        throw WeakReferenceCollectedException(type.toString());
      }
    } else {
      instanceToReturn = _instance;
    }

    if (_interceptors.isNotEmpty) {
      for (final interceptor in _interceptors) {
        final inter = InterceptorResolver.resolveSync(
          ddiInstance: ddiInstance,
          qualifier: interceptor,
        );
        instanceToReturn = InterceptorResultValidator.ensureCompatible<BeanT>(
          value: inter.onGet(instanceToReturn!),
          interceptor: interceptor,
          lifecycle: 'onGet',
        );
      }
    }

    // Update storage based on weak reference setting
    if (_useWeakReference && instanceToReturn != null) {
      _weakInstance = WeakReference(instanceToReturn);
      _instance = null; // Ensure _instance is null when using weak reference
    } else if (!_useWeakReference && instanceToReturn != null) {
      if (!identical(_instance, instanceToReturn)) {
        _instance = instanceToReturn;
      }
      // Ensure _weakInstance is null when not using weak reference
      _weakInstance = null;
    }

    return instanceToReturn!;
  }

  void _runner<ParameterT extends Object>({
    required Object qualifier,
    required DDI ddiInstance,
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
        ddiInstance: ddiInstance,
      );

      if (_interceptors.isNotEmpty) {
        for (final interceptor in _interceptors) {
          final inter = InterceptorResolver.resolveSync(
            ddiInstance: ddiInstance,
            qualifier: interceptor,
          );
          ins = InterceptorResultValidator.ensureCompatible<BeanT>(
            value: inter.onCreate(ins),
            interceptor: interceptor,
            lifecycle: 'onCreate',
          );
        }
      }

      if (_decorators.isNotEmpty) {
        for (final decorator in _decorators) {
          ins = decorator(ins);
        }
      }

      // Store instance based on weak reference setting
      if (_useWeakReference) {
        _weakInstance = WeakReference(ins);
        _instance = null; // Ensure _instance is null when using weak reference
      } else {
        _instance = ins;
        _weakInstance =
            null; // Ensure _weakInstance is null when not using weak reference
      }

      if (ins is DDIModule) {
        (ins as DDIModule).moduleQualifier = qualifier;

        final Object? moduleContext = ins.contextQualifier;
        _captureModuleContext(moduleContext);
        if (moduleContext != null &&
            !ddiInstance.contextExists(moduleContext)) {
          ddiInstance.createContext(moduleContext);
        }
      } else {
        _captureModuleContext(null);
      }

      if (ins is PostConstruct) {
        (ins as PostConstruct).onPostConstruct();
      } else if (ins is Future<PostConstruct>) {
        (ins as Future<PostConstruct>).then(
          (PostConstruct postConstruct) => postConstruct.onPostConstruct(),
        );
      }

      _state = BeanStateEnum.created;
      if (!_created.isCompleted) {
        _created.complete();
      }
    } catch (e) {
      if (!_created.isCompleted) {
        _created.complete();
      }

      // Reset the instance to null in case of error on creation
      // When the instance is null, the next getWith will try to create again
      _instance = null;
      _weakInstance = null;
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
    required DDI ddiInstance,
    ParameterT? parameter,
  }) async {
    _checkState(type);
    final initialDispose = _disposeCompleter?.future;
    if (initialDispose != null) {
      await _waitForDispose(initialDispose);
    }

    // Check if instance was garbage collected (weak reference)
    if (_useWeakReference && isReady) {
      final weakInst = _weakInstance?.target;
      if (weakInst == null) {
        // Instance was garbage collected, reset state to allow re-creation
        _weakInstance = null;
        _instance = null;
        _state = BeanStateEnum.registered;
        _created = Completer();
        _runningCreateProcess = false;
        // Continue with normal creation flow
      }
    }

    if (isReady) {
      // Instance is already ready, proceed to interceptor phase
      try {
        final inst = await _runGetInterceptors(ddiInstance: ddiInstance);
        return inst;
      } on WeakReferenceCollectedException {
        // Instance was garbage collected, reset state and continue with creation
        _weakInstance = null;
        _instance = null;
        _state = BeanStateEnum.registered;
        _created = Completer();
        _runningCreateProcess = false;
        // Continue with normal creation flow below
      }
    }

    if (_runningCreateProcess) {
      final resolutionMap = _getResolutionMap();

      if (resolutionMap.contains(qualifier)) {
        throw ConcurrentCreationException(qualifier.toString());
      }

      // Wait for the entire creation lifecycle, including PostConstruct.
      final activeCreation = _activeAsyncCreation;
      BeanT? completedCreation;
      if (activeCreation != null) {
        completedCreation = await activeCreation;
      } else {
        await _created.future;
      }

      final disposeAfterCreation = _disposeCompleter?.future;
      if (disposeAfterCreation != null) {
        await _waitForDispose(disposeAfterCreation);
      } else if (isReady) {
        // Instance was created by another process, proceed to interceptor phase
        try {
          final instance = await _runGetInterceptors(ddiInstance: ddiInstance);
          return instance;
        } on WeakReferenceCollectedException {
          // Instance was garbage collected, reset state and continue with creation
          _weakInstance = null;
          _instance = null;
          _state = BeanStateEnum.registered;
          _created = Completer();
          _runningCreateProcess = false;
          // Continue with normal creation flow below
        }
      } else if (completedCreation != null) {
        // A concurrent caller may destroy the factory immediately after its
        // own resolution completes. Existing waiters still receive the
        // instance produced by that shared creation.
        return completedCreation;
      }
    }

    if (_requires != null && _requires.isNotEmpty) {
      final validation = DependencyValidator.validateDependenciesAsync(
        requires: _requires,
        ddiInstance: ddiInstance,
      );

      if (validation is Future) {
        await validation;
      }
    }

    final disposeBeforeCreation = _disposeCompleter?.future;
    if (disposeBeforeCreation != null) {
      await _waitForDispose(disposeBeforeCreation);
    }

    // If resolutionMap doesn't exist in the current zone, create a new zone with a new map
    final Future<BeanT> creation;
    if (Zone.current[_resolutionKey] == null) {
      creation = runZoned(
        () => _runnerAsync<ParameterT>(
          qualifier: qualifier,
          parameter: parameter,
          ddiInstance: ddiInstance,
        ),
        zoneValues: {_resolutionKey: <Object>{}},
      );
    } else {
      creation = _runnerAsync<ParameterT>(
        qualifier: qualifier,
        parameter: parameter,
        ddiInstance: ddiInstance,
      );
    }

    return _trackAsyncCreation(creation);
  }

  Future<void> _waitForDispose(Future<void> pendingDispose) async {
    try {
      await pendingDispose;
    } catch (_) {
      // Disposal errors are delivered to the dispose caller. Resolution only
      // needs to wait until the lifecycle operation reaches a terminal state.
    }
  }

  Future<BeanT> _trackAsyncCreation(Future<BeanT> creation) {
    _activeAsyncCreation = creation;
    creation.then<void>(
      (_) => _clearTrackedCreation(creation),
      onError: (Object _, StackTrace __) => _clearTrackedCreation(creation),
    );
    return creation;
  }

  void _clearTrackedCreation(Future<BeanT> creation) {
    if (identical(_activeAsyncCreation, creation)) {
      _activeAsyncCreation = null;
    }
  }

  Future<BeanT> _runnerAsync<ParameterT extends Object>({
    required Object qualifier,
    required DDI ddiInstance,
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
        ddiInstance: ddiInstance,
      );

      /// Verify if the Instance class is Future, and await for it
      BeanT instance =
          execInstance is Future ? await execInstance : execInstance;

      // Double-check: another process might have completed creation
      if (_created.isCompleted) {
        // Another process completed creation, use that instance
        if (isReady) {
          _runningCreateProcess = false;
          return _runGetInterceptors(ddiInstance: ddiInstance);
        } else {
          throw StateError(
            'Another process completed creation but instance is not ready',
          );
        }
      }

      /// Run the Interceptor for create process
      for (final interceptor in _interceptors) {
        final ins = await InterceptorResolver.resolveAsync(
          ddiInstance: ddiInstance,
          qualifier: interceptor,
        );

        final exec = ins.onCreate(instance);
        final result = exec is Future ? await exec : exec;
        instance = InterceptorResultValidator.ensureCompatible<BeanT>(
          value: result,
          interceptor: interceptor,
          lifecycle: 'onCreate',
        );
      }

      /// Apply all Decorators to the instance
      if (_decorators.isNotEmpty) {
        for (final decorator in _decorators) {
          instance = decorator(instance);
        }
      }

      // Store instance based on weak reference setting
      if (_useWeakReference) {
        _weakInstance = WeakReference(instance);
        _instance = null; // Ensure _instance is null when using weak reference
      } else {
        _instance = instance;
        // Ensure _weakInstance is null when not using weak reference
        _weakInstance = null;
      }

      /// Refresh the qualifier for the Module
      if (instance is DDIModule) {
        (instance as DDIModule).moduleQualifier = qualifier;

        final Object? moduleContext = instance.contextQualifier;
        _captureModuleContext(moduleContext);
        if (moduleContext != null &&
            !ddiInstance.contextExists(moduleContext)) {
          ddiInstance.createContext(moduleContext);
        }
      } else {
        _captureModuleContext(null);
      }

      _state = BeanStateEnum.created;
      if (!_created.isCompleted) {
        _created.complete();
      }

      final instanceForPostConstruct =
          _useWeakReference ? _weakInstance?.target : _instance;

      if (instanceForPostConstruct is PostConstruct) {
        await (instanceForPostConstruct as PostConstruct).onPostConstruct();
      } else if (instanceForPostConstruct is Future<PostConstruct>) {
        final PostConstruct postConstruct =
            await (instanceForPostConstruct as Future<PostConstruct>);

        await postConstruct.onPostConstruct();
      }

      final inst = await _runGetInterceptors(ddiInstance: ddiInstance);
      return inst;
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
  Future<BeanT> _runGetInterceptors({required DDI ddiInstance}) async {
    BeanT? instanceToProcess;
    if (_useWeakReference) {
      // Get instance from weak reference if enabled
      instanceToProcess = _weakInstance?.target;
      if (instanceToProcess == null) {
        // Instance was garbage collected, reset state to allow re-creation
        _weakInstance = null;
        _instance = null;
        _state = BeanStateEnum.registered;
        _created = Completer();
        _runningCreateProcess = false;
        // Throw specific exception to signal that instance needs to be re-created
        throw WeakReferenceCollectedException(type.toString());
      }
    } else {
      instanceToProcess = _instance;
    }

    if (_interceptors.isEmpty) {
      return instanceToProcess!;
    }

    /// Run the Interceptors for the GET process.
    /// Must run everytime
    for (final interceptor in _interceptors) {
      final inter = await InterceptorResolver.resolveAsync(
        ddiInstance: ddiInstance,
        qualifier: interceptor,
      );
      final exec = inter.onGet(instanceToProcess!);
      final result = exec is Future ? await exec : exec;
      instanceToProcess = InterceptorResultValidator.ensureCompatible<BeanT>(
        value: result,
        interceptor: interceptor,
        lifecycle: 'onGet',
      );
    }

    // Update storage based on weak reference setting
    if (_useWeakReference && instanceToProcess != null) {
      _weakInstance = WeakReference(instanceToProcess);
      _instance = null; // Ensure _instance is null when using weak reference
    } else if (!_useWeakReference && instanceToProcess != null) {
      if (!identical(_instance, instanceToProcess)) {
        _instance = instanceToProcess;
      }
      // Ensure _weakInstance is null when not using weak reference
      _weakInstance = null;
    }

    return instanceToProcess!;
  }

  /// Verify if this factory is a Future.
  @override
  @pragma('vm:prefer-inline')
  bool get isFuture => _builder.isFuture || BeanT is Future;

  /// Verify if this factory is ready (Created).
  @override
  bool get isReady {
    if (_useWeakReference) {
      // Check weak reference if enabled
      final weakInst = _weakInstance?.target;
      return weakInst != null &&
          _created.isCompleted &&
          _state == BeanStateEnum.created;
    }

    // Check strong reference if not using weak reference
    return _instance != null &&
        _created.isCompleted &&
        _state == BeanStateEnum.created;
  }

  static const _registeredStates = {
    BeanStateEnum.registered,
    BeanStateEnum.created,
    BeanStateEnum.beingCreated,
    BeanStateEnum.beingDisposed,
    BeanStateEnum.disposed,
  };

  @override
  @pragma('vm:prefer-inline')
  bool get isRegistered => _registeredStates.contains(_state);

  @override
  @pragma('vm:prefer-inline')
  bool get canDestroy => _canDestroy;

  /// Removes this instance of the registered class in [DDI].
  @override
  FutureOr<void> destroy(
      {required void Function() apply, required DDI ddiInstance}) {
    // Only destroy if canDestroy was registered with true
    if (!_canDestroy) {
      return null;
    }

    if (_state == BeanStateEnum.beingDestroyed ||
        _state == BeanStateEnum.destroyed) {
      return null;
    }

    final previousState = _state;

    if (_canDestroy && _runningCreateProcess && !_created.isCompleted) {
      _created.complete();
    }

    _state = BeanStateEnum.beingDestroyed;

    final BeanT? instanceForDestroy =
        _instance ?? (_useWeakReference ? _weakInstance?.target : null);

    final result = InstanceDestroyUtils.destroyInstance<BeanT>(
      apply: apply,
      instance: instanceForDestroy,
      interceptors: _interceptors,
      children: _children,
      ddiInstance: ddiInstance,
      moduleContext: _moduleContext,
    );

    if (result == null) {
      return null;
    }

    return result.onError((Object error, StackTrace stackTrace) {
      _state = previousState;
      Error.throwWithStackTrace(error, stackTrace);
    });
  }

  /// Disposes of the instance of the registered class in [DDI].
  @override
  Future<void> dispose({required DDI ddiInstance}) {
    if (_state == BeanStateEnum.beingDestroyed ||
        _state == BeanStateEnum.destroyed) {
      return Future.value();
    }

    final pendingDispose = _disposeCompleter;
    if (pendingDispose != null) {
      return pendingDispose.future;
    }

    final completer = Completer<void>();
    _disposeCompleter = completer;

    _runDispose(ddiInstance: ddiInstance).then<void>(
      (_) {
        if (identical(_disposeCompleter, completer)) {
          _disposeCompleter = null;
        }
        completer.complete();
      },
      onError: (Object error, StackTrace stackTrace) {
        if (identical(_disposeCompleter, completer)) {
          _disposeCompleter = null;
        }
        completer.completeError(error, stackTrace);
      },
    );

    return completer.future;
  }

  Future<void> _runDispose({required DDI ddiInstance}) async {
    final activeCreation = _activeAsyncCreation;
    if (activeCreation != null) {
      try {
        await activeCreation;
      } catch (_) {
        // A failed creation restores the factory to registered state. Dispose
        // can then complete normally without an instance.
      }
    } else if (_runningCreateProcess) {
      try {
        await _created.future;
      } catch (_) {
        // Keep the same recovery behavior for non-tracked creation flows.
      }
    }

    final previousState = _state;
    final previousInstance = _instance;
    final previousWeakInstance = _weakInstance;
    final previousCreated = _created;
    final previousRunningCreateProcess = _runningCreateProcess;

    _state = BeanStateEnum.beingDisposed;

    try {
      final BeanT? instanceForDispose =
          _instance ?? (_useWeakReference ? _weakInstance?.target : null);

      // Run interceptors for dispose
      for (final interceptor in _interceptors) {
        final resolved = InterceptorResolver.resolveAsync(
          ddiInstance: ddiInstance,
          qualifier: interceptor,
        );
        final DDIInterceptor instance =
            resolved is Future ? await resolved : resolved;

        final exec = instance.onDispose(instanceForDispose);
        if (exec is Future) {
          await exec;
        }
      }

      // Handle PreDispose lifecycle
      if (instanceForDispose case final clazz? when clazz is PreDispose) {
        await _runFutureOrPreDispose(clazz: clazz, ddiInstance: ddiInstance);
        return;
      }

      final Object? moduleContext = instanceForDispose is DDIModule
          ? (instanceForDispose as DDIModule).contextQualifier
          : _moduleContext;
      // Preserve behavior for callers that do not await dispose():
      // clear local state before awaiting async cleanup.
      _instance = null;
      _weakInstance = null;
      _state = BeanStateEnum.disposed;
      _created = Completer();
      _runningCreateProcess = false;

      await _disposeChildrenAsync(
        ddiInstance: ddiInstance,
        context: moduleContext,
      );
    } catch (error, stackTrace) {
      _state = previousState;
      _instance = previousInstance;
      _weakInstance = previousWeakInstance;
      _created = previousCreated;
      _runningCreateProcess = previousRunningCreateProcess;
      Error.throwWithStackTrace(error, stackTrace);
    }
  }

  Future<void> _runFutureOrPreDispose({
    required PreDispose clazz,
    required DDI ddiInstance,
  }) async {
    await clazz.onPreDispose();

    final Object? context =
        clazz is DDIModule ? (clazz as DDIModule).contextQualifier : null;
    await _disposeChildrenAsync(ddiInstance: ddiInstance, context: context);

    _instance = null;
    _weakInstance = null;
    _state = BeanStateEnum.disposed;
    _created = Completer();
    _runningCreateProcess = false;
    return Future.value();
  }

  Future<void> _disposeChildrenAsync({
    required DDI ddiInstance,
    required Object? context,
  }) async {
    if (_children.isEmpty) {
      return;
    }

    final List<Future<void>> futures = [
      for (final Object child in _children)
        ddiInstance.dispose(qualifier: child, context: context),
    ];

    return Future.wait(futures).ignore();
  }

  void _captureModuleContext(Object? nextContext) {
    final previousContext = _moduleContext;
    if (previousContext != null && previousContext != nextContext) {
      throw ModuleContextChangedException(
        previousContext: previousContext,
        nextContext: nextContext,
      );
    }

    _moduleContext = nextContext;
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
      BeanT? decoratedInstance =
          _instance ?? (_useWeakReference ? _weakInstance?.target : null);

      if (decoratedInstance != null) {
        for (final decorator in newDecorators) {
          decoratedInstance = decorator(decoratedInstance!);
        }

        if (_useWeakReference) {
          _weakInstance = WeakReference(decoratedInstance!);
          _instance = null;
        } else {
          _instance = decoratedInstance;
        }
      } else if (_useWeakReference) {
        _weakInstance = null;
        _instance = null;
        _state = BeanStateEnum.registered;
        _created = Completer();
        _runningCreateProcess = false;
      }
    }

    if (_decorators.isEmpty) {
      _decorators = List.of(newDecorators);
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
      _interceptors = Set.of(newInterceptors);
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
      _children = Set.of(child);
      return;
    }

    _children.addAll(child);
  }

  @override
  @pragma('vm:prefer-inline')
  Set<Object> get children => _children;

  void _checkState(Object qualifier) {
    if (_state == BeanStateEnum.beingDestroyed ||
        _state == BeanStateEnum.destroyed) {
      throw BeanDestroyedException(qualifier.toString());
    }
  }
}
