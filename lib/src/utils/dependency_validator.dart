import 'dart:async';

import 'package:dart_ddi/dart_ddi.dart';

/// Utility class for validating required dependencies in DDI factories.
///
/// This class centralizes the logic for validating that all required dependencies
/// (qualifiers or types) are registered and ready in the DDI container before
/// creating or retrieving bean instances.
class DependencyValidator {
  /// Validates that all required dependencies are registered (synchronous version).
  ///
  /// This method checks if all qualifiers/types in [required] are registered
  /// in the DDI container. If any dependency is missing, it throws
  /// [MissingDependenciesException].
  ///
  /// **Note:** This method assumes that [required] is not null and not empty.
  /// The factory should check this before calling this method.
  ///
  /// - `required`: Set of qualifiers or types that must be registered (must not be null or empty).
  /// - `ddiInstance`: The DDI instance to use for validation (defaults to `DDI.instance`).
  static void validateDependencies({
    required Set<Object> required,
    required DDI ddiInstance,
  }) {
    for (final dep in required) {
      if (!ddiInstance.isRegistered(qualifier: dep)) {
        throw MissingDependenciesException(
          'Required dependency "${dep.toString()}" is not registered',
        );
      }

      if (!ddiInstance.isReady(qualifier: dep)) {
        if (ddiInstance.isFuture(qualifier: dep)) {
          throw MissingDependenciesException(
            'Required async dependency "${dep.toString()}" is not ready. Use getAsyncWith instead.',
          );
        }
        ddiInstance.getWith(qualifier: dep);
      }
    }
  }

  /// Validates that all required dependencies are registered (asynchronous version).
  ///
  /// This method checks if all qualifiers/types in [required] are registered
  /// in the DDI container. If any dependency is missing, it throws
  /// [MissingDependenciesException]. For async dependencies, it waits for them to be ready.
  ///
  /// **Note:** This method assumes that [required] is not null and not empty.
  /// The factory should check this before calling this method.
  ///
  /// - `required`: Set of qualifiers or types that must be registered (must not be null or empty).
  /// - `ddiInstance`: The DDI instance to use for validation (defaults to `DDI.instance`).
  ///
  /// Returns `FutureOr<void>` - The return type is `FutureOr<void>` to maintain compatibility
  /// with existing code that may need to await the result conditionally.
  static FutureOr<void> validateDependenciesAsync({
    required Set<Object> required,
    required DDI ddiInstance,
  }) async {
    for (final dep in required) {
      if (!ddiInstance.isRegistered(qualifier: dep)) {
        throw MissingDependenciesException(
          'Required dependency "${dep.toString()}" is not registered',
        );
      }

      if (!ddiInstance.isReady(qualifier: dep)) {
        if (ddiInstance.isFuture(qualifier: dep)) {
          await ddiInstance.getAsyncWith(qualifier: dep);
        } else {
          ddiInstance.getWith(qualifier: dep);
        }
      }
    }
  }
}
