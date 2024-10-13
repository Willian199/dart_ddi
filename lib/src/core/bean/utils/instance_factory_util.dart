import 'dart:async';

import 'package:dart_ddi/dart_ddi.dart';

class InstanceFactoryUtil {
  static BeanT create<BeanT extends Object, ParameterT extends Object>({
    required CustomFactory<FutureOr<BeanT>> clazzFactory,
    ParameterT? parameters,
  }) {
    return switch (clazzFactory.clazzRegister) {
      final BeanT Function() s => s.call(),
      final BeanT Function(ParameterT) c when parameters != null =>
        c.call(parameters),
      final BeanT Function(ParameterT) c when parameters == null =>
        c.call(ddi.get(qualifier: clazzFactory.parametersType.first)),
      final Function f when parameters != null && parameters is List =>
        Function.apply(f, [...parameters]) as BeanT,
      final Function f when parameters != null =>
        Function.apply(f, [parameters]) as BeanT,
      final Function _ when parameters == null => _autoInject(clazzFactory),
      _ => throw Exception("erro")
    };
  }

  static BeanT _autoInject<BeanT extends Object>(
      CustomFactory<FutureOr<BeanT>> clazzFactory) {
    final instances = [
      for (final inject in clazzFactory.parametersType)
        ddi.get(qualifier: inject)
    ];

    return Function.apply(clazzFactory.clazzRegister, instances) as BeanT;
  }

  static FutureOr<BeanT>
      createAsync<BeanT extends Object, ParameterT extends Object>({
    required CustomFactory<FutureOr<BeanT>> clazzFactory,
    ParameterT? parameters,
  }) {
    return switch (clazzFactory.clazzRegister) {
      final FutureOr<BeanT> Function() s => s.call(),
      final FutureOr<BeanT> Function(ParameterT) c when parameters != null =>
        c.call(parameters),
      final FutureOr<BeanT> Function(ParameterT) c when parameters == null =>
        c.call(ddi.get<ParameterT>()),
      final Function f when parameters != null && parameters is List =>
        Function.apply(f, [...parameters]) as FutureOr<BeanT>,
      final Function f when parameters != null =>
        Function.apply(f, [parameters]) as FutureOr<BeanT>,
      final Function _ when parameters == null =>
        _autoInjectAsync(clazzFactory),
      _ => throw Exception("erro")
    };
  }

  static FutureOr<BeanT> _autoInjectAsync<BeanT extends Object>(
      CustomFactory<FutureOr<BeanT>> clazzFactory) async {
    /// Must await inject by inject
    /// If use await Future.wait([]) could create different instance for the same type.
    final instances = [
      for (final inject in clazzFactory.parametersType)
        await ddi.getAsync(qualifier: inject)
    ];

    return Function.apply(clazzFactory.clazzRegister, instances) as BeanT;
  }
}
