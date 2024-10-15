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
      ScopeFactory<BeanT> factory, Object effectiveQualifierName) {
    if (_resolutionMap.contains(effectiveQualifierName)) {
      throw ConcurrentCreationException(effectiveQualifierName.toString());
    }

    _resolutionMap.add(effectiveQualifierName);

    try {
      return switch (factory.scopeType) {
        Scopes.singleton || Scopes.object => DartDDIUtils.getSingleton<BeanT>(
            factory,
            effectiveQualifierName,
          ),
        Scopes.dependent => DependentUtils.getDependent<BeanT>(
            factory,
            effectiveQualifierName,
          ),
        Scopes.application ||
        Scopes.session =>
          ApplicationUtils.getAplication<BeanT>(
            factory,
            effectiveQualifierName,
          )
      };
    } finally {
      _resolutionMap.remove(effectiveQualifierName);
    }
  }

  static Future<BeanT> _getScopedAsync<BeanT extends Object>(
      ScopeFactory<BeanT> factory, Object effectiveQualifierName) async {
    if (_resolutionMap.contains(effectiveQualifierName)) {
      throw ConcurrentCreationException(effectiveQualifierName.toString());
    }

    _resolutionMap.add(effectiveQualifierName);

    try {
      return switch (factory.scopeType) {
        Scopes.singleton ||
        Scopes.object =>
          await Future.value(DartDDIUtils.getSingleton<BeanT>(
            factory,
            effectiveQualifierName,
          )),
        Scopes.dependent => await DependentUtils.getDependentAsync<BeanT>(
            factory,
            effectiveQualifierName,
          ),
        Scopes.application ||
        Scopes.session =>
          await ApplicationUtils.getAplicationAsync<BeanT>(
            factory,
            effectiveQualifierName,
          )
      };
    } finally {
      _resolutionMap.remove(effectiveQualifierName);
    }
  }

  static BeanT executar<BeanT extends Object>(
      ScopeFactory<BeanT> factory, Object effectiveQualifierName) {
    return runZoned(
      () {
        return _getScoped<BeanT>(factory, effectiveQualifierName);
      },
      zoneValues: {_resolutionKey: <Object>{}},
    );
  }

  static Future<BeanT> executarAsync<BeanT extends Object>(
      ScopeFactory<BeanT> factory, Object effectiveQualifierName) {
    return runZoned(
      () {
        return _getScopedAsync<BeanT>(factory, effectiveQualifierName);
      },
      zoneValues: {_resolutionKey: <Object>{}},
    );
  }
}
