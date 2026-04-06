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
  static const _rootContext = #ddi_zone_root_context;

  /// Gets the current zone name for debugging and identification purposes.
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

  Map<Object, DDIBaseFactory<Object>> _getBeansMapForContext(Object? context) {
    if (context == _rootContext) {
      return _globalBeansMap;
    }

    if (context case final Map<Object, DDIBaseFactory<Object>> explicitMap) {
      return explicitMap;
    }

    return switch (Zone.current[context ?? _beansKey]) {
      final Map<Object, DDIBaseFactory<Object>> zoneMap => zoneMap,
      _ => <Object, DDIBaseFactory<Object>>{},
    };
  }

  @override
  ({DDIBaseFactory<BeanT> factory, Object context})?
      getFactory<BeanT extends Object>({
    required Object qualifier,
    bool fallback = true,
    Object? contextQualifier,
  }) {
    if (contextQualifier == _rootContext) {
      final rootFactory = _globalBeansMap[qualifier];
      if (rootFactory == null) {
        return null;
      }
      return (
        factory: rootFactory as DDIBaseFactory<BeanT>,
        context: _rootContext
      );
    }

    final Map<Object, DDIBaseFactory<Object>>? zoneMap =
        switch (contextQualifier) {
      final Map<Object, DDIBaseFactory<Object>> explicitMap => explicitMap,
      _ => Zone.current[contextQualifier ?? _beansKey]
          as Map<Object, DDIBaseFactory<Object>>?,
    };

    if (zoneMap?.containsKey(qualifier) ?? false) {
      return (
        factory: zoneMap![qualifier] as DDIBaseFactory<BeanT>,
        context: zoneMap
      );
    } else if (fallback && Zone.current.parent != null) {
      Zone zone = Zone.current.parent!;

      while (zone.parent != null && zone[#zone_name] != null) {
        final Map<Object, DDIBaseFactory<Object>>? parentZoneMap =
            zone[_beansKey] as Map<Object, DDIBaseFactory<Object>>?;

        if (parentZoneMap?.containsKey(qualifier) ?? false) {
          return (
            factory: parentZoneMap![qualifier] as DDIBaseFactory<BeanT>,
            context: parentZoneMap
          );
        }

        zone = zone.parent!;
      }
    }

    if (fallback || (contextQualifier == null && zoneName == 'root')) {
      final rootFactory = _globalBeansMap[qualifier];
      if (rootFactory == null) {
        return null;
      }
      return (
        factory: rootFactory as DDIBaseFactory<BeanT>,
        context: _rootContext
      );
    }

    return null;
  }

  @override
  void restoreContext(Object? context) {}

  @override
  Object get currentContext =>
      Zone.current[_beansKey] as Map<Object, DDIBaseFactory<Object>>? ??
      _rootContext;

  /// Checks if we are currently in a zone with a dedicated registry.
  ///
  /// Returns `true` if the current zone has its own bean registry,
  /// `false` if using the global registry.
  @override
  bool get hasContext => Zone.current[_beansKey] != null;

  /// Executes code in a new zone with dedicated bean registries.
  ///
  /// This method creates a new zone with its own isolated bean registry,
  /// allowing for isolated dependency injection contexts. When the zone completes,
  /// all registered beans in that zone are automatically cleaned up.
  ///
  /// - `name`: Unique identifier for the zone (used for debugging).
  /// - `body`: Function to execute within the new zone context.
  @override
  BeanT runWithContext<BeanT>(Object name, BeanT Function() body) {
    return runZoned(
      body,
      zoneValues: {
        #zone_name: name,
        _beansKey: <Object, DDIBaseFactory<Object>>{},
      },
    );
  }

  @override
  void createContext(Object name) {}

  @override
  bool hasContextQualifier(Object name) {
    if (name == _rootContext) {
      return true;
    }

    return Zone.current[#zone_name] == name ||
        ((Zone.current[_beansKey] as Map<Object, DDIBaseFactory<Object>>?)
                ?.isNotEmpty ??
            false);
  }

  @override
  Iterable<Object> contextDestroyOrder(Object name) {
    if (hasContextQualifier(name)) {
      return [name];
    }

    return const Iterable.empty();
  }

  @override
  bool contextHasDestroyBlockers(Object name) {
    if (name == _rootContext) {
      return _globalBeansMap.values.any((factory) => !factory.canDestroy);
    }

    if (name case final Map<Object, DDIBaseFactory<Object>> explicitMap) {
      return explicitMap.values.any((factory) => !factory.canDestroy);
    }

    return false;
  }

  @override
  void destroyContext(Object name) {
    if (name == _rootContext) {
      throw ArgumentError.value(
          name, 'name', 'Root context cannot be destroyed.');
    }

    if (name case final Map<Object, DDIBaseFactory<Object>> explicitMap) {
      explicitMap.clear();
      return;
    }

    throw ContextNotFoundException(name.toString());
  }

  /// Implementation of required MapBase methods
  @override
  void setFactory(Object key, DDIBaseFactory<Object> value, {Object? context}) {
    _getBeansMapForContext(context)[key] = value;
  }

  @override
  Iterable<Object> get keys => _getBeansMap().keys;

  @override
  Iterable<MapEntry<Object, DDIBaseFactory<Object>>> entries(
      {Object? context}) {
    return _getBeansMapForContext(context).entries;
  }

  @override
  bool get isEmpty => _getBeansMap().isEmpty;

  @override
  int get length => _getBeansMap().length;

  @override
  DDIBaseFactory<Object>? removeFactory(Object? key, {Object? context}) {
    if (context == _rootContext) {
      return _globalBeansMap.remove(key);
    }

    if (context case final Map<Object, DDIBaseFactory<Object>> explicitMap) {
      return explicitMap.remove(key);
    }

    return _getBeansMap().remove(key);
  }
}
