import 'package:dart_ddi/dart_ddi.dart';

final class BeanEntry {
  BeanEntry({
    required this.factory,
    required this.primaryQualifier,
    this.priority,
    Set<Object> aliases = const {},
  }) : aliases = Set.unmodifiable(
          aliases.where((alias) => alias != primaryQualifier),
        );

  final DDIBaseFactory<Object> factory;
  final Object primaryQualifier;
  final int? priority;
  final Set<Object> aliases;

  bool get canDestroy => factory.canDestroy;

  Set<Object> get allQualifiers => <Object>{primaryQualifier, ...aliases};

  BeanEntry withAliases(Set<Object> added) => BeanEntry(
        factory: factory,
        primaryQualifier: primaryQualifier,
        priority: priority,
        aliases: <Object>{...aliases, ...added},
      );

  BeanEntry withoutAliases(Set<Object> removed) => BeanEntry(
        factory: factory,
        primaryQualifier: primaryQualifier,
        priority: priority,
        aliases: aliases.difference(removed),
      );
}

final class QualifierContext {
  QualifierContext({
    required this.parent,
    required this.qualifier,
    required this.depth,
  })  : _entries = <Object, BeanEntry>{},
        _aliasIndex = <Object, Set<Object>>{};

  QualifierContext.root({required Object rootQualifier})
      : parent = null,
        qualifier = rootQualifier,
        depth = 0,
        _entries = <Object, BeanEntry>{},
        _aliasIndex = <Object, Set<Object>>{};

  final QualifierContext? parent;
  final Object qualifier;
  final int depth;

  final Set<QualifierContext> children = <QualifierContext>{};

  final Map<Object, BeanEntry> _entries;
  final Map<Object, Set<Object>> _aliasIndex;

  bool _hasNonDestroyableEntries = false;
  bool isFrozen = false;

  bool get hasNonDestroyableEntries => _hasNonDestroyableEntries;
  bool get isEmpty => _entries.isEmpty;
  int get length => _entries.length;
  Iterable<Object> get primaryKeys => _entries.keys;
  Iterable<BeanEntry> get entriesValues => _entries.values;

  Iterable<MapEntry<Object, DDIBaseFactory<Object>>> get factoryEntries =>
      _entries.entries.map((e) => MapEntry(e.key, e.value.factory));

  BeanEntry? getPrimaryEntry(Object primaryQualifier) =>
      _entries[primaryQualifier];

  Set<Object>? aliasOwnersFor(Object alias) => _aliasIndex[alias];

  Object? pickPrimaryByPriority(Iterable<Object> candidates) {
    Object? bestPrimary;
    BeanEntry? bestEntry;

    for (final primary in candidates) {
      final entry = _entries[primary];
      if (entry == null) {
        continue;
      }

      if (bestEntry == null || _isHigherPriority(entry, bestEntry)) {
        bestPrimary = primary;
        bestEntry = entry;
      }
    }

    return bestPrimary;
  }

  Set<Object> primaryQualifiersFor(Object qualifier) {
    if (_entries.containsKey(qualifier)) {
      return <Object>{qualifier};
    }

    final owners = _aliasIndex[qualifier];
    if (owners == null || owners.isEmpty) {
      return const <Object>{};
    }
    return Set<Object>.unmodifiable(owners);
  }

  BeanEntry? getEntry(Object qualifier) {
    final direct = _entries[qualifier];
    if (direct != null) {
      return direct;
    }

    final owners = _aliasIndex[qualifier];
    if (owners == null || owners.length != 1) {
      return null;
    }
    return _entries[owners.first];
  }

  void setEntry(Object primaryQualifier, BeanEntry entry) {
    assert(
      entry.primaryQualifier == primaryQualifier,
      'BeanEntry.primaryQualifier must match the map key',
    );

    final existing = _entries[primaryQualifier];
    if (existing != null) {
      _unregisterAliases(existing);
    }

    _entries[primaryQualifier] = entry;
    _registerAliases(entry);
    _recalcDestroyFlagAfterSet(replaced: existing, incoming: entry);
  }

  void addAliases(Object primaryQualifier, Set<Object> newAliases) {
    final entry = _entries[primaryQualifier];
    if (entry == null) {
      throw ArgumentError.value(
        primaryQualifier,
        'primaryQualifier',
        'No bean registered under this qualifier.',
      );
    }

    final updated = entry.withAliases(newAliases);
    _entries[primaryQualifier] = updated;
    _registerAliases(updated);
  }

  void removeAliases(Object primaryQualifier, Set<Object> aliasesToRemove) {
    final entry = _entries[primaryQualifier];
    if (entry == null) {
      return;
    }

    final updated = entry.withoutAliases(aliasesToRemove);
    _entries[primaryQualifier] = updated;
    for (final alias in aliasesToRemove) {
      final owners = _aliasIndex[alias];
      if (owners == null) {
        continue;
      }
      owners.remove(primaryQualifier);
      if (owners.isEmpty) {
        _aliasIndex.remove(alias);
      }
    }
  }

  BeanEntry? removeEntry(Object? key) {
    if (key == null) {
      return null;
    }

    final owners = _aliasIndex[key];
    if (!_entries.containsKey(key) && owners != null && owners.length != 1) {
      return null;
    }

    final resolvedKey = _entries.containsKey(key) ? key : owners?.first ?? key;
    final removed = _entries.remove(resolvedKey);
    if (removed == null) {
      return null;
    }

    _unregisterAliases(removed);

    if (_entries.isEmpty) {
      _hasNonDestroyableEntries = false;
      return removed;
    }

    if (!removed.canDestroy && _hasNonDestroyableEntries) {
      _hasNonDestroyableEntries =
          _entries.values.any((entry) => !entry.canDestroy);
    }

    return removed;
  }

  void _registerAliases(BeanEntry entry) {
    for (final alias in entry.aliases) {
      (_aliasIndex[alias] ??= <Object>{}).add(entry.primaryQualifier);
    }
  }

  void _unregisterAliases(BeanEntry entry) {
    for (final alias in entry.aliases) {
      final owners = _aliasIndex[alias];
      if (owners == null) {
        continue;
      }

      owners.remove(entry.primaryQualifier);
      if (owners.isEmpty) {
        _aliasIndex.remove(alias);
      }
    }
  }

  void _recalcDestroyFlagAfterSet({
    required BeanEntry? replaced,
    required BeanEntry incoming,
  }) {
    if (!incoming.canDestroy) {
      _hasNonDestroyableEntries = true;
      return;
    }

    if (replaced != null && !replaced.canDestroy && _hasNonDestroyableEntries) {
      _hasNonDestroyableEntries =
          _entries.values.any((entry) => !entry.canDestroy);
    }
  }

  bool _isHigherPriority(BeanEntry candidate, BeanEntry current) {
    final candidatePriority = candidate.priority;
    final currentPriority = current.priority;

    // null means "no priority", always sorted to the end.
    if (candidatePriority == null) {
      return false;
    }
    if (currentPriority == null) {
      return true;
    }
    return candidatePriority < currentPriority;
  }
}
