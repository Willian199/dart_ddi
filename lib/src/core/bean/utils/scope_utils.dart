import 'dart:async';

import 'package:dart_ddi/src/core/bean/utils/application_util.dart';
import 'package:dart_ddi/src/core/bean/utils/dart_ddi_utils.dart';
import 'package:dart_ddi/src/core/bean/utils/dependent_utils.dart';
import 'package:dart_ddi/src/data/factory_clazz.dart';
import 'package:dart_ddi/src/enum/scopes.dart';
import 'package:dart_ddi/src/exception/circular_detection.dart';

final class ScopeUtils {
  static const _resolutionKey = #_resolutionKey;

  static final Map<Object, List<Object>> _resolutionMap =
      Zone.current[_resolutionKey] as Map<Object, List<Object>>? ?? {};
  static BeanT _getScoped<BeanT extends Object>(
      FactoryClazz<BeanT> factoryClazz, Object effectiveQualifierName) {
    if (_resolutionMap[effectiveQualifierName]?.isNotEmpty ?? false) {
      throw CircularDetectionException(effectiveQualifierName.toString());
    }

    _resolutionMap[effectiveQualifierName] = [
      ..._resolutionMap[effectiveQualifierName] ?? [],
      effectiveQualifierName
    ];

    try {
      return switch (factoryClazz.scopeType) {
        Scopes.singleton || Scopes.object => DartDDIUtils.getSingleton<BeanT>(
            factoryClazz,
            effectiveQualifierName,
          ),
        Scopes.dependent => DependentUtils.getDependent<BeanT>(
            factoryClazz,
            effectiveQualifierName,
          ),
        Scopes.application ||
        Scopes.session =>
          ApplicationUtils.getAplication<BeanT>(
            factoryClazz,
            effectiveQualifierName,
          )
      };
    } finally {
      _resolutionMap[effectiveQualifierName]?.removeLast();
    }
  }

  static Future<BeanT> _getScopedAsync<BeanT extends Object>(
      FactoryClazz<BeanT> factoryClazz, Object effectiveQualifierName) {
    if (_resolutionMap[effectiveQualifierName]?.isNotEmpty ?? false) {
      throw CircularDetectionException(effectiveQualifierName.toString());
    }

    _resolutionMap[effectiveQualifierName] = [
      ..._resolutionMap[effectiveQualifierName] ?? [],
      effectiveQualifierName
    ];

    try {
      return switch (factoryClazz.scopeType) {
        Scopes.singleton ||
        Scopes.object =>
          Future.value(DartDDIUtils.getSingleton<BeanT>(
            factoryClazz,
            effectiveQualifierName,
          )),
        Scopes.dependent => DependentUtils.getDependentAsync<BeanT>(
            factoryClazz,
            effectiveQualifierName,
          ),
        Scopes.application ||
        Scopes.session =>
          ApplicationUtils.getAplicationAsync<BeanT>(
            factoryClazz,
            effectiveQualifierName,
          )
      };
    } finally {
      _resolutionMap[effectiveQualifierName]?.removeLast();
    }
  }

  static BeanT executar<BeanT extends Object>(
      FactoryClazz<BeanT> factoryClazz, Object effectiveQualifierName) {
    return runZoned(
      () {
        return _getScoped<BeanT>(factoryClazz, effectiveQualifierName);
      },
      zoneValues: {_resolutionKey: <Object, List<Object>>{}},
    );
  }

  static Future<BeanT> executarAsync<BeanT extends Object>(
      FactoryClazz<BeanT> factoryClazz, Object effectiveQualifierName) {
    return runZoned(
      () {
        return _getScopedAsync<BeanT>(factoryClazz, effectiveQualifierName);
      },
      zoneValues: {_resolutionKey: <Object, List<Object>>{}},
    );
  }
}
