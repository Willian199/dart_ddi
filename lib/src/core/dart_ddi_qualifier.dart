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

  /// Returns a token representing the current active context.
  ///
  /// This always returns a valid context object, including the root context.
  @pragma('vm:prefer-inline')
  Object get currentContext;

  /// Checks if we are currently in a zone with a dedicated registry.
  ///
  /// Returns `true` if the current zone has its own bean registry,
  /// `false` if using the global registry.
  @pragma('vm:prefer-inline')
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

  /// Creates or activates a persistent context without executing a body.
  @pragma('vm:prefer-inline')
  void createContext(Object name);

  /// Implementation of required MapBase methods
  @pragma('vm:prefer-inline')
  void setFactory(Object key, DDIBaseFactory<Object> value);

  @pragma('vm:prefer-inline')
  Iterable<Object> get keys;

  @pragma('vm:prefer-inline')
  Iterable<MapEntry<Object, DDIBaseFactory<Object>>> entries({Object? context});

  @pragma('vm:prefer-inline')
  bool get isEmpty;

  @pragma('vm:prefer-inline')
  int get length;

  DDIBaseFactory<Object>? remove(Object? key, {Object? context});
}
