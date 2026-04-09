import 'package:dart_ddi/dart_ddi.dart';
import 'package:dart_ddi/src/data/ddi_context_models.dart';
import 'package:meta/meta.dart';

/// Default [DDIStrategy] backed by a context tree.
///
/// Resolution is optimized for read-heavy scenarios by combining:
/// 1) local O(1) lookup (primary and alias)
/// 2) parent-chain fallback lookup
final class DDIDefaultStrategy implements DDIStrategy {
  DDIDefaultStrategy._({
    required QualifierContext rootContext,
    required Map<Object, QualifierContext> contexts,
  })  : _rootContext = rootContext,
        _contexts = contexts,
        _currentContext = rootContext;

  factory DDIDefaultStrategy() {
    final rootContext = QualifierContext.root(rootQualifier: _rootQualifier);
    return DDIDefaultStrategy._(
      rootContext: rootContext,
      contexts: <Object, QualifierContext>{_rootQualifier: rootContext},
    );
  }

  static const Object _rootQualifier = #ddi_default_root_context;

  final QualifierContext _rootContext;
  final Map<Object, QualifierContext> _contexts;
  QualifierContext _currentContext;

  QualifierContext? _resolveContext(Object? contextQualifier) {
    if (contextQualifier == _rootQualifier) {
      return _rootContext;
    }
    if (contextQualifier == null) {
      return _currentContext;
    }
    return _contexts[contextQualifier];
  }

  @override
  Object get currentContext => _currentContext.qualifier;

  @override
  bool get hasContext => !identical(_currentContext, _rootContext);

  @override
  bool hasContextQualifier(Object name) => _resolveContext(name) != null;

  @override
  void createContext(Object name) {
    if (hasContextQualifier(name)) {
      throw DuplicatedContextException(name.toString());
    }
    _currentContext = _activateContext(name);
  }

  QualifierContext _activateContext(Object qualifier) {
    if (qualifier == _rootQualifier) {
      return _rootContext;
    }

    final existing = _contexts[qualifier];
    if (existing != null) {
      return existing;
    }

    final created = QualifierContext(
      parent: _currentContext,
      qualifier: qualifier,
      depth: _currentContext.depth + 1,
    );
    _currentContext.children.add(created);
    _contexts[qualifier] = created;
    return created;
  }

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
    _resolveContext(name)?.isFrozen = false;
  }

  @override
  bool isContextFrozen(Object name) => _resolveContext(name)?.isFrozen ?? false;

  @override
  Iterable<Object> contextDestroyOrder(Object name) {
    final target = _contexts[name];
    if (target == null) {
      return const Iterable.empty();
    }

    final order = <Object>[];
    final stack = <({bool visited, QualifierContext node})>[
      (visited: false, node: target)
    ];

    while (stack.isNotEmpty) {
      final current = stack.removeLast();
      if (current.visited) {
        order.add(current.node.qualifier);
        continue;
      }

      stack.add((visited: true, node: current.node));
      for (final child in current.node.children) {
        stack.add((visited: false, node: child));
      }
    }

    return order;
  }

  @override
  bool contextHasDestroyBlockers(Object name) {
    final target = _contexts[name];
    if (target == null) {
      return false;
    }

    final stack = <QualifierContext>[target];
    while (stack.isNotEmpty) {
      final current = stack.removeLast();
      if (current.hasNonDestroyableEntries) {
        return true;
      }
      stack.addAll(current.children);
    }

    return false;
  }

  @override
  void destroyContext(Object name) {
    if (name == _rootQualifier) {
      throw ArgumentError.value(
        name,
        'name',
        'Root context cannot be destroyed.',
      );
    }

    final target = _contexts[name];
    if (target == null) {
      throw ContextNotFoundException(name.toString());
    }

    final ordered = contextDestroyOrder(name).toList();

    if (_belongsToSubtree(_currentContext, target)) {
      _currentContext = target.parent ?? _rootContext;
    }

    for (final qualifier in ordered) {
      final context = _contexts[qualifier];
      if (context == null) {
        continue;
      }

      context.parent?.children.remove(context);
      _contexts.remove(qualifier);
    }
  }

  bool _belongsToSubtree(QualifierContext candidate, QualifierContext root) {
    QualifierContext? cursor = candidate;
    while (cursor != null) {
      if (identical(cursor, root)) {
        return true;
      }
      cursor = cursor.parent;
    }
    return false;
  }

  @override
  ({DDIBaseFactory<BeanT> factory, Object context})?
      getFactory<BeanT extends Object>({
    required Object qualifier,
    bool fallback = true,
    Object? contextQualifier,
  }) {
    final context = _resolveContext(contextQualifier);
    if (context == null) {
      return null;
    }

    final localPrimary = context.getPrimaryEntry(qualifier);
    if (localPrimary != null) {
      return (
        factory: localPrimary.factory as DDIBaseFactory<BeanT>,
        context: context.qualifier,
      );
    }

    final localCandidates = context.aliasOwnersFor(qualifier);
    if (localCandidates != null && localCandidates.isNotEmpty) {
      final preferredPrimary = _pickPrimaryByPriorityOrThrow(
        context: context,
        alias: qualifier,
        candidates: localCandidates,
      );
      if (preferredPrimary == null) {
        return null;
      }
      final local = context.getPrimaryEntry(preferredPrimary);
      if (local == null) {
        return null;
      }
      return (
        factory: local.factory as DDIBaseFactory<BeanT>,
        context: context.qualifier,
      );
    }

    if (!fallback) {
      return null;
    }

    final resolved = _resolveWithFallback(context.parent, qualifier);
    if (resolved == null) {
      return null;
    }

    return (
      factory: resolved.entry.factory as DDIBaseFactory<BeanT>,
      context: resolved.context.qualifier,
    );
  }

  ({QualifierContext context, BeanEntry entry})? _resolveWithFallback(
    QualifierContext? startAt,
    Object qualifier,
  ) {
    QualifierContext? cursor = startAt;
    while (cursor != null) {
      final direct = cursor.getPrimaryEntry(qualifier);
      if (direct != null) {
        return (context: cursor, entry: direct);
      }

      final candidates = cursor.aliasOwnersFor(qualifier);
      if (candidates != null && candidates.isNotEmpty) {
        final primary = _pickPrimaryByPriorityOrThrow(
          context: cursor,
          alias: qualifier,
          candidates: candidates,
        );
        if (primary == null) {
          cursor = cursor.parent;
          continue;
        }
        final entry = cursor.getPrimaryEntry(primary);
        if (entry != null) {
          return (context: cursor, entry: entry);
        }
      }

      cursor = cursor.parent;
    }

    return null;
  }

  Object? _pickPrimaryByPriorityOrThrow({
    required QualifierContext context,
    required Object alias,
    required Iterable<Object> candidates,
  }) {
    int? bestPriority;
    final bestQualifiers = <Object>{};

    for (final primary in candidates) {
      final entry = context.getPrimaryEntry(primary);
      if (entry == null) {
        continue;
      }

      final candidatePriority = entry.priority;
      if (bestQualifiers.isEmpty) {
        bestPriority = candidatePriority;
        bestQualifiers.add(primary);
        continue;
      }

      final comparison = _comparePriority(candidatePriority, bestPriority);
      if (comparison < 0) {
        bestPriority = candidatePriority;
        bestQualifiers
          ..clear()
          ..add(primary);
      } else if (comparison == 0) {
        bestQualifiers.add(primary);
      }
    }

    if (bestQualifiers.isEmpty) {
      return null;
    }

    if (bestQualifiers.length > 1) {
      throw AmbiguousAliasException(
        alias: alias,
        context: context.qualifier,
        qualifiers: bestQualifiers,
      );
    }

    return bestQualifiers.first;
  }

  int _comparePriority(int? candidate, int? current) {
    if (candidate == null && current == null) {
      return 0;
    }
    if (candidate == null) {
      return 1;
    }
    if (current == null) {
      return -1;
    }
    return candidate.compareTo(current);
  }

  @override
  void setFactory(
    Object qualifier,
    DDIBaseFactory<Object> value, {
    Object? context,
    Set<Object>? aliases,
    int? priority,
  }) {
    final targetContext = _resolveContext(context) ?? _currentContext;

    targetContext.setEntry(
      qualifier,
      BeanEntry(
        factory: value,
        primaryQualifier: qualifier,
        priority: priority,
        aliases: aliases ?? const {},
      ),
    );
  }

  @visibleForTesting
  void addAliases(
    Object qualifier,
    Set<Object> newAliases, {
    Object? context,
  }) {
    final targetContext = _resolveContext(context) ?? _currentContext;
    targetContext.addAliases(qualifier, newAliases);
  }

  @visibleForTesting
  void removeAliases(
    Object qualifier,
    Set<Object> aliasesToRemove, {
    Object? context,
  }) {
    final targetContext = _resolveContext(context) ?? _currentContext;
    targetContext.removeAliases(qualifier, aliasesToRemove);
  }

  @visibleForTesting
  Set<Object> getAllQualifiers(Object qualifier, {Object? context}) {
    final targetContext = _resolveContext(context) ?? _currentContext;
    final candidates = targetContext.primaryQualifiersFor(qualifier);
    if (candidates.isEmpty) {
      return const {};
    }

    final all = <Object>{};
    for (final primary in candidates) {
      final entry = targetContext.getPrimaryEntry(primary);
      if (entry != null) {
        all.addAll(entry.allQualifiers);
      }
    }
    return all;
  }

  @override
  DDIBaseFactory<Object>? removeFactory(Object? key, {Object? context}) {
    final targetContext = _resolveContext(context);
    if (targetContext == null) {
      return null;
    }
    final removed = targetContext.removeEntry(key);
    if (removed == null) {
      return null;
    }
    return removed.factory;
  }

  @override
  Iterable<Object> get keys => _currentContext.primaryKeys;

  @override
  Iterable<MapEntry<Object, DDIBaseFactory<Object>>> entries(
      {Object? context}) {
    return _resolveContext(context)?.factoryEntries ?? const Iterable.empty();
  }

  @override
  Set<Object> qualifiersOf(Object key, {Object? context}) {
    final targetContext = _resolveContext(context);
    if (targetContext == null) {
      return const <Object>{};
    }

    final entry = targetContext.getPrimaryEntry(key);
    if (entry == null) {
      return const <Object>{};
    }
    return entry.allQualifiers;
  }

  @override
  bool get isEmpty => _currentContext.isEmpty;

  @override
  int get length => _currentContext.length;
}
