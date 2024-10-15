import 'dart:async';

import 'package:dart_ddi/src/core/bean/utils/application_util.dart';
import 'package:dart_ddi/src/core/bean/utils/dart_ddi_utils.dart';
import 'package:dart_ddi/src/core/bean/utils/dependent_utils.dart';
import 'package:dart_ddi/src/data/factory_clazz.dart';
import 'package:dart_ddi/src/enum/scopes.dart';
import 'package:dart_ddi/src/exception/concurrent_creation.dart';

final class ScopeUtils {
  static const _resolutionKey = #_resolutionKey;

  static final Set<Object> _resolutionMap =
      Zone.current[_resolutionKey] as Set<Object>? ?? {};
  static BeanT _getScoped<BeanT extends Object>(
      FactoryClazz<BeanT> factoryClazz, Object effectiveQualifierName) {
    if (_resolutionMap.contains(effectiveQualifierName)) {
      throw ConcurrentCreationException(effectiveQualifierName.toString());
    }

    _resolutionMap.add(effectiveQualifierName);

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
      _resolutionMap.remove(effectiveQualifierName);
    }
  }

  static Future<BeanT> _getScopedAsync<BeanT extends Object>(
      FactoryClazz<BeanT> factoryClazz, Object effectiveQualifierName) async {
    if (_resolutionMap.contains(effectiveQualifierName)) {
      throw ConcurrentCreationException(effectiveQualifierName.toString());
    }

    _resolutionMap.add(effectiveQualifierName);

    try {
      return switch (factoryClazz.scopeType) {
        Scopes.singleton ||
        Scopes.object =>
          await Future.value(DartDDIUtils.getSingleton<BeanT>(
            factoryClazz,
            effectiveQualifierName,
          )),
        Scopes.dependent => await DependentUtils.getDependentAsync<BeanT>(
            factoryClazz,
            effectiveQualifierName,
          ),
        Scopes.application ||
        Scopes.session =>
          await ApplicationUtils.getAplicationAsync<BeanT>(
            factoryClazz,
            effectiveQualifierName,
          )
      };
    } finally {
      _resolutionMap.remove(effectiveQualifierName);
    }
  }

  static BeanT executar<BeanT extends Object>(
      FactoryClazz<BeanT> factoryClazz, Object effectiveQualifierName) {
    return runZoned(
      () {
        return _getScoped<BeanT>(factoryClazz, effectiveQualifierName);
      },
      zoneValues: {_resolutionKey: <Object>{}},
    );
  }

  static Future<BeanT> executarAsync<BeanT extends Object>(
      FactoryClazz<BeanT> factoryClazz, Object effectiveQualifierName) {
    return runZoned(
      () {
        return _getScopedAsync<BeanT>(factoryClazz, effectiveQualifierName);
      },
      zoneValues: {_resolutionKey: <Object>{}},
    );
  }
}
