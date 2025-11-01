import 'package:dart_ddi/dart_ddi.dart';
import 'package:dart_ddi/src/core/dart_ddi_qualifier.dart';

/// Implementation of [DartDDIQualifier] without using Zones.
///
/// Instead of Zone-based isolation, this version uses named contexts
/// to provide isolated bean registries with fallback to a global registry.
final class DartDDIDefaultQualifierImpl implements DartDDIQualifier {
  /// Name of the global context.
  static const String _globalContext = 'root';

  /// Map of context names to their bean registries.
  final Map<Object, DDIBaseFactory<Object>> _contexts = {};

  /// Returns the current "zone" name (actually context name here).
  @override
  String get zoneName => _globalContext;

  @override
  DDIBaseFactory<BeanT>? getFactory<BeanT extends Object>({
    required Object qualifier,
    bool fallback = true,
  }) {
    return _contexts[qualifier] as DDIBaseFactory<BeanT>?;
  }

  @override
  void setFactory(Object qualifier, DDIBaseFactory<Object> value) {
    _contexts[qualifier] = value;
  }

  @override
  bool hasZoneRegistry() {
    return false;
  }

  @override
  T runWithZoneRegistry<T>(String name, T Function() body) {
    throw UnsupportedError(
      'Zones are not supported with the Default Qualifier',
    );
  }

  @override
  DDIBaseFactory<Object>? remove(Object? key) {
    return _contexts.remove(key);
  }

  @override
  Iterable<Object> get keys => _contexts.keys;

  @override
  Iterable<MapEntry<Object, DDIBaseFactory<Object>>> get entries =>
      _contexts.entries;

  @override
  bool get isEmpty => _contexts.isEmpty;

  @override
  int get length => _contexts.length;
}
