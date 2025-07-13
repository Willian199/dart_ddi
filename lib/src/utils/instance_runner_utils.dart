import 'dart:async';

import 'package:dart_ddi/src/exception/concurrent_creation.dart';
import 'package:dart_ddi/src/factories/dart_ddi_base_factory.dart';

/// Utility class for running instance creation with proper concurrency control and zone management.
///
/// This class provides methods to safely create instances while preventing concurrent creation of the same instance,
/// which could lead to race conditions or duplicate instances. It uses Dart's Zone API to manage resolution maps
/// and ensure thread-safe instance creation.
///
/// The class handles both synchronous and asynchronous instance creation, with proper cleanup of resolution maps
/// to prevent memory leaks.
final class InstanceRunnerUtils {
  /// Key used to store the resolution map in the current zone.
  static const _resolutionKey = #_resolutionKey;

  /// Gets the resolution map for the current zone, or creates an empty one if it doesn't exist.
  ///
  /// The resolution map tracks which instances are currently being created to prevent concurrent creation.
  static Set<Object> _getResolutionMap() {
    return Zone.current[_resolutionKey] as Set<Object>? ?? {};
  }

  /// Runs instance creation synchronously with concurrency control.
  ///
  /// This method ensures that only one instance of a given type/qualifier combination is being created at a time.
  /// If a concurrent creation is detected, it throws a [ConcurrentCreationException].
  ///
  /// - `factory`: The factory responsible for creating the instance.
  /// - `effectiveQualifierName`: The qualifier name used to identify the instance.
  /// - `parameter`: Optional parameter to pass during instance creation.
  ///
  /// If no resolution map exists in the current zone, it creates a new zone with a fresh resolution map.
  ///
  /// Example:
  /// ```dart
  /// final instance = InstanceRunnerUtils.run(
  ///   factory: myFactory,
  ///   effectiveQualifierName: 'myService',
  ///   parameter: 'config',
  /// );
  /// ```
  static BeanT run<BeanT extends Object, ParameterT extends Object>({
    required DDIBaseFactory<BeanT> factory,
    required Object effectiveQualifierName,
    ParameterT? parameter,
  }) {
    final resolutionMap = _getResolutionMap();

    if (resolutionMap.contains(effectiveQualifierName)) {
      throw ConcurrentCreationException(effectiveQualifierName.toString());
    }

    // If resolutionMap doesn't exist in the current zone, create a new zone with a new map
    if (Zone.current[_resolutionKey] == null) {
      return runZoned(
        () => run(
          factory: factory,
          effectiveQualifierName: effectiveQualifierName,
          parameter: parameter,
        ),
        zoneValues: {_resolutionKey: <Object>{}},
      );
    }

    resolutionMap.add(effectiveQualifierName);

    try {
      return factory.getWith<ParameterT>(
          parameter: parameter, qualifier: effectiveQualifierName);
    } finally {
      resolutionMap.remove(effectiveQualifierName);
    }
  }

  /// Runs instance creation asynchronously with concurrency control.
  ///
  /// This method ensures that only one instance of a given type/qualifier combination is being created at a time,
  /// even for asynchronous creation. If a concurrent creation is detected, it throws a [ConcurrentCreationException].
  ///
  /// - `factory`: The factory responsible for creating the instance.
  /// - `effectiveQualifierName`: The qualifier name used to identify the instance.
  /// - `parameter`: Optional parameter to pass during instance creation.
  ///
  /// If no resolution map exists in the current zone, it creates a new zone with a fresh resolution map.
  ///
  /// Example:
  /// ```dart
  /// final instance = await InstanceRunnerUtils.runAsync(
  ///   factory: myAsyncFactory,
  ///   effectiveQualifierName: 'myAsyncService',
  ///   parameter: 'config',
  /// );
  /// ```
  static Future<BeanT>
      runAsync<BeanT extends Object, ParameterT extends Object>({
    required DDIBaseFactory<BeanT> factory,
    required Object effectiveQualifierName,
    ParameterT? parameter,
  }) async {
    final resolutionMap = _getResolutionMap();

    if (resolutionMap.contains(effectiveQualifierName)) {
      throw ConcurrentCreationException(effectiveQualifierName.toString());
    }

    // If resolutionMap doesn't exist in the current zone, create a new zone with a new map
    if (Zone.current[_resolutionKey] == null) {
      return runZoned(
        () => runAsync(
          factory: factory,
          effectiveQualifierName: effectiveQualifierName,
          parameter: parameter,
        ),
        zoneValues: {_resolutionKey: <Object>{}},
      );
    }

    resolutionMap.add(effectiveQualifierName);

    try {
      return await factory.getAsyncWith(
          parameter: parameter, qualifier: effectiveQualifierName);
    } finally {
      resolutionMap.remove(effectiveQualifierName);
    }
  }
}
