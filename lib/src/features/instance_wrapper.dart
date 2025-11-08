import 'dart:async';
import 'dart:core';

import 'package:dart_ddi/dart_ddi.dart';

/// Internal wrapper for Instance that uses DDI's getWith methods.
///
/// This implementation supports:
/// - `useWeakReference`: If `true`, maintains a weak reference to the instance.
///   This allows the instance to be garbage collected if no other strong references exist.
/// - `cache`: If `true`, maintains a strong reference to the instance (caching).
///   This prevents the instance from being garbage collected while the Instance wrapper exists.
///
/// **Important:** If both `useWeakReference` and `cache` are `true`, `cache` takes precedence
/// (strong reference is maintained).
class InstanceWrapper<BeanT extends Object> implements Instance<BeanT> {
  InstanceWrapper({
    required this.qualifier,
    required this.ddi,
    bool useWeakReference = false,
    bool cache = false,
  })  : _useWeakReference =
            useWeakReference && !cache, // cache takes precedence
        _cache = cache;

  final Object qualifier;
  final DDI ddi;

  /// Whether to use weak reference for the instance.
  /// Only effective if `cache` is `false`.
  final bool _useWeakReference;

  /// Whether to cache (strong reference) the instance.
  /// Takes precedence over `useWeakReference`.
  final bool _cache;

  /// Strong reference to the cached instance (used when `_cache` is true).
  BeanT? _cachedInstance;

  /// Weak reference to the instance (used when `_useWeakReference` is true and `_cache` is false).
  WeakReference<BeanT>? _weakCachedInstance;

  @override
  bool isResolvable() {
    return ddi.isRegistered<BeanT>(qualifier: qualifier);
  }

  @override
  BeanT get<ParameterT extends Object>({ParameterT? parameter}) {
    // Check cache first if enabled
    if (_cache && _cachedInstance != null) {
      return _cachedInstance!;
    }

    // Check weak reference if configured
    if (_useWeakReference && _weakCachedInstance != null) {
      final weakInstance = _weakCachedInstance?.target;
      if (weakInstance != null) {
        return weakInstance;
      }
      // Weak reference was collected, clear it
      _weakCachedInstance = null;
    }

    // Get instance from DDI
    final instance = ddi.getWith<BeanT, ParameterT>(
      qualifier: qualifier,
      parameter: parameter,
    );

    // Update cache/weak reference based on configuration
    _updateCache(instance);

    return instance;
  }

  @override
  Future<BeanT> getAsync<ParameterT extends Object>(
      {ParameterT? parameter}) async {
    // Check cache first if enabled
    if (_cache && _cachedInstance != null) {
      return _cachedInstance!;
    }

    // Check weak reference if configured
    if (_useWeakReference && _weakCachedInstance != null) {
      final weakInstance = _weakCachedInstance?.target;
      if (weakInstance != null) {
        return weakInstance;
      }
      // Weak reference was collected, clear it
      _weakCachedInstance = null;
    }

    // Get instance from DDI
    final instance = await ddi.getAsyncWith<BeanT, ParameterT>(
      qualifier: qualifier,
      parameter: parameter,
    );

    // Update cache/weak reference based on configuration
    _updateCache(instance);

    return instance;
  }

  /// Updates the cache/weak reference based on the configuration.
  void _updateCache(BeanT instance) {
    if (_cache) {
      // Cache takes precedence: maintain strong reference
      _cachedInstance = instance;
      _weakCachedInstance = null;
    } else if (_useWeakReference) {
      // Use weak reference: allow GC collection
      _weakCachedInstance = WeakReference(instance);
      _cachedInstance = null;
    } else {
      // No caching: clear both
      _cachedInstance = null;
      _weakCachedInstance = null;
    }
  }

  @override
  FutureOr<void> destroy() {
    // Clear cache before destroying
    _cachedInstance = null;
    _weakCachedInstance = null;
    return ddi.destroy<BeanT>(qualifier: qualifier);
  }

  @override
  Future<void> dispose() {
    // Clear cache before disposing
    _cachedInstance = null;
    _weakCachedInstance = null;
    return ddi.dispose<BeanT>(qualifier: qualifier);
  }
}
