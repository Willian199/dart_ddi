import 'dart:async';

import 'package:dart_ddi/dart_ddi.dart';
import 'package:dart_ddi/src/typedef/typedef.dart';

/// [CustomBuilder] is a class that represents how a Bean should be created.
/// It is used to create a Bean after the registration in the [DDI] system.
final class CustomBuilder<BeanT extends Object> {
  /// Constructor that initializes the [CustomBuilder] with the given parameters.
  ///
  /// - `producer`: The function that will be used to create the Bean.
  /// - `parametersType`: A list of types representing the parameters required to create the Bean.
  /// - `returnType`: The type of the Bean that will be returned.
  /// - `isFuture`: A flag indicating if the creation of the Bean will be asynchronous (returns a Future).
  const CustomBuilder({
    required this.producer,
    required this.parametersType,
    required this.returnType,
    required this.isFuture,
  });

  factory CustomBuilder.of(BeanT Function() producer) => CustomBuilder<BeanT>(
        producer: producer,
        parametersType: [],
        returnType: BeanT,
        isFuture: false,
      );

  factory CustomBuilder.ofFuture(FutureOr<BeanT> Function() producer) =>
      CustomBuilder<BeanT>(
        producer: producer,
        parametersType: [],
        returnType: BeanT,
        isFuture: true,
      );

  /// The function that will be used to create the Bean.
  final Function producer;

  /// A list of parameter types that the Bean's creation function require.
  final List<Type> parametersType;

  /// The type of the Bean that will be returned.
  final Type returnType;

  /// Indicates if the Bean creation is asynchronous, meaning it returns a Future.
  final bool isFuture;

  /// Creates a Bean with an Application scope.
  ///
  /// - `decorators`: A list of decorators to modify the Bean before it is returned.
  /// - `canDestroy`: Optional parameter to make the instance indestructible.
  /// - `children`: A set of child objects associated with the Bean.
  /// - `selector`: Optional function that allows conditional selection of instances based on specific criteria. Useful for dynamically choosing an instance at runtime based on application context.
  /// - `qualifier`: Optional qualifier name to distinguish between different instances of the same type.
  /// - `canRegister`: Optional function to conditionally register the instance.
  /// - `required`: Optional set of qualifiers or types that must be registered before creating an instance.
  Future<void> asApplication({
    ListDecorator<BeanT> decorators = const [],
    bool canDestroy = true,
    Set<Object> children = const {},
    FutureOr<bool> Function(Object)? selector,
    Object? qualifier,
    FutureOr<bool> Function()? canRegister,
    Set<Object>? required,
  }) {
    return DDI.instance.register<BeanT>(
      factory: ApplicationFactory<BeanT>(
        builder: this,
        decorators: decorators,
        canDestroy: canDestroy,
        children: children,
        selector: selector,
        required: required,
      ),
      qualifier: qualifier,
      canRegister: canRegister,
    );
  }

  /// Creates a Bean with a Dependent scope.
  ///
  /// - `decorators`: A list of decorators to modify the Bean before it is returned.
  /// - `canDestroy`: Optional parameter to make the instance indestructible.
  /// - `children`: A set of child objects associated with the Bean.
  /// - `selector`: Optional function that allows conditional selection of instances based on specific criteria. Useful for dynamically choosing an instance at runtime based on application context.
  /// - `qualifier`: Optional qualifier name to distinguish between different instances of the same type.
  /// - `canRegister`: Optional function to conditionally register the instance.
  /// - `required`: Optional set of qualifiers or types that must be registered before creating an instance.
  Future<void> asDependent({
    ListDecorator<BeanT> decorators = const [],
    bool canDestroy = true,
    Set<Object> children = const {},
    FutureOr<bool> Function(Object)? selector,
    Object? qualifier,
    FutureOr<bool> Function()? canRegister,
    Set<Object>? required,
  }) {
    return DDI.instance.register<BeanT>(
      factory: DependentFactory<BeanT>(
        builder: this,
        decorators: decorators,
        canDestroy: canDestroy,
        children: children,
        selector: selector,
        required: required,
      ),
      qualifier: qualifier,
      canRegister: canRegister,
    );
  }

  /// Creates a Bean with a Singleton scope.
  ///
  /// - `decorators`: A list of decorators to modify the Bean before it is returned.
  /// - `canDestroy`: Optional parameter to make the instance indestructible.
  /// - `children`: A set of child objects associated with the Bean.
  /// - `selector`: Optional function that allows conditional selection of instances based on specific criteria. Useful for dynamically choosing an instance at runtime based on application context.
  /// - `qualifier`: Optional qualifier name to distinguish between different instances of the same type.
  /// - `canRegister`: Optional function to conditionally register the instance.
  /// - `required`: Optional set of qualifiers or types that must be registered before creating an instance.
  Future<void> asSingleton({
    ListDecorator<BeanT> decorators = const [],
    bool canDestroy = true,
    Set<Object> children = const {},
    FutureOr<bool> Function(Object)? selector,
    Object? qualifier,
    FutureOr<bool> Function()? canRegister,
    Set<Object>? required,
  }) {
    return DDI.instance.register<BeanT>(
      factory: SingletonFactory<BeanT>(
        builder: this,
        decorators: decorators,
        canDestroy: canDestroy,
        children: children,
        selector: selector,
        required: required,
      ),
      qualifier: qualifier,
      canRegister: canRegister,
    );
  }
}
