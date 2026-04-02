import 'package:dart_ddi/dart_ddi.dart';

/// Manages qualifier mapping for Zones
///
/// This class provides functionality to manage bean registrations across different
/// Dart zones, allowing for isolated dependency injection contexts. It handles
/// both zone-specific and global bean registrations with proper fallback mechanisms.
abstract interface class DartDDIQualifier {
  DDIBaseFactory<BeanT>? getFactory<BeanT extends Object>({
    required Object qualifier,
    bool fallback = true,
    Object? contextQualifier,
  });

  /// Restores a previously captured context.
  void restoreContext(Object? context);

  /// Returns the qualifier of the current active context.
  ///
  /// When the root context is active, returns `null`.
  Object? get currentContext;

  /// Checks if we are currently in a zone with a dedicated registry.
  ///
  /// Returns `true` if the current zone has its own bean registry,
  /// `false` if using the global registry.
  bool get hasContext;

  /// Executes code in a new zone with dedicated bean registries.
  ///
  /// This method creates a new zone with its own isolated bean registry,
  /// allowing for isolated dependency injection contexts. When the zone completes,
  /// all registered beans in that zone are automatically cleaned up.
  ///
  /// - `name`: Unique identifier for the zone (used for debugging).
  /// - `body`: Function to execute within the new zone context.
  BeanT runWithContext<BeanT>(Object name, BeanT Function() body);

  /// Implementation of required MapBase methods
  void setFactory(Object key, DDIBaseFactory<Object> value);

  Iterable<Object> get keys;

  Iterable<MapEntry<Object, DDIBaseFactory<Object>>> get entries;

  bool get isEmpty;

  int get length;

  DDIBaseFactory<Object>? remove(Object? key, {Object? context});
}
