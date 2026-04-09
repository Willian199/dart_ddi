import 'package:dart_ddi/dart_ddi.dart';

/// Manages qualifier mapping across contextual registries.
abstract interface class DDIStrategy {
  ({DDIBaseFactory<BeanT> factory, Object context})?
      getFactory<BeanT extends Object>({
    required Object qualifier,
    bool fallback = true,
    Object? contextQualifier,
  });

  /// Returns a token representing the current active context.
  ///
  /// This always returns a valid context object, including the root context.
  @pragma('vm:prefer-inline')
  Object get currentContext;

  /// Checks if we are currently in a dedicated non-root context.
  @pragma('vm:prefer-inline')
  bool get hasContext;

  /// Creates or activates a persistent context without executing a body.
  @pragma('vm:prefer-inline')
  void createContext(Object name);

  @pragma('vm:prefer-inline')
  bool hasContextQualifier(Object name);

  void freezeContext(Object name);

  void unfreezeContext(Object name);

  bool isContextFrozen(Object name);

  /// Returns the context and all linked descendants in destroy order.
  ///
  /// The first entries must be the deepest contexts.
  Iterable<Object> contextDestroyOrder(Object name);

  /// Returns `true` when context destroy is blocked by non-destroyable factories.
  bool contextHasDestroyBlockers(Object name);

  void destroyContext(Object name);

  /// Implementation of required MapBase methods
  void setFactory(
    Object key,
    DDIBaseFactory<Object> value, {
    Object? context,
    Set<Object>? aliases,
    int? priority,
  });

  @pragma('vm:prefer-inline')
  Iterable<Object> get keys;

  @pragma('vm:prefer-inline')
  Iterable<MapEntry<Object, DDIBaseFactory<Object>>> entries({Object? context});

  Set<Object> qualifiersOf(Object key, {Object? context});

  @pragma('vm:prefer-inline')
  bool get isEmpty;

  @pragma('vm:prefer-inline')
  int get length;

  DDIBaseFactory<Object>? removeFactory(Object? key, {Object? context});
}
