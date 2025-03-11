import 'dart:async';

import 'package:dart_ddi/dart_ddi.dart';
import 'package:dart_ddi/src/typedef/typedef.dart';

/// [Instance] is a class that represents a Bean and its state.
/// It is used for the registration of Beans in the [DDI] system.
class Instance<BeanT extends Object> {
  /// Private constructor for [ScopeFactory].
  Instance({
    this.canDestroy = true,
    this.instance,
    this.builder,
    this.decorators,
    this.interceptors,
    this.children,
    this.selector,
  });

  /// The instance of the Bean created by the factory.
  BeanT? instance;

  /// The factory builder responsible for creating the Bean.
  final CustomBuilder<FutureOr<BeanT>>? builder;

  /// A list of decorators that are applied during the Bean creation process.
  ListDecorator<BeanT>? decorators;

  /// A list of interceptors that are called at various stages of the Bean usage.
  Set<Object>? interceptors;

  /// The type of the Bean.
  Type _type = BeanT;

  /// Returns the current Bean type.
  Type get type => _type;

  /// A flag that indicates whether the Bean can be destroyed after its usage.
  final bool canDestroy;

  /// The child objects associated with the Bean, acting as a module.
  Set<Object>? children;

  final FutureOr<bool> Function(Object)? selector;

  /// Casts the current [ScopeFactory] to a new type [NewType].
  void setType<NewType extends Object>() {
    _type = NewType;
  }
}
