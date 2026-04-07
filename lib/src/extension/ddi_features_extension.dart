import 'package:dart_ddi/src/core/dart_ddi.dart';

extension DDIFeaturesExtension on DDI {
  /// Adds a single child module to a parent module.
  ///
  /// This method allows you to establish a parent-child relationship between modules,
  /// where the parent module can manage the lifecycle of its child modules.
  /// When the parent module is disposed or destroyed, all its children are also disposed or destroyed.
  ///
  /// **Use cases:**
  /// - Organizing related services into logical groups
  /// - Managing lifecycle dependencies between modules
  /// - Creating hierarchical dependency injection structures
  /// - Ensuring proper cleanup of related services
  ///
  /// - `child`: The type or qualifier of the child module to add to the parent.
  /// - `qualifier`: Optional qualifier for the parent module (defaults to the type).
  ///
  /// Example:
  /// ```dart
  /// // Add a child module to a parent
  /// ddi.addChildModules<AppModule>(
  ///   child: DatabaseModule,
  ///   qualifier: 'mainApp',
  /// );
  ///
  /// // When AppModule is disposed, DatabaseModule will also be disposed
  /// await ddi.dispose<AppModule>(qualifier: 'mainApp');
  /// ```
  void addChildModules<BeanT extends Object>({
    required Object child,
    Object? qualifier,
    Object? context,
  }) {
    addChildrenModules<BeanT>(
      child: {child},
      qualifier: qualifier,
      context: context,
    );
  }
}
