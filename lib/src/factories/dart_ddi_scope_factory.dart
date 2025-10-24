import 'dart:async';

import 'package:dart_ddi/dart_ddi.dart';
import 'package:dart_ddi/src/typedef/typedef.dart';

abstract class DDIScopeFactory<BeanT extends Object>
    extends DDIBaseFactory<BeanT> {
  DDIScopeFactory({super.selector});

  /// Allows to dynamically add a Decorators.
  ///
  /// When using this method, consider the following:
  ///
  /// - **Order of Execution:** Decorators are applied in the order they are provided.
  /// - **Instaces Already Gets:** No changes any Instances that have been get.
  FutureOr<void> addDecorator(ListDecorator<BeanT> newDecorators);

  /// Allows to dynamically add a Interceptor.
  ///
  /// When using this method, consider the following:
  ///
  /// - **Order of Execution:** Interceptor are applied in the order they are provided.
  /// - **Instaces Already Gets:** No changes any Instances that have been get.
  void addInterceptor(Set<Object> newInterceptors);

  /// This function adds multiple child modules to a parent module.
  /// It takes a list of 'child' objects and an optional 'qualifier' for the parent module.
  void addChildrenModules(Set<Object> child);

  /// This function returns a set of child modules for a parent module.
  Set<Object> get children;
}
