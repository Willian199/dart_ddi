import 'package:dart_ddi/dart_ddi.dart';
import 'package:dart_ddi/src/core/dart_ddi_qualifier.dart';

/// Implementation of [DartDDIQualifier] without using Zones.
///
/// Instead of Zone-based isolation, this version uses named contexts arranged
/// as a tree.
///
/// The active context is always the last context activated successfully.
/// Local operations remain O(1), while fallback lookups only walk through the
/// ancestor chain of the active context.
///
/// Important: because this implementation does not use `Zone`, async flows only
/// stay isolated when used linearly (for example, with `await`). Concurrent
/// async execution sharing the same qualifier instance can still interleave the
/// active context.
final class DartDDIDefaultQualifierImpl implements DartDDIQualifier {
  DartDDIDefaultQualifierImpl._({
    required _QualifierContext rootContext,
    required Map<Object, _QualifierContext> contexts,
  })  : _rootContext = rootContext,
        _contexts = contexts,
        _currentContext = rootContext;

  factory DartDDIDefaultQualifierImpl() {
    final rootContext = _QualifierContext.root();

    return DartDDIDefaultQualifierImpl._(
      rootContext: rootContext,
      contexts: <Object, _QualifierContext>{_rootQualifier: rootContext},
    );
  }

  static const Object _rootQualifier = #ddi_default_root_context;

  final _QualifierContext _rootContext;
  final Map<Object, _QualifierContext> _contexts;
  _QualifierContext _currentContext;

  @override
  ({DDIBaseFactory<BeanT> factory, Object context})?
      getFactory<BeanT extends Object>({
    required Object qualifier,
    bool fallback = true,
    Object? contextQualifier,
  }) {
    final _QualifierContext? context = _resolveContext(contextQualifier);

    if (context == null) {
      return null;
    }

    final DDIBaseFactory<Object>? explicitFactory =
        context.factories[qualifier];

    if (explicitFactory != null || !fallback) {
      if (explicitFactory == null) {
        return null;
      }
      return (
        factory: explicitFactory as DDIBaseFactory<BeanT>,
        context: context.qualifier
      );
    }

    return _findInParents<BeanT>(
      qualifier: qualifier,
      startAt: context.parent,
    );
  }

  ({DDIBaseFactory<BeanT> factory, Object context})?
      _findInParents<BeanT extends Object>({
    required Object qualifier,
    required _QualifierContext? startAt,
  }) {
    _QualifierContext? parent = startAt;

    while (parent != null) {
      final DDIBaseFactory<Object>? factory = parent.factories[qualifier];

      if (factory != null) {
        return (
          factory: factory as DDIBaseFactory<BeanT>,
          context: parent.qualifier
        );
      }

      parent = parent.parent;
    }

    return null;
  }

  @override
  void restoreContext(Object? context) {
    if (context == null) {
      _currentContext = _rootContext;
      return;
    }

    final _QualifierContext? qualifierContext = _contexts[context];

    if (qualifierContext != null) {
      _currentContext = qualifierContext;
      return;
    }

    _currentContext = _rootContext;
  }

  @override
  @pragma('vm:prefer-inline')
  Object get currentContext => _currentContext.qualifier;

  @override
  @pragma('vm:prefer-inline')
  bool get hasContext => !identical(_currentContext, _rootContext);

  @override
  BeanT runWithContext<BeanT>(Object name, BeanT Function() body) {
    final _QualifierContext previousContext = _currentContext;
    final _QualifierContext context = _activateContext(name);
    _currentContext = context;

    final BeanT result;

    try {
      result = body();
    } catch (_) {
      _currentContext = previousContext;
      rethrow;
    }

    if (result is Future<Object?>) {
      return result.catchError((Object error, StackTrace stackTrace) {
        _currentContext = previousContext;
        Error.throwWithStackTrace(error, stackTrace);
      }) as BeanT;
    }

    return result;
  }

  _QualifierContext? _resolveContext(Object? contextQualifier) {
    if (contextQualifier == _rootQualifier) {
      return _rootContext;
    }

    if (contextQualifier == null) {
      return _currentContext;
    }

    return _contexts[contextQualifier];
  }

  _QualifierContext _activateContext(Object qualifier) {
    if (qualifier == _rootQualifier) {
      return _rootContext;
    }

    return _contexts.putIfAbsent(qualifier, () {
      return _QualifierContext(
        parent: _currentContext,
        qualifier: qualifier,
      );
    });
  }

  @override
  void createContext(Object name) {
    if (hasContextQualifier(name)) {
      throw DuplicatedContextException(name.toString());
    }

    _currentContext = _activateContext(name);
  }

  @override
  @pragma('vm:prefer-inline')
  bool hasContextQualifier(Object name) => _resolveContext(name) != null;

  @override
  void freezeContext(Object name) {
    final context = _resolveContext(name);
    if (context == null) {
      throw ContextNotFoundException(name.toString());
    }

    context.isFrozen = true;
  }

  @override
  void unfreezeContext(Object name) {
    final context = _resolveContext(name);
    if (context == null) {
      return;
    }

    context.isFrozen = false;
  }

  @override
  bool isContextFrozen(Object name) => _resolveContext(name)?.isFrozen ?? false;

  @override
  Iterable<Object> contextDestroyOrder(Object name) {
    final _QualifierContext? targetContext = _contexts[name];
    if (targetContext == null) {
      return const Iterable.empty();
    }

    final List<_QualifierContext> contextsToDestroy = [
      for (final qualifierContext in _contexts.values)
        if (identical(qualifierContext, targetContext) ||
            _isDescendantOf(qualifierContext, targetContext))
          qualifierContext,
    ];

    contextsToDestroy.sort(
      (a, b) => _depthOf(b).compareTo(_depthOf(a)),
    );

    return contextsToDestroy.map((context) => context.qualifier);
  }

  @override
  bool contextHasDestroyBlockers(Object name) {
    final _QualifierContext? targetContext = _contexts[name];
    if (targetContext == null) {
      return false;
    }

    for (final qualifierContext in _contexts.values) {
      if (identical(qualifierContext, targetContext) ||
          _isDescendantOf(qualifierContext, targetContext)) {
        if (qualifierContext.hasNonDestroyableFactories) {
          return true;
        }
      }
    }

    return false;
  }

  @override
  void destroyContext(Object name) {
    if (name == _rootQualifier) {
      throw ArgumentError.value(
          name, 'name', 'Root context cannot be destroyed.');
    }

    final _QualifierContext? targetContext = _contexts[name];
    if (targetContext == null) {
      throw ContextNotFoundException(name.toString());
    }

    final Set<Object> removedQualifiers = <Object>{targetContext.qualifier};

    for (final MapEntry<Object, _QualifierContext> entry in _contexts.entries) {
      if (identical(entry.value, _rootContext) ||
          identical(entry.value, targetContext)) {
        continue;
      }

      if (_isDescendantOf(entry.value, targetContext)) {
        removedQualifiers.add(entry.key);
      }
    }

    if (removedQualifiers.contains(_currentContext.qualifier)) {
      _currentContext = targetContext.parent ?? _rootContext;
    }

    for (final qualifier in removedQualifiers) {
      _contexts.remove(qualifier);
    }
  }

  @override
  void setFactory(Object qualifier, DDIBaseFactory<Object> value,
      {Object? context}) {
    final _QualifierContext targetContext =
        _resolveContext(context) ?? _currentContext;
    targetContext.setFactory(qualifier, value);
  }

  @override
  DDIBaseFactory<Object>? removeFactory(Object? key, {Object? context}) {
    final _QualifierContext targetContext =
        context == null ? _rootContext : (_contexts[context] ?? _rootContext);

    return targetContext.removeFactory(key);
  }

  @override
  @pragma('vm:prefer-inline')
  Iterable<Object> get keys => _currentContext.factories.keys;

  @override
  @pragma('vm:prefer-inline')
  Iterable<MapEntry<Object, DDIBaseFactory<Object>>> entries(
      {Object? context}) {
    return _resolveContext(context)?.factories.entries ??
        const Iterable.empty();
  }

  @override
  @pragma('vm:prefer-inline')
  bool get isEmpty => _currentContext.factories.isEmpty;

  @override
  @pragma('vm:prefer-inline')
  int get length => _currentContext.factories.length;

  bool _isDescendantOf(
      _QualifierContext candidate, _QualifierContext ancestor) {
    _QualifierContext? current = candidate.parent;

    while (current != null) {
      if (identical(current, ancestor)) {
        return true;
      }
      current = current.parent;
    }

    return false;
  }

  int _depthOf(_QualifierContext context) {
    int depth = 0;
    _QualifierContext? current = context.parent;

    while (current != null) {
      depth++;
      current = current.parent;
    }

    return depth;
  }
}

final class _QualifierContext {
  _QualifierContext({required this.parent, required this.qualifier})
      : factories = <Object, DDIBaseFactory<Object>>{};

  _QualifierContext.root()
      : parent = null,
        qualifier = DartDDIDefaultQualifierImpl._rootQualifier,
        factories = <Object, DDIBaseFactory<Object>>{};

  final _QualifierContext? parent;
  final Object qualifier;
  final Map<Object, DDIBaseFactory<Object>> factories;
  bool _hasNonDestroyableFactories = false;
  bool isFrozen = false;

  bool get hasNonDestroyableFactories => _hasNonDestroyableFactories;

  void setFactory(Object key, DDIBaseFactory<Object> value) {
    final existing = factories[key];
    factories[key] = value;

    if (!value.canDestroy) {
      _hasNonDestroyableFactories = true;
      return;
    }

    // Recalculate only when replacing a previous non-destroyable entry.
    if (existing != null &&
        !existing.canDestroy &&
        _hasNonDestroyableFactories) {
      _hasNonDestroyableFactories =
          factories.values.any((factory) => !factory.canDestroy);
    }
  }

  DDIBaseFactory<Object>? removeFactory(Object? key) {
    final removed = factories.remove(key);
    if (factories.isEmpty) {
      _hasNonDestroyableFactories = false;
      return removed;
    }

    // Recalculate only when a non-destroyable factory was removed.
    if (removed != null && !removed.canDestroy && _hasNonDestroyableFactories) {
      _hasNonDestroyableFactories =
          factories.values.any((factory) => !factory.canDestroy);
    }
    return removed;
  }
}
