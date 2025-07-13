import 'dart:async';

import 'package:dart_ddi/dart_ddi.dart';

/// Manages qualifier mapping for Zones
class DartDDIQualifier {
  /// Key used to store data in Zone
  static const _beansKey = #ddi_beans_registry;

  String get zoneName => Zone.current[#zone_name] as String? ?? 'root';

  /// Global beans map (fallback)
  final Map<Object, DDIBaseFactory<Object>> _globalBeansMap = {};

  /// Gets the beans map for the current zone
  Map<Object, DDIBaseFactory<Object>> _getBeansMap() {
    final Map<Object, DDIBaseFactory<Object>>? zoneMap =
        Zone.current[_beansKey] as Map<Object, DDIBaseFactory<Object>>?;

    return zoneMap ?? _globalBeansMap;
  }

  DDIBaseFactory<Object>? getFactory<BeanT extends Object>(
      {required Object qualifier, bool fallback = true}) {
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

  /// Checks if we are in a zone with dedicated registry
  bool hasZoneRegistry() {
    return Zone.current[_beansKey] != null;
  }

  /// Executes code in a new zone with dedicated registries
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
  void setFactory(Object key, DDIBaseFactory<Object> value) {
    _getBeansMap()[key] = value;
  }

  Iterable<Object> get keys => _getBeansMap().keys;

  Iterable<MapEntry<Object, DDIBaseFactory<Object>>> get entries =>
      _getBeansMap().entries;

  DDIBaseFactory<Object>? remove(Object? key) {
    return _getBeansMap().remove(key);
  }
}
