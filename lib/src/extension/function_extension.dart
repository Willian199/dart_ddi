import 'dart:async';

import 'package:dart_ddi/dart_ddi.dart';

/// Extensions to easily create [CustomBuilder]s for functions with different numbers of parameters.
///
/// These extensions allow you to convert a function (sync or async) with up to 10 parameters into a [CustomBuilder],
/// which is used by the DDI system to register factories with parameterized constructors or async creation.
///
/// Example:
/// ```dart
/// // For a function with no parameters
/// MyService.new.builder.asApplication();
///
/// // For a function with one parameter
/// ((String name) => MyService(name)).builder.asApplication();
///
/// // For an async function
/// (() async => await MyService.create()).builder.asApplication();
/// ```

/// Extension for functions with 0 parameters (sync)
extension P0<BeanT extends Object> on BeanT Function() {
  /// Returns an empty list, as there are no parameters.
  List<Type> get parameters => [];

  /// Returns the return type of the function.
  Type get returnType => BeanT;

  /// Converts this function into a [CustomBuilder].
  CustomBuilder<BeanT> get builder => CustomBuilder<BeanT>(
        producer: this,
        parametersType: parameters,
        returnType: returnType,
        isFuture: this is Future<Object> Function(),
      );
}

/// Extension for functions with 0 parameters (async)
extension PF0<BeanT extends Object> on Future<BeanT> Function() {
  /// Returns an empty list, as there are no parameters.
  List<Type> get parameters => [];

  /// Returns the return type of the function.
  Type get returnType => BeanT;

  /// Converts this async function into a [CustomBuilder].
  CustomBuilder<BeanT> get builder => CustomBuilder<BeanT>(
        producer: this,
        parametersType: parameters,
        returnType: returnType,
        isFuture: true,
      );
}

/// Extension for functions with 1 parameter (sync)
extension P1<BeanT extends Object, A> on BeanT Function(A) {
  /// Returns a list with the type of the parameter.
  List<Type> get parameters => [A];

  /// Returns the return type of the function.
  Type get returnType => BeanT;

  /// Converts this function into a [CustomBuilder].
  CustomBuilder<BeanT> get builder => CustomBuilder<BeanT>(
        producer: this,
        parametersType: parameters,
        returnType: returnType,
        isFuture: this is Future<Object> Function(A),
      );
}

/// Extension for functions with 1 parameter (async)
extension PF1<BeanT extends Object, A> on Future<BeanT> Function(A) {
  /// Returns a list with the type of the parameter.
  List<Type> get parameters => [A];

  /// Returns the return type of the function.
  Type get returnType => BeanT;

  /// Converts this async function into a [CustomBuilder].
  CustomBuilder<BeanT> get builder => CustomBuilder<BeanT>(
        producer: this,
        parametersType: parameters,
        returnType: returnType,
        isFuture: true,
      );
}

/// Extension for functions with 2 parameters (sync)
extension P2<BeanT extends Object, A, B> on BeanT Function(A, B) {
  /// Returns a list with the types of the parameters.
  List<Type> get parameters => [A, B];

  /// Returns the return type of the function.
  Type get returnType => BeanT;

  /// Converts this function into a [CustomBuilder].
  CustomBuilder<BeanT> get builder => CustomBuilder<BeanT>(
        producer: this,
        parametersType: parameters,
        returnType: returnType,
        isFuture: this is Future<Object> Function(A, B),
      );
}

/// Extension for functions with 2 parameters (async)
extension PF2<BeanT extends Object, A, B> on Future<BeanT> Function(A, B) {
  /// Returns a list with the types of the parameters.
  List<Type> get parameters => [A, B];

  /// Returns the return type of the function.
  Type get returnType => BeanT;

  /// Converts this async function into a [CustomBuilder].
  CustomBuilder<BeanT> get builder => CustomBuilder<BeanT>(
        producer: this,
        parametersType: parameters,
        returnType: returnType,
        isFuture: true,
      );
}

/// Extension for functions with 3 parameters (sync)
extension P3<BeanT extends Object, A, B, C> on BeanT Function(A, B, C) {
  /// Returns a list with the types of the parameters.
  List<Type> get parameters => [A, B, C];

  /// Returns the return type of the function.
  Type get returnType => BeanT;

  /// Converts this function into a [CustomBuilder].
  CustomBuilder<BeanT> get builder => CustomBuilder<BeanT>(
        producer: this,
        parametersType: parameters,
        returnType: returnType,
        isFuture: this is Future<Object> Function(A, B, C),
      );
}

/// Extension for functions with 3 parameters (async)
extension PF3<BeanT extends Object, A, B, C> on Future<BeanT> Function(
    A, B, C) {
  /// Returns a list with the types of the parameters.
  List<Type> get parameters => [A, B, C];

  /// Returns the return type of the function.
  Type get returnType => BeanT;

  /// Converts this async function into a [CustomBuilder].
  CustomBuilder<BeanT> get builder => CustomBuilder<BeanT>(
        producer: this,
        parametersType: parameters,
        returnType: returnType,
        isFuture: true,
      );
}

/// Extension for functions with 4 parameters (sync)
extension P4<BeanT extends Object, A, B, C, D> on BeanT Function(A, B, C, D) {
  /// Returns a list with the types of the parameters.
  List<Type> get parameters => [A, B, C, D];

  /// Returns the return type of the function.
  Type get returnType => BeanT;

  /// Converts this function into a [CustomBuilder].
  CustomBuilder<BeanT> get builder => CustomBuilder<BeanT>(
        producer: this,
        parametersType: parameters,
        returnType: returnType,
        isFuture: this is Future<Object> Function(A, B, C, D),
      );
}

/// Extension for functions with 4 parameters (async)
extension PF4<BeanT extends Object, A, B, C, D> on Future<BeanT> Function(
    A, B, C, D) {
  /// Returns a list with the types of the parameters.
  List<Type> get parameters => [A, B, C, D];

  /// Returns the return type of the function.
  Type get returnType => BeanT;

  /// Converts this async function into a [CustomBuilder].
  CustomBuilder<BeanT> get builder => CustomBuilder<BeanT>(
        producer: this,
        parametersType: parameters,
        returnType: returnType,
        isFuture: true,
      );
}

/// Extension for functions with 5 parameters (sync)
extension P5<BeanT extends Object, A, B, C, D, E> on BeanT Function(
    A, B, C, D, E) {
  /// Returns a list with the types of the parameters.
  List<Type> get parameters => [A, B, C, D, E];

  /// Returns the return type of the function.
  Type get returnType => BeanT;

  /// Converts this function into a [CustomBuilder].
  CustomBuilder<BeanT> get builder => CustomBuilder<BeanT>(
        producer: this,
        parametersType: parameters,
        returnType: returnType,
        isFuture: this is Future<Object> Function(A, B, C, D, E),
      );
}

/// Extension for functions with 5 parameters (async)
extension PF5<BeanT extends Object, A, B, C, D, E> on Future<BeanT> Function(
    A, B, C, D, E) {
  /// Returns a list with the types of the parameters.
  List<Type> get parameters => [A, B, C, D, E];

  /// Returns the return type of the function.
  Type get returnType => BeanT;

  /// Converts this async function into a [CustomBuilder].
  CustomBuilder<BeanT> get builder => CustomBuilder<BeanT>(
        producer: this,
        parametersType: parameters,
        returnType: returnType,
        isFuture: true,
      );
}

/// Extension for functions with 6 parameters (sync)
extension P6<BeanT extends Object, A, B, C, D, E, F> on BeanT Function(
    A, B, C, D, E, F) {
  /// Returns a list with the types of the parameters.
  List<Type> get parameters => [A, B, C, D, E, F];

  /// Returns the return type of the function.
  Type get returnType => BeanT;

  /// Converts this function into a [CustomBuilder].
  CustomBuilder<BeanT> get builder => CustomBuilder<BeanT>(
        producer: this,
        parametersType: parameters,
        returnType: returnType,
        isFuture: this is Future<Object> Function(A, B, C, D, E, F),
      );
}

/// Extension for functions with 6 parameters (async)
extension PF6<BeanT extends Object, A, B, C, D, E, F> on BeanT Function(
    A, B, C, D, E, F) {
  /// Returns a list with the types of the parameters.
  List<Type> get parameters => [A, B, C, D, E, F];

  /// Returns the return type of the function.
  Type get returnType => BeanT;

  /// Converts this async function into a [CustomBuilder].
  CustomBuilder<BeanT> get builder => CustomBuilder<BeanT>(
        producer: this,
        parametersType: parameters,
        returnType: returnType,
        isFuture: true,
      );
}

/// Extension for functions with 7 parameters (sync)
extension P7<BeanT extends Object, A, B, C, D, E, F, G> on BeanT Function(
    A, B, C, D, E, F, G) {
  /// Returns a list with the types of the parameters.
  List<Type> get parameters => [A, B, C, D, E, F, G];

  /// Returns the return type of the function.
  Type get returnType => BeanT;

  /// Converts this function into a [CustomBuilder].
  CustomBuilder<BeanT> get builder => CustomBuilder<BeanT>(
        producer: this,
        parametersType: parameters,
        returnType: returnType,
        isFuture: this is Future<Object> Function(A, B, C, D, E, F, G),
      );
}

extension PF7<BeanT extends Object, A, B, C, D, E, F, G> on Future<BeanT>
    Function(A, B, C, D, E, F, G) {
  List<Type> get parameters => [A, B, C, D, E, F, G];
  Type get returnType => BeanT;
  CustomBuilder<BeanT> get builder => CustomBuilder<BeanT>(
        producer: this,
        parametersType: parameters,
        returnType: returnType,
        isFuture: true,
      );
}

extension P8<BeanT extends Object, A, B, C, D, E, F, G, H> on BeanT Function(
    A, B, C, D, E, F, G, H) {
  List<Type> get parameters => [A, B, C, D, E, F, G, H];
  Type get returnType => BeanT;
  CustomBuilder<BeanT> get builder => CustomBuilder<BeanT>(
        producer: this,
        parametersType: parameters,
        returnType: returnType,
        isFuture: this is Future<Object> Function(A, B, C, D, E, F, G, H),
      );
}

extension PF8<BeanT extends Object, A, B, C, D, E, F, G, H> on Future<BeanT>
    Function(A, B, C, D, E, F, G, H) {
  List<Type> get parameters => [A, B, C, D, E, F, G, H];
  Type get returnType => BeanT;
  CustomBuilder<BeanT> get builder => CustomBuilder<BeanT>(
        producer: this,
        parametersType: parameters,
        returnType: returnType,
        isFuture: true,
      );
}

extension P9<BeanT extends Object, A, B, C, D, E, F, G, H, I> on BeanT Function(
    A, B, C, D, E, F, G, H, I) {
  List<Type> get parameters => [A, B, C, D, E, F, G, H, I];
  Type get returnType => BeanT;
  CustomBuilder<BeanT> get builder => CustomBuilder<BeanT>(
        producer: this,
        parametersType: parameters,
        returnType: returnType,
        isFuture: this is Future<Object> Function(A, B, C, D, E, F, G, H, I),
      );
}

extension PF9<BeanT extends Object, A, B, C, D, E, F, G, H, I> on Future<BeanT>
    Function(A, B, C, D, E, F, G, H, I) {
  List<Type> get parameters => [A, B, C, D, E, F, G, H, I];
  Type get returnType => BeanT;
  CustomBuilder<BeanT> get builder => CustomBuilder<BeanT>(
        producer: this,
        parametersType: parameters,
        returnType: returnType,
        isFuture: true,
      );
}

extension P10<BeanT extends Object, A, B, C, D, E, F, G, H, I, J> on BeanT
    Function(A, B, C, D, E, F, G, H, I, J) {
  List<Type> get parameters => [A, B, C, D, E, F, G, H, I, J];
  Type get returnType => BeanT;
  CustomBuilder<BeanT> get builder => CustomBuilder<BeanT>(
        producer: this,
        parametersType: parameters,
        returnType: returnType,
        isFuture: this is Future<Object> Function(A, B, C, D, E, F, G, H, I, J),
      );
}

extension PF10<BeanT extends Object, A, B, C, D, E, F, G, H, I, J>
    on Future<BeanT> Function(A, B, C, D, E, F, G, H, I, J) {
  List<Type> get parameters => [A, B, C, D, E, F, G, H, I, J];
  Type get returnType => BeanT;
  CustomBuilder<BeanT> get builder => CustomBuilder<BeanT>(
        producer: this,
        parametersType: parameters,
        returnType: returnType,
        isFuture: true,
      );
}
