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
  /// Converts this function into a [CustomBuilder].
  CustomBuilder<BeanT> get builder => CustomBuilder<BeanT>(
        producer: this,
        parametersType: [],
        returnType: BeanT,
        isFuture: this is Future<Object> Function(),
      );

  CustomBuilder<BeanT> get inject => CustomBuilder<BeanT>(
        producer: this,
        parametersType: [],
        returnType: BeanT,
        isFuture: this is Future<Object> Function(),
      );
}

/// Extension for functions with 0 parameters (async)
extension PF0<BeanT extends Object> on Future<BeanT> Function() {
  /// Converts this async function into a [CustomBuilder].
  CustomBuilder<BeanT> get builder => CustomBuilder<BeanT>(
        producer: this,
        parametersType: [],
        returnType: BeanT,
        isFuture: true,
      );

  CustomBuilder<BeanT> get inject => CustomBuilder<BeanT>(
        producer: this,
        parametersType: [],
        returnType: BeanT,
        isFuture: true,
      );
}

/// Extension for functions with 1 parameter (sync)
extension P1<BeanT extends Object, A extends Object> on BeanT Function(A) {
  /// Converts this function into a [CustomBuilder].
  CustomBuilder<BeanT> get builder => CustomBuilder<BeanT>(
        producer: this,
        parametersType: [A],
        returnType: BeanT,
        isFuture: this is Future<Object> Function(A),
      );

  CustomBuilder<BeanT> get inject => CustomBuilder<BeanT>(
        producer: () => this(ddi.get(qualifier: A)),
        parametersType: [],
        returnType: BeanT,
        isFuture: this is Future<Object> Function(A),
      );
}

/// Extension for functions with 1 parameter (async)
extension PF1<BeanT extends Object, A extends Object>
    on Future<BeanT> Function(A) {
  /// Converts this async function into a [CustomBuilder].
  CustomBuilder<BeanT> get builder => CustomBuilder<BeanT>(
        producer: this,
        parametersType: [A],
        returnType: BeanT,
        isFuture: true,
      );

  CustomBuilder<BeanT> get inject => CustomBuilder<BeanT>(
        producer: () async => this(await ddi.getAsync(qualifier: A)),
        parametersType: [],
        returnType: BeanT,
        isFuture: true,
      );
}

/// Extension for functions with 2 parameters (sync)
extension P2<BeanT extends Object, A extends Object, B extends Object>
    on BeanT Function(A, B) {
  /// Converts this function into a [CustomBuilder].
  CustomBuilder<BeanT> get builder => CustomBuilder<BeanT>(
        producer: this,
        parametersType: [A, B],
        returnType: BeanT,
        isFuture: this is Future<Object> Function(A, B),
      );

  CustomBuilder<BeanT> get inject => CustomBuilder<BeanT>(
        producer: () => this(
          ddi.get(qualifier: A),
          ddi.get(qualifier: B),
        ),
        parametersType: [],
        returnType: BeanT,
        isFuture: this is Future<Object> Function(A, B),
      );
}

/// Extension for functions with 2 parameters (async)
extension PF2<BeanT extends Object, A extends Object, B extends Object>
    on Future<BeanT> Function(A, B) {
  /// Converts this async function into a [CustomBuilder].
  CustomBuilder<BeanT> get builder => CustomBuilder<BeanT>(
        producer: this,
        parametersType: [A, B],
        returnType: BeanT,
        isFuture: true,
      );

  CustomBuilder<BeanT> get inject => CustomBuilder<BeanT>(
        producer: () async => this(
          await ddi.getAsync(qualifier: A),
          await ddi.getAsync(qualifier: B),
        ),
        parametersType: [],
        returnType: BeanT,
        isFuture: true,
      );
}

/// Extension for functions with 3 parameters (sync)
extension P3<BeanT extends Object, A extends Object, B extends Object,
    C extends Object> on BeanT Function(A, B, C) {
  /// Converts this function into a [CustomBuilder].
  CustomBuilder<BeanT> get builder => CustomBuilder<BeanT>(
        producer: this,
        parametersType: [A, B, C],
        returnType: BeanT,
        isFuture: this is Future<Object> Function(A, B, C),
      );

  CustomBuilder<BeanT> get inject => CustomBuilder<BeanT>(
        producer: () => this(
          ddi.get(qualifier: A),
          ddi.get(qualifier: B),
          ddi.get(qualifier: C),
        ),
        parametersType: [],
        returnType: BeanT,
        isFuture: this is Future<Object> Function(A, B, C),
      );
}

/// Extension for functions with 3 parameters (async)
extension PF3<BeanT extends Object, A extends Object, B extends Object,
    C extends Object> on Future<BeanT> Function(A, B, C) {
  /// Converts this async function into a [CustomBuilder].
  CustomBuilder<BeanT> get builder => CustomBuilder<BeanT>(
        producer: this,
        parametersType: [A, B, C],
        returnType: BeanT,
        isFuture: true,
      );

  CustomBuilder<BeanT> get inject => CustomBuilder<BeanT>(
        producer: () async => this(
          await ddi.getAsync(qualifier: A),
          await ddi.getAsync(qualifier: B),
          await ddi.getAsync(qualifier: C),
        ),
        parametersType: [],
        returnType: BeanT,
        isFuture: true,
      );
}

/// Extension for functions with 4 parameters (sync)
extension P4<BeanT extends Object, A extends Object, B extends Object,
    C extends Object, D extends Object> on BeanT Function(A, B, C, D) {
  /// Converts this function into a [CustomBuilder].
  CustomBuilder<BeanT> get builder => CustomBuilder<BeanT>(
        producer: this,
        parametersType: [A, B, C, D],
        returnType: BeanT,
        isFuture: this is Future<Object> Function(A, B, C, D),
      );

  CustomBuilder<BeanT> get inject => CustomBuilder<BeanT>(
        producer: () => this(
          ddi.get(qualifier: A),
          ddi.get(qualifier: B),
          ddi.get(qualifier: C),
          ddi.get(qualifier: D),
        ),
        parametersType: [],
        returnType: BeanT,
        isFuture: this is Future<Object> Function(A, B, C, D),
      );
}

/// Extension for functions with 4 parameters (async)
extension PF4<BeanT extends Object, A extends Object, B extends Object,
    C extends Object, D extends Object> on Future<BeanT> Function(A, B, C, D) {
  /// Converts this async function into a [CustomBuilder].
  CustomBuilder<BeanT> get builder => CustomBuilder<BeanT>(
        producer: this,
        parametersType: [A, B, C, D],
        returnType: BeanT,
        isFuture: true,
      );

  CustomBuilder<BeanT> get inject => CustomBuilder<BeanT>(
        producer: () async => this(
          await ddi.getAsync(qualifier: A),
          await ddi.getAsync(qualifier: B),
          await ddi.getAsync(qualifier: C),
          await ddi.getAsync(qualifier: D),
        ),
        parametersType: [],
        returnType: BeanT,
        isFuture: true,
      );
}

/// Extension for functions with 5 parameters (sync)
extension P5<BeanT extends Object, A extends Object, B extends Object,
    C extends Object, D extends Object, E extends Object>
    on BeanT Function(A, B, C, D, E) {
  /// Converts this function into a [CustomBuilder].
  CustomBuilder<BeanT> get builder => CustomBuilder<BeanT>(
        producer: this,
        parametersType: [A, B, C, D, E],
        returnType: BeanT,
        isFuture: this is Future<Object> Function(A, B, C, D, E),
      );

  CustomBuilder<BeanT> get inject => CustomBuilder<BeanT>(
        producer: () => this(
          ddi.get(qualifier: A),
          ddi.get(qualifier: B),
          ddi.get(qualifier: C),
          ddi.get(qualifier: D),
          ddi.get(qualifier: E),
        ),
        parametersType: [],
        returnType: BeanT,
        isFuture: this is Future<Object> Function(A, B, C, D, E),
      );
}

/// Extension for functions with 5 parameters (async)
extension PF5<BeanT extends Object, A extends Object, B extends Object,
    C extends Object, D extends Object, E extends Object>
    on Future<BeanT> Function(A, B, C, D, E) {
  /// Converts this async function into a [CustomBuilder].
  CustomBuilder<BeanT> get builder => CustomBuilder<BeanT>(
        producer: this,
        parametersType: [A, B, C, D, E],
        returnType: BeanT,
        isFuture: true,
      );

  CustomBuilder<BeanT> get inject => CustomBuilder<BeanT>(
        producer: () async => this(
          await ddi.getAsync(qualifier: A),
          await ddi.getAsync(qualifier: B),
          await ddi.getAsync(qualifier: C),
          await ddi.getAsync(qualifier: D),
          await ddi.getAsync(qualifier: E),
        ),
        parametersType: [],
        returnType: BeanT,
        isFuture: true,
      );
}

/// Extension for functions with 6 parameters (sync)
extension P6<BeanT extends Object, A extends Object, B extends Object,
    C extends Object, D extends Object, E extends Object, F extends Object>
    on BeanT Function(A, B, C, D, E, F) {
  /// Converts this function into a [CustomBuilder].
  CustomBuilder<BeanT> get builder => CustomBuilder<BeanT>(
        producer: this,
        parametersType: [A, B, C, D, E, F],
        returnType: BeanT,
        isFuture: this is Future<Object> Function(A, B, C, D, E, F),
      );

  CustomBuilder<BeanT> get inject => CustomBuilder<BeanT>(
        producer: () => this(
          ddi.get(qualifier: A),
          ddi.get(qualifier: B),
          ddi.get(qualifier: C),
          ddi.get(qualifier: D),
          ddi.get(qualifier: E),
          ddi.get(qualifier: F),
        ),
        parametersType: [],
        returnType: BeanT,
        isFuture: this is Future<Object> Function(A, B, C, D, E, F),
      );
}

/// Extension for functions with 6 parameters (async)
extension PF6<BeanT extends Object, A extends Object, B extends Object,
    C extends Object, D extends Object, E extends Object, F extends Object>
    on BeanT Function(A, B, C, D, E, F) {
  /// Converts this async function into a [CustomBuilder].
  CustomBuilder<BeanT> get builder => CustomBuilder<BeanT>(
        producer: this,
        parametersType: [A, B, C, D, E, F],
        returnType: BeanT,
        isFuture: true,
      );

  CustomBuilder<BeanT> get inject => CustomBuilder<BeanT>(
        producer: () => this(
          ddi.get(qualifier: A),
          ddi.get(qualifier: B),
          ddi.get(qualifier: C),
          ddi.get(qualifier: D),
          ddi.get(qualifier: E),
          ddi.get(qualifier: F),
        ),
        parametersType: [],
        returnType: BeanT,
        isFuture: true,
      );
}

/// Extension for functions with 7 parameters (sync)
extension P7<BeanT extends Object, A extends Object, B extends Object,
    C extends Object, D extends Object, E extends Object, F extends Object,
    G extends Object> on BeanT Function(A, B, C, D, E, F, G) {
  /// Converts this function into a [CustomBuilder].
  CustomBuilder<BeanT> get builder => CustomBuilder<BeanT>(
        producer: this,
        parametersType: [A, B, C, D, E, F, G],
        returnType: BeanT,
        isFuture: this is Future<Object> Function(A, B, C, D, E, F, G),
      );

  CustomBuilder<BeanT> get inject => CustomBuilder<BeanT>(
        producer: () => this(
          ddi.get(qualifier: A),
          ddi.get(qualifier: B),
          ddi.get(qualifier: C),
          ddi.get(qualifier: D),
          ddi.get(qualifier: E),
          ddi.get(qualifier: F),
          ddi.get(qualifier: G),
        ),
        parametersType: [],
        returnType: BeanT,
        isFuture: this is Future<Object> Function(A, B, C, D, E, F, G),
      );
}

extension PF7<BeanT extends Object, A extends Object, B extends Object,
    C extends Object, D extends Object, E extends Object, F extends Object,
    G extends Object> on Future<BeanT> Function(A, B, C, D, E, F, G) {  CustomBuilder<BeanT> get builder => CustomBuilder<BeanT>(
        producer: this,
        parametersType: [A, B, C, D, E, F, G],
        returnType: BeanT,
        isFuture: true,
      );

  CustomBuilder<BeanT> get inject => CustomBuilder<BeanT>(
        producer: () async => this(
          await ddi.getAsync(qualifier: A),
          await ddi.getAsync(qualifier: B),
          await ddi.getAsync(qualifier: C),
          await ddi.getAsync(qualifier: D),
          await ddi.getAsync(qualifier: E),
          await ddi.getAsync(qualifier: F),
          await ddi.getAsync(qualifier: G),
        ),
        parametersType: [],
        returnType: BeanT,
        isFuture: true,
      );
}

extension P8<BeanT extends Object, A extends Object, B extends Object,
    C extends Object, D extends Object, E extends Object, F extends Object,
    G extends Object, H extends Object> on BeanT Function(A, B, C, D, E, F, G, H) {  CustomBuilder<BeanT> get builder => CustomBuilder<BeanT>(
        producer: this,
        parametersType: [A, B, C, D, E, F, G, H],
        returnType: BeanT,
        isFuture: this is Future<Object> Function(A, B, C, D, E, F, G, H),
      );

  CustomBuilder<BeanT> get inject => CustomBuilder<BeanT>(
        producer: () => this(
          ddi.get(qualifier: A),
          ddi.get(qualifier: B),
          ddi.get(qualifier: C),
          ddi.get(qualifier: D),
          ddi.get(qualifier: E),
          ddi.get(qualifier: F),
          ddi.get(qualifier: G),
          ddi.get(qualifier: H),
        ),
        parametersType: [],
        returnType: BeanT,
        isFuture: this is Future<Object> Function(A, B, C, D, E, F, G, H),
      );
}

extension PF8<BeanT extends Object, A extends Object, B extends Object,
    C extends Object, D extends Object, E extends Object, F extends Object,
    G extends Object, H extends Object>
    on Future<BeanT> Function(A, B, C, D, E, F, G, H) {  CustomBuilder<BeanT> get builder => CustomBuilder<BeanT>(
        producer: this,
        parametersType: [A, B, C, D, E, F, G, H],
        returnType: BeanT,
        isFuture: true,
      );

  CustomBuilder<BeanT> get inject => CustomBuilder<BeanT>(
        producer: () async => this(
          await ddi.getAsync(qualifier: A),
          await ddi.getAsync(qualifier: B),
          await ddi.getAsync(qualifier: C),
          await ddi.getAsync(qualifier: D),
          await ddi.getAsync(qualifier: E),
          await ddi.getAsync(qualifier: F),
          await ddi.getAsync(qualifier: G),
          await ddi.getAsync(qualifier: H),
        ),
        parametersType: [],
        returnType: BeanT,
        isFuture: true,
      );
}

extension P9<BeanT extends Object, A extends Object, B extends Object,
    C extends Object, D extends Object, E extends Object, F extends Object,
    G extends Object, H extends Object, I extends Object>
    on BeanT Function(A, B, C, D, E, F, G, H, I) {  CustomBuilder<BeanT> get builder => CustomBuilder<BeanT>(
        producer: this,
        parametersType: [A, B, C, D, E, F, G, H, I],
        returnType: BeanT,
        isFuture: this is Future<Object> Function(A, B, C, D, E, F, G, H, I),
      );

  CustomBuilder<BeanT> get inject => CustomBuilder<BeanT>(
        producer: () => this(
          ddi.get(qualifier: A),
          ddi.get(qualifier: B),
          ddi.get(qualifier: C),
          ddi.get(qualifier: D),
          ddi.get(qualifier: E),
          ddi.get(qualifier: F),
          ddi.get(qualifier: G),
          ddi.get(qualifier: H),
          ddi.get(qualifier: I),
        ),
        parametersType: [],
        returnType: BeanT,
        isFuture: this is Future<Object> Function(A, B, C, D, E, F, G, H, I),
      );
}

extension PF9<BeanT extends Object, A extends Object, B extends Object,
    C extends Object, D extends Object, E extends Object, F extends Object,
    G extends Object, H extends Object, I extends Object>
    on Future<BeanT> Function(A, B, C, D, E, F, G, H, I) {  CustomBuilder<BeanT> get builder => CustomBuilder<BeanT>(
        producer: this,
        parametersType: [A, B, C, D, E, F, G, H, I],
        returnType: BeanT,
        isFuture: true,
      );

  CustomBuilder<BeanT> get inject => CustomBuilder<BeanT>(
        producer: () async => this(
          await ddi.getAsync(qualifier: A),
          await ddi.getAsync(qualifier: B),
          await ddi.getAsync(qualifier: C),
          await ddi.getAsync(qualifier: D),
          await ddi.getAsync(qualifier: E),
          await ddi.getAsync(qualifier: F),
          await ddi.getAsync(qualifier: G),
          await ddi.getAsync(qualifier: H),
          await ddi.getAsync(qualifier: I),
        ),
        parametersType: [],
        returnType: BeanT,
        isFuture: true,
      );
}

extension P10<BeanT extends Object, A extends Object, B extends Object,
    C extends Object, D extends Object, E extends Object, F extends Object,
    G extends Object, H extends Object, I extends Object, J extends Object>
    on BeanT Function(A, B, C, D, E, F, G, H, I, J) {  CustomBuilder<BeanT> get builder => CustomBuilder<BeanT>(
        producer: this,
        parametersType: [A, B, C, D, E, F, G, H, I, J],
        returnType: BeanT,
        isFuture: this is Future<Object> Function(A, B, C, D, E, F, G, H, I, J),
      );

  CustomBuilder<BeanT> get inject => CustomBuilder<BeanT>(
        producer: () => this(
          ddi.get(qualifier: A),
          ddi.get(qualifier: B),
          ddi.get(qualifier: C),
          ddi.get(qualifier: D),
          ddi.get(qualifier: E),
          ddi.get(qualifier: F),
          ddi.get(qualifier: G),
          ddi.get(qualifier: H),
          ddi.get(qualifier: I),
          ddi.get(qualifier: J),
        ),
        parametersType: [],
        returnType: BeanT,
        isFuture: this is Future<Object> Function(A, B, C, D, E, F, G, H, I, J),
      );
}

extension PF10<BeanT extends Object, A extends Object, B extends Object,
    C extends Object, D extends Object, E extends Object, F extends Object,
    G extends Object, H extends Object, I extends Object, J extends Object>
    on Future<BeanT> Function(A, B, C, D, E, F, G, H, I, J) {  CustomBuilder<BeanT> get builder => CustomBuilder<BeanT>(
        producer: this,
        parametersType: [A, B, C, D, E, F, G, H, I, J],
        returnType: BeanT,
        isFuture: true,
      );

  CustomBuilder<BeanT> get inject => CustomBuilder<BeanT>(
        producer: () async => this(
          await ddi.getAsync(qualifier: A),
          await ddi.getAsync(qualifier: B),
          await ddi.getAsync(qualifier: C),
          await ddi.getAsync(qualifier: D),
          await ddi.getAsync(qualifier: E),
          await ddi.getAsync(qualifier: F),
          await ddi.getAsync(qualifier: G),
          await ddi.getAsync(qualifier: H),
          await ddi.getAsync(qualifier: I),
          await ddi.getAsync(qualifier: J),
        ),
        parametersType: [],
        returnType: BeanT,
        isFuture: true,
      );
}

