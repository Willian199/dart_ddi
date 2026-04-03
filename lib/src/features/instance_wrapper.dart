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
    required this.context,
    bool useWeakReference = false,
    bool cache = false,
  })  : _useWeakReference =
            useWeakReference && !cache, // cache takes precedence
        _cache = cache;

  final Object qualifier;
  final DDI ddi;
  final Object context;

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
    return ddi.isRegistered<BeanT>(qualifier: qualifier, context: context);
  }

  @override
  BeanT get<ParameterT extends Object>({ParameterT? parameter}) {
    if (!_cache && !_useWeakReference) {
      return ddi.getWith<BeanT, ParameterT>(
        qualifier: qualifier,
        parameter: parameter,
        context: context,
      );
    }

    if (_cache && _cachedInstance != null) {
      return _cachedInstance!;
    }

    if (_useWeakReference && _weakCachedInstance != null) {
      final weakInstance = _weakCachedInstance?.target;
      if (weakInstance != null) {
        return weakInstance;
      }
      _weakCachedInstance = null;
    }

    final instance = ddi.getWith<BeanT, ParameterT>(
      qualifier: qualifier,
      parameter: parameter,
      context: context,
    );

    _updateCache(instance);

    return instance;
  }

  @override
  Future<BeanT> getAsync<ParameterT extends Object>(
      {ParameterT? parameter}) async {
    if (!_cache && !_useWeakReference) {
      return ddi.getAsyncWith<BeanT, ParameterT>(
        qualifier: qualifier,
        parameter: parameter,
        context: context,
      );
    }

    if (_cache && _cachedInstance != null) {
      return _cachedInstance!;
    }

    if (_useWeakReference && _weakCachedInstance != null) {
      final weakInstance = _weakCachedInstance?.target;
      if (weakInstance != null) {
        return weakInstance;
      }
      _weakCachedInstance = null;
    }

    final instance = await ddi.getAsyncWith<BeanT, ParameterT>(
      qualifier: qualifier,
      parameter: parameter,
      context: context,
    );

    _updateCache(instance);

    return instance;
  }

  void _updateCache(BeanT instance) {
    if (_cache) {
      _cachedInstance = instance;
      _weakCachedInstance = null;
    } else if (_useWeakReference) {
      _weakCachedInstance = WeakReference(instance);
      _cachedInstance = null;
    } else {
      _cachedInstance = null;
      _weakCachedInstance = null;
    }
  }

  @override
  FutureOr<void> destroy() {
    _cachedInstance = null;
    _weakCachedInstance = null;
    return ddi.destroy<BeanT>(qualifier: qualifier, context: context);
  }

  @override
  Future<void> dispose() {
    _cachedInstance = null;
    _weakCachedInstance = null;
    return ddi.dispose<BeanT>(qualifier: qualifier, context: context);
  }
}
