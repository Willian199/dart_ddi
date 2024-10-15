import 'dart:async';

import 'package:dart_ddi/dart_ddi.dart';
import 'package:dart_ddi/src/exception/bean_creation.dart';

class InstanceFactoryUtil {
  static BeanT create<BeanT extends Object, ParameterT extends Object>({
    required CustomBuilder<FutureOr<BeanT>> builder,
    ParameterT? parameters,
  }) {
    return switch (builder.producer) {
      final BeanT Function() s => s.call(),
      final BeanT Function(ParameterT) c when parameters != null =>
        c.call(parameters),
      final BeanT Function(ParameterT) c when parameters == null =>
        c.call(ddi.get<ParameterT>()),
      final Function f when parameters != null && parameters is List =>
        Function.apply(f, [...parameters]) as BeanT,
      final Function f when parameters != null =>
        Function.apply(f, [parameters]) as BeanT,
      final Function _ when parameters == null => _autoInject(builder),
      _ => throw BeanCreationException(BeanT.toString())
    };
  }

  static BeanT _autoInject<BeanT extends Object>(
      CustomBuilder<FutureOr<BeanT>> builder) {
    final instances = [
      for (final inject in builder.parametersType) ddi.get(qualifier: inject)
    ];

    return Function.apply(builder.producer, instances) as BeanT;
  }

  static FutureOr<BeanT>
      createAsync<BeanT extends Object, ParameterT extends Object>({
    required CustomBuilder<FutureOr<BeanT>> builder,
    ParameterT? parameters,
  }) async {
    return switch (builder.producer) {
      final FutureOr<BeanT> Function() s => s.call(),
      final FutureOr<BeanT> Function(ParameterT) c when parameters != null =>
        c.call(parameters),
      final FutureOr<BeanT> Function(ParameterT) c when parameters == null =>
        c.call(await ddi.getAsync<ParameterT>()),
      final Function f when parameters != null && parameters is List =>
        Function.apply(f, [...parameters]) as FutureOr<BeanT>,
      final Function f when parameters != null =>
        Function.apply(f, [parameters]) as FutureOr<BeanT>,
      final Function _ when parameters == null => _autoInjectAsync(builder),
      _ => throw BeanCreationException(BeanT.toString())
    };
  }

  static FutureOr<BeanT> _autoInjectAsync<BeanT extends Object>(
      CustomBuilder<FutureOr<BeanT>> builder) async {
    /// Must await inject by inject
    /// If use await Future.wait([]) could create different instance for the same type.
    final instances = [
      for (final inject in builder.parametersType)
        await ddi.getAsync(qualifier: inject)
    ];

    return Function.apply(builder.producer, instances) as BeanT;
  }
}
