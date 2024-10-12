import 'dart:async';

import 'package:dart_ddi/dart_ddi.dart';

class InstanceFactoryUtil {
  static BeanT create<BeanT extends Object, ParameterT extends Object>({
    required Function clazzRegister,
    ParameterT? parameters,
  }) {
    return switch (clazzRegister) {
      final BeanT Function() s => s.call(),
      final BeanT Function(ParameterT) c when parameters != null => c.call(parameters),
      final BeanT Function(ParameterT) c when parameters == null => c.call(ddi.get<ParameterT>()),
      final Function f when parameters != null && parameters is List => Function.apply(f, [...parameters]) as BeanT,
      final Function f when parameters != null => Function.apply(f, [parameters]) as BeanT,
      final Function f when parameters == null => _findType(clazzRegister: f),
      _ => throw Exception("erro")
    };
  }

  static BeanT _findType<BeanT extends Object>({
    required Function clazzRegister,
  }) {
    final List<String> injects =
        RegExp(r'\((.*?)\)\s*=>').firstMatch(clazzRegister.runtimeType.toString())!.group(1)?.trim().replaceAll(' ', '').split(',') ?? [];

    return Function.apply(clazzRegister, [for (final inject in injects) ddi.get(qualifier: inject)]) as BeanT;
  }

  static FutureOr<BeanT> createAsync<BeanT extends Object, ParameterT extends Object>({
    required Function clazzRegister,
    ParameterT? parameters,
  }) {
    return switch (clazzRegister) {
      final FutureOr<BeanT> Function() s => s.call(),
      final FutureOr<BeanT> Function(ParameterT) c when parameters != null => c.call(parameters),
      final FutureOr<BeanT> Function(ParameterT) c when parameters == null => c.call(ddi.get<ParameterT>()),
      final Function f when parameters != null && parameters is List => Function.apply(f, [...parameters]) as FutureOr<BeanT>,
      final Function f when parameters != null => Function.apply(f, [parameters]) as FutureOr<BeanT>,
      final Function f when parameters == null => _findTypeAsync(clazzRegister: f),
      _ => throw Exception("erro")
    };
  }

  static FutureOr<BeanT> _findTypeAsync<BeanT extends Object>({
    required Function clazzRegister,
  }) async {
    final List<String> injects =
        RegExp(r'\((.*?)\)\s*=>').firstMatch(clazzRegister.runtimeType.toString())!.group(1)?.trim().replaceAll(' ', '').split(',') ?? [];

    return Function.apply(
            clazzRegister, [for (final inject in injects) await ddi.getAsync(qualifier: inject.replaceAll('Future<', '').replaceAll('>', ''))])
        as FutureOr<BeanT>;
  }
}
