import 'dart:async';

import 'package:dart_ddi/dart_ddi.dart';
import 'package:dart_ddi/src/utils/interceptor_resolver.dart';

/// Utility class for destroying instances with proper cleanup and interceptor handling.
///
/// This class provides methods to safely destroy instances while ensuring proper cleanup of resources,
/// calling interceptors, and handling child modules. It manages the destruction process in a controlled manner,
/// respecting the `canDestroy` flag and calling appropriate lifecycle hooks.
///
/// The destruction process includes:
/// - Calling interceptors' `onDestroy` method
/// - Calling `PreDestroy` mixin if the instance implements it
/// - Destroying child modules if the instance is a `DDIModule`
/// - Executing the provided apply function to remove the instance from the container
final class InstanceDestroyUtils {
  /// Destroys an instance with proper cleanup and interceptor handling.
  ///
  /// This method orchestrates the destruction process, ensuring all cleanup steps are executed in the correct order.
  /// It respects the `canDestroy` flag and only proceeds with destruction if it's set to true.
  ///
  /// - `apply`: Function to remove the instance from the DDI container.
  /// - `canDestroy`: Flag indicating whether the instance can be destroyed.
  /// - `instance`: The instance to be destroyed (can be null).
  /// - `children`: Set of child qualifiers that should be destroyed.
  /// - `interceptors`: Set of interceptor qualifiers to call during destruction.
  ///
  /// The destruction process follows this order:
  /// 1. Call interceptors' `onDestroy` method (even if instance is null)
  /// 2. If instance implements `PreDestroy`, call `onPreDestroy` and destroy children
  /// 3. If instance is a `DDIModule` with children, destroy all children first
  /// 4. Execute the apply function to remove from container
  ///
  /// Example:
  /// ```dart
  /// await InstanceDestroyUtils.destroyInstance(
  ///   apply: () => ddi.remove<MyService>(),
  ///   canDestroy: true,
  ///   instance: myService,
  ///   children: {'child1', 'child2'},
  ///   interceptors: {'interceptor1'},
  /// );
  /// ```
  static FutureOr<void> destroyInstance<BeanT extends Object>({
    required void Function() apply,
    required BeanT? instance,
    required Set<Object> children,
    required Set<Object> interceptors,
    required DDI ddiInstance,
  }) async {
    // Should call interceptors even if the instance is null
    if (interceptors.isNotEmpty) {
      for (final interceptor in interceptors) {
        try {
          final resolved = InterceptorResolver.resolveAsync(
            ddiInstance: ddiInstance,
            qualifier: interceptor,
          );
          final DDIInterceptor inter =
              resolved is Future ? await resolved : resolved;

          final exec = inter.onDestroy(instance);
          if (exec is Future) {
            await exec;
          }
        } on BeanNotFoundException {
          // Ignore BeanNotFoundException interceptor error during destruction
        }
      }
    }

    if (instance case final clazz? when clazz is PreDestroy) {
      return _runFutureOrPreDestroy<BeanT>(
        clazz: clazz,
        children: children,
        apply: apply,
        ddiInstance: ddiInstance,
      );
    } else if (instance is DDIModule) {
      final Object? moduleContext = instance.contextQualifier;

      if (children.isNotEmpty) {
        final List<Future<void>> futures = [
          for (final Object child in children)
            Future<void>.sync(() {
              return ddiInstance.destroy(
                qualifier: child,
                context: moduleContext,
              );
            }),
        ];

        return Future.wait(
          futures,
          eagerError: true,
        ).then(
          (_) async {
            await _destroyModuleContext(
              ddiInstance: ddiInstance,
              context: moduleContext,
            );
            apply();
          },
        );
      }

      return _destroyModuleContext(
        ddiInstance: ddiInstance,
        context: moduleContext,
      ).then((_) => apply());
    }

    final destroyChildrenResult = _destroyChildren<BeanT>(
      children: children,
      ddiInstance: ddiInstance,
      context: instance is DDIModule ? instance.contextQualifier : null,
    );

    apply();

    if (destroyChildrenResult is Future) {
      return destroyChildrenResult;
    }
  }

  /// Destroys all child instances for a given set of child qualifiers.
  ///
  /// This method iterates through the children set and calls `ddi.destroy` for each child.
  /// It's used internally by the main destruction process to ensure all child modules are properly cleaned up.
  ///
  /// - `children`: Set of child qualifiers to destroy.
  ///
  /// Example:
  /// ```dart
  /// InstanceDestroyUtils._destroyChildren(children: {'child1', 'child2'});
  /// ```
  static FutureOr<void> _destroyChildren<BeanT extends Object>({
    required Set<Object> children,
    required DDI ddiInstance,
    Object? context,
  }) {
    final futures = <Future<void>>[];
    for (final Object child in children) {
      final result = ddiInstance.destroy(qualifier: child, context: context);
      if (result is Future) {
        futures.add(result);
      }
    }

    if (futures.isNotEmpty) {
      return Future.wait(futures).then((_) {});
    }
  }

  /// Executes the `onPreDestroy` method for instances that implement `PreDestroy`.
  ///
  /// This method is called when an instance implements the `PreDestroy` mixin. It ensures that
  /// the `onPreDestroy` method is called before the instance is destroyed, and that all children
  /// are also destroyed in the process.
  ///
  /// - `clazz`: The instance implementing `PreDestroy`.
  /// - `children`: Set of child qualifiers to destroy.
  /// - `apply`: Function to remove the instance from the container.
  ///
  /// Example:
  /// ```dart
  /// await InstanceDestroyUtils._runFutureOrPreDestroy(
  ///   clazz: myService,
  ///   children: {'child1'},
  ///   apply: () => ddi.remove<MyService>(),
  /// );
  /// ```
  static Future<void> _runFutureOrPreDestroy<BeanT extends Object>({
    required PreDestroy clazz,
    required Set<Object> children,
    required void Function() apply,
    required DDI ddiInstance,
  }) async {
    final Object? context =
        clazz is DDIModule ? (clazz as DDIModule).contextQualifier : null;

    for (final Object child in children) {
      await ddiInstance.destroy(
        qualifier: child,
        context: context,
      );
    }

    await clazz.onPreDestroy();
    await _destroyModuleContext(ddiInstance: ddiInstance, context: context);
    apply();
  }

  static Future<void> _destroyModuleContext({
    required DDI ddiInstance,
    required Object? context,
  }) async {
    if (context == null || !ddiInstance.contextExists(context)) {
      return;
    }

    final destroyResult = ddiInstance.destroyContext(context);
    if (destroyResult is Future) {
      await destroyResult;
    }
  }
}
