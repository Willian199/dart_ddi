import 'dart:async';

import 'package:dart_ddi/dart_ddi.dart';

mixin InstanceFactoryMixin {
  BeanT createInstance<BeanT extends Object, ParameterT extends Object>({
    required CustomBuilder<FutureOr<BeanT>> builder,
    ParameterT? parameter,
  }) {
    return switch (builder.producer) {
      final BeanT Function() s => s.call(),
      final BeanT Function(ParameterT) c => c.call(parameter ?? ddi.get<ParameterT>()),
      final Function f when parameter != null && parameter is Iterable => Function.apply(f, parameter.toList()) as BeanT,
      final Function f when parameter != null && parameter is Map => Function.apply(f, null, _getMap(parameter)) as BeanT,
      final _ => _autoInject(builder),
    };
  }

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

  BeanT _autoInject<BeanT extends Object>(CustomBuilder<FutureOr<BeanT>> builder) {
    final instances = [for (final inject in builder.parametersType) ddi.get(qualifier: inject)];

    return Function.apply(builder.producer, instances) as BeanT;
  }

  FutureOr<BeanT> createInstanceAsync<BeanT extends Object, ParameterT extends Object>({
    required CustomBuilder<FutureOr<BeanT>> builder,
    ParameterT? parameter,
  }) async {
    return switch (builder.producer) {
      final FutureOr<BeanT> Function() s => s.call(),
      final FutureOr<BeanT> Function(ParameterT) c => c.call(parameter ?? await ddi.getAsync<ParameterT>()),
      final Function f when parameter != null && parameter is Iterable => Function.apply(f, parameter.toList()) as FutureOr<BeanT>,
      final Function f when parameter != null && parameter is Map => Function.apply(f, null, _getMap(parameter)) as FutureOr<BeanT>,
      final _ => _autoInjectAsync(builder),
    };
  }

  FutureOr<BeanT> _autoInjectAsync<BeanT extends Object>(CustomBuilder<FutureOr<BeanT>> builder) async {
    /// Must await inject by inject
    /// If use await Future.wait([]) could create different instance for the same type.
    final instances = [for (final inject in builder.parametersType) await ddi.getAsync(qualifier: inject)];

    return Function.apply(builder.producer, instances) as FutureOr<BeanT>;
  }
}
