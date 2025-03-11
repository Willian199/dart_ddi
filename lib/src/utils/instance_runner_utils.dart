import 'dart:async';

import 'package:dart_ddi/src/exception/concurrent_creation.dart';
import 'package:dart_ddi/src/factories/dart_ddi_base_factory.dart';

final class InstanceRunnerUtils {
  static const _resolutionKey = #_resolutionKey;

  static final Set<Object> _resolutionMap = Zone.current[_resolutionKey] as Set<Object>? ?? {};

  static BeanT run<BeanT extends Object, ParameterT extends Object>({
    required DDIBaseFactory<BeanT> factory,
    required Object effectiveQualifierName,
    ParameterT? parameter,
  }) {
    return runZoned(
      () {
        if (_resolutionMap.contains(effectiveQualifierName)) {
          throw ConcurrentCreationException(effectiveQualifierName.toString());
        }

        _resolutionMap.add(effectiveQualifierName);

        try {
          return factory.getWith<ParameterT>(parameter: parameter, qualifier: effectiveQualifierName);
        } finally {
          _resolutionMap.remove(effectiveQualifierName);
        }
      },
      zoneValues: {_resolutionKey: <Object>{}},
    );
  }

  static Future<BeanT> runAsync<BeanT extends Object, ParameterT extends Object>({
    required DDIBaseFactory<BeanT> factory,
    required Object effectiveQualifierName,
    ParameterT? parameter,
  }) {
    return runZoned(
      () {
        if (_resolutionMap.contains(effectiveQualifierName)) {
          throw ConcurrentCreationException(effectiveQualifierName.toString());
        }

        _resolutionMap.add(effectiveQualifierName);

        return factory.getAsyncWith(parameter: parameter, qualifier: effectiveQualifierName).whenComplete(
          () {
            _resolutionMap.remove(effectiveQualifierName);
          },
        );
      },
      zoneValues: {_resolutionKey: <Object>{}},
    );
  }
}
