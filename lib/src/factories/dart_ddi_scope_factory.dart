import 'dart:async';

import 'package:dart_ddi/dart_ddi.dart';
import 'package:dart_ddi/src/typedef/typedef.dart';

/// Abstract base class for DDI scope factories that support decorators, interceptors, and child modules.
///
/// This class extends [DDIBaseFactory] and adds functionality for:
/// - Dynamic decorator addition
/// - Interceptor management
/// - Child module management
/// - Scope-specific lifecycle management
abstract class DDIScopeFactory<BeanT extends Object>
    extends DDIBaseFactory<BeanT> {
  /// Creates a new [DDIScopeFactory] with an optional selector function.
  DDIScopeFactory({super.selector});

  /// Dynamically adds decorators to this Bean.
  ///
  /// This method allows you to add decorators to an existing Bean after it has been registered.
  /// Decorators are applied in the order they are provided and will affect new instances.
  ///
  /// **Important considerations:**
  /// - **Order of Execution:** Decorators are applied in the order they are provided.
  /// - **Instances Already Retrieved:** No changes to instances that have been retrieved.
  ///
  /// - `newDecorators`: List of decorator functions to add to this factory.
  FutureOr<void> addDecorator(ListDecorator<BeanT> newDecorators);

  /// Dynamically adds interceptors to this Bean.
  ///
  /// This method allows you to add interceptors to an existing Bean after it has been registered.
  /// Interceptors are applied in the order they are provided and will affect new instances.
  ///
  /// **Important considerations:**
  /// - **Order of Execution:** Interceptors are applied in the order they are provided.
  /// - **Instances Already Retrieved:** No changes to instances that have been retrieved.
  ///
  /// - `newInterceptors`: Set of interceptor qualifiers or classes to add to this factory.
  void addInterceptor(Set<Object> newInterceptors);

  /// Adds multiple child modules to this parent module.
  ///
  /// This method establishes parent-child relationships between modules, allowing the parent
  /// to manage the lifecycle of its children. When the parent is disposed or destroyed,
  /// all its children are also disposed or destroyed (If the Scope permit).
  ///
  /// - `child`: Set of child module types or qualifiers to add to this parent module.
  void addChildrenModules(Set<Object> child);

  /// Gets the set of child modules for this parent module.
  ///
  /// Returns all child modules that have been registered under this parent module.
  /// This is useful for discovering the module hierarchy and managing child modules.
  Set<Object> get children;
}
