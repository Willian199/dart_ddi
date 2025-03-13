import 'dart:async';

import 'package:dart_ddi/src/exception/concurrent_creation.dart';
import 'package:dart_ddi/src/factories/dart_ddi_base_factory.dart';

final class InstanceRunnerUtils {
  static const _resolutionKey = #_resolutionKey;

  static Set<Object> _getResolutionMap() {
    return Zone.current[_resolutionKey] as Set<Object>? ?? {};
  }

  static BeanT run<BeanT extends Object, ParameterT extends Object>({
    required DDIBaseFactory<BeanT> factory,
    required Object effectiveQualifierName,
    ParameterT? parameter,
  }) {
    final resolutionMap = _getResolutionMap();

    if (resolutionMap.contains(effectiveQualifierName)) {
      throw ConcurrentCreationException(effectiveQualifierName.toString());
    }

    // Se não existir resolutionMap na zona atual, crie uma nova zona com um novo mapa
    if (Zone.current[_resolutionKey] == null) {
      return runZoned(
        () => run(
          factory: factory,
          effectiveQualifierName: effectiveQualifierName,
          parameter: parameter,
        ),
        zoneValues: {_resolutionKey: <Object>{}},
      );
    }

    resolutionMap.add(effectiveQualifierName);

    try {
      return factory.getWith<ParameterT>(parameter: parameter, qualifier: effectiveQualifierName);
    } finally {
      resolutionMap.remove(effectiveQualifierName);
    }
  }

  static Future<BeanT> runAsync<BeanT extends Object, ParameterT extends Object>({
    required DDIBaseFactory<BeanT> factory,
    required Object effectiveQualifierName,
    ParameterT? parameter,
  }) async {
    final resolutionMap = _getResolutionMap();

    if (resolutionMap.contains(effectiveQualifierName)) {
      throw ConcurrentCreationException(effectiveQualifierName.toString());
    }

    // Se não existir resolutionMap na zona atual, crie uma nova zona com um novo mapa
    if (Zone.current[_resolutionKey] == null) {
      return runZoned(
        () => runAsync(
          factory: factory,
          effectiveQualifierName: effectiveQualifierName,
          parameter: parameter,
        ),
        zoneValues: {_resolutionKey: <Object>{}},
      );
    }

    resolutionMap.add(effectiveQualifierName);

    try {
      return await factory.getAsyncWith(parameter: parameter, qualifier: effectiveQualifierName);
    } finally {
      resolutionMap.remove(effectiveQualifierName);
    }
  }
}
