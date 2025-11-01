import 'dart:async';

import 'package:dart_ddi/dart_ddi.dart';
import 'package:dart_ddi/src/core/dart_ddi_qualifier.dart';

/// Manages qualifier mapping for Zones
///
/// This class provides functionality to manage bean registrations across different
/// Dart zones, allowing for isolated dependency injection contexts. It handles
/// both zone-specific and global bean registrations with proper fallback mechanisms.
final class DartDDIZoneQualifierImpl implements DartDDIQualifier {
  /// Key used to store bean registry data in Zone
  static const _beansKey = #ddi_beans_registry;

  /// Gets the current zone name for debugging and identification purposes.
  @override
  String get zoneName => Zone.current[#zone_name] as String? ?? 'root';

  /// Global beans map used as fallback when no zone-specific registry exists.
  final Map<Object, DDIBaseFactory<Object>> _globalBeansMap = {};

  /// Gets the beans map for the current zone, falling back to global registry if needed.
  ///
  /// This method returns the appropriate bean registry based on the current zone context.
  /// If no zone-specific registry exists, it falls back to the global registry.
  Map<Object, DDIBaseFactory<Object>> _getBeansMap() {
    final Map<Object, DDIBaseFactory<Object>>? zoneMap =
        Zone.current[_beansKey] as Map<Object, DDIBaseFactory<Object>>?;

    return zoneMap ?? _globalBeansMap;
  }

  @override
  DDIBaseFactory<BeanT>? getFactory<BeanT extends Object>({
    required Object qualifier,
    bool fallback = true,
  }) {
    final Map<Object, DDIBaseFactory<Object>>? zoneMap =
        Zone.current[_beansKey] as Map<Object, DDIBaseFactory<Object>>?;

    if (zoneMap?.containsKey(qualifier) ?? false) {
      return zoneMap?[qualifier] as DDIBaseFactory<BeanT>;
    } else if (fallback && Zone.current.parent != null) {
      Zone zone = Zone.current.parent!;

      while (zone.parent != null && zone[#zone_name] != null) {
        final Map<Object, DDIBaseFactory<Object>>? parentZoneMap =
            zone[_beansKey] as Map<Object, DDIBaseFactory<Object>>?;

        if (parentZoneMap?.containsKey(qualifier) ?? false) {
          return parentZoneMap?[qualifier] as DDIBaseFactory<BeanT>;
        }

        zone = zone.parent!;
      }
    }

    if (fallback || zoneName == 'root') {
      return _globalBeansMap[qualifier] as DDIBaseFactory<BeanT>?;
    }

    return null;
  }

  /// Checks if we are currently in a zone with a dedicated registry.
  ///
  /// Returns `true` if the current zone has its own bean registry,
  /// `false` if using the global registry.
  @override
  bool hasZoneRegistry() {
    return Zone.current[_beansKey] != null;
  }

  /// Executes code in a new zone with dedicated bean registries.
  ///
  /// This method creates a new zone with its own isolated bean registry,
  /// allowing for isolated dependency injection contexts. When the zone completes,
  /// all registered beans in that zone are automatically cleaned up.
  ///
  /// - `name`: Unique identifier for the zone (used for debugging).
  /// - `body`: Function to execute within the new zone context.
  @override
  T runWithZoneRegistry<T>(String name, T Function() body) {
    return runZoned(
      body,
      zoneValues: {
        #zone_name: name,
        _beansKey: <Object, DDIBaseFactory<Object>>{},
      },
    );
  }

  /// Implementation of required MapBase methods
  @override
  void setFactory(Object key, DDIBaseFactory<Object> value) {
    _getBeansMap()[key] = value;
  }

  @override
  Iterable<Object> get keys => _getBeansMap().keys;

  @override
  Iterable<MapEntry<Object, DDIBaseFactory<Object>>> get entries =>
      _getBeansMap().entries;

  @override
  bool get isEmpty => _getBeansMap().isEmpty;

  @override
  int get length => _getBeansMap().length;

  @override
  DDIBaseFactory<Object>? remove(Object? key) {
    return _getBeansMap().remove(key);
  }
}
