import 'dart:async';

import 'package:dart_ddi/dart_ddi.dart';

/// Mixin that provides logic for creating instances of beans, including automatic dependency injection.
///
/// This mixin is used by factories to instantiate objects, supporting parameterized constructors, positional and named parameters,
/// and automatic injection of dependencies based on the types required by the constructor.
///
/// Example:
/// ```dart
/// class MyFactory with InstanceFactoryMixin {
///   // ...
/// }
/// ```
///
/// The [createInstance] method will attempt to resolve parameters automatically from the DDI container if not provided.
///
/// - If the constructor requires a parameter and none is provided, it will try to resolve it from DDI.
/// - If the parameter is an Iterable or Map, it will use [Function.apply] to pass them.
/// - If no parameters are required, it will call the default constructor.
///
/// The [_autoInject] method is used internally to resolve all required types from the DDI container.
mixin InstanceFactoryMixin {
  /// Creates an instance of [BeanT] using the provided [CustomBuilder] and optional [parameter].
  ///
  /// - If the function matches the parameter signature, it is called directly.
  /// - If the parameter is an Iterable or Map, it is passed using [Function.apply].
  /// - If no parameter is provided, it attempts to auto-inject dependencies from DDI.
  ///
  /// Example:
  /// ```dart
  /// final instance = createInstance<MyService, String>(builder: myBuilder, parameter: 'name');
  /// ```
  BeanT createInstance<BeanT extends Object, ParameterT extends Object>({
    required CustomBuilder<FutureOr<BeanT>> builder,
    required DDI ddiInstance,
    ParameterT? parameter,
  }) {
    return switch (builder.producer) {
      final BeanT Function() s => s.call(),
      final BeanT Function(ParameterT) c =>
        c.call(parameter ?? ddiInstance.get<ParameterT>()),
      final Function f when parameter != null && parameter is Iterable =>
        Function.apply(f, parameter.toList()) as BeanT,
      final Function f when parameter != null && parameter is Map =>
        Function.apply(f, null, _getMap(parameter)) as BeanT,
      final _ => _autoInject(builder: builder, ddiInstance: ddiInstance),
    };
  }

  /// Converts a [Map] to [Map<Symbol, dynamic>] for named parameter injection.
  /// Throws an assertion error if the map is not of the correct type.
  // ignore: strict_raw_type
  Map<Symbol, dynamic> _getMap<BeanT extends Object>(Map map) {
    assert(map is Map<Symbol, dynamic>, '''
When creating the instance with a Map type, it must be Map<Symbol, dynamic>
Ex:
<Symbol, dynamic>{
  #first: ddi.get(qualifier: 'first'),
  #second: SecondValue(),
}
''');

    return map as Map<Symbol, dynamic>;
  }

  /// Automatically injects dependencies for the parameters required by the [builder].
  ///
  /// This method will resolve all types listed in [builder.parametersType] from the DDI container
  /// and call the producer function with those instances.
  ///
  /// Example:
  /// ```dart
  /// // If builder.parametersType == [A, B], this will call builder.producer(ddi.get<A>(), ddi.get<B>())
  /// ```
  BeanT _autoInject<BeanT extends Object>({
    required CustomBuilder<FutureOr<BeanT>> builder,
    required DDI ddiInstance,
  }) {
    final instances = [
      for (final inject in builder.parametersType)
        ddiInstance.get(qualifier: inject)
    ];

    return Function.apply(builder.producer, instances) as BeanT;
  }

  FutureOr<BeanT>
      createInstanceAsync<BeanT extends Object, ParameterT extends Object>({
    required CustomBuilder<FutureOr<BeanT>> builder,
    required DDI ddiInstance,
    ParameterT? parameter,
  }) async {
    return switch (builder.producer) {
      final FutureOr<BeanT> Function() s => s.call(),
      final FutureOr<BeanT> Function(ParameterT) c =>
        c.call(parameter ?? await ddiInstance.getAsync<ParameterT>()),
      final Function f when parameter != null && parameter is Iterable =>
        Function.apply(f, parameter.toList()) as FutureOr<BeanT>,
      final Function f when parameter != null && parameter is Map =>
        Function.apply(f, null, _getMap(parameter)) as FutureOr<BeanT>,
      final _ => _autoInjectAsync(builder: builder, ddiInstance: ddiInstance),
    };
  }

  FutureOr<BeanT> _autoInjectAsync<BeanT extends Object>({
    required CustomBuilder<FutureOr<BeanT>> builder,
    required DDI ddiInstance,
  }) async {
    /// Must await each injection individually.
    /// If using await Future.wait([]) could create different instances for the same type.
    final instances = [
      for (final inject in builder.parametersType)
        await ddiInstance.getAsync(qualifier: inject)
    ];

    return Function.apply(builder.producer, instances) as FutureOr<BeanT>;
  }
}
