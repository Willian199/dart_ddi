import 'package:dart_ddi/src/typedef/typedef.dart';

/// Utility class for applying decorators to instances.
///
/// This class provides functionality to apply a chain of decorators to an instance,
/// allowing for dynamic modification or enhancement of object behavior.
/// Decorators are applied in the order they are provided in the list.
final class InstanceDecoratorsUtils {
  /// Applies a list of decorators to an instance in sequence.
  ///
  /// This method takes an instance and applies each decorator in the provided list,
  /// passing the result of each decorator to the next one. This creates a chain
  /// of transformations that can modify or enhance the original instance.
  ///
  /// **Important notes:**
  /// - Decorators are applied in the order they appear in the list
  /// - Each decorator receives the result of the previous decorator
  /// - If the decorators list is null or empty, the original instance is returned unchanged
  /// - The final result is the output of the last decorator in the chain
  ///
  /// **Use cases:**
  /// - Adding logging or monitoring to instances
  /// - Implementing caching or memoization
  /// - Adding validation or transformation logic
  /// - Creating proxy or wrapper objects
  ///
  /// - `clazz`: The original instance to be decorated.
  /// - `decorators`: List of decorator functions to apply (can be null or empty).
  ///
  /// Example:
  /// ```dart
  /// // Define decorators
  /// String addPrefix(String str) => 'PREFIX: $str';
  /// String addSuffix(String str) => '$str :SUFFIX';
  /// String toUpperCase(String str) => str.toUpperCase();
  ///
  /// // Apply decorators
  /// final result = InstanceDecoratorsUtils.executeDecorators(
  ///   'hello',
  ///   [addPrefix, toUpperCase, addSuffix],
  /// );
  /// // Result: 'PREFIX: HELLO :SUFFIX'
  /// ```
  static BeanT executeDecorators<BeanT extends Object>(
    BeanT clazz,
    ListDecorator<BeanT>? decorators,
  ) {
    if (decorators != null) {
      for (final decorator in decorators) {
        clazz = decorator(clazz);
      }
    }

    return clazz;
  }
}
