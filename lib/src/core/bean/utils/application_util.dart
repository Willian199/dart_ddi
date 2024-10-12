import 'dart:async';

import 'package:dart_ddi/dart_ddi.dart';
import 'package:dart_ddi/src/core/bean/utils/dart_ddi_utils.dart';
import 'package:dart_ddi/src/core/bean/utils/instance_factory_util.dart';
import 'package:dart_ddi/src/data/factory_clazz.dart';

final class ApplicationUtils {
  static Future<BeanT> getAplicationAsync<BeanT extends Object, ParameterT extends Object>({
    required FactoryClazz<BeanT> factoryClazz,
    required Object effectiveQualifierName,
    ParameterT? parameters,
  }) async {
    late BeanT applicationClazz;

    if (factoryClazz.clazzInstance == null) {
      applicationClazz = await InstanceFactoryUtil.createAsync<BeanT, ParameterT>(
        clazzRegister: factoryClazz.clazzRegister!,
        parameters: parameters,
      );

      applicationClazz = _applyApplication<BeanT>(factoryClazz, applicationClazz);

      if (applicationClazz is DDIModule) {
        applicationClazz.moduleQualifier = effectiveQualifierName;
      }

      if (applicationClazz is PostConstruct) {
        await applicationClazz.onPostConstruct();
      } else if (applicationClazz is Future<PostConstruct>) {
        await DartDDIUtils.runFutureOrPostConstruct(applicationClazz);
      }
    } else {
      applicationClazz = factoryClazz.clazzInstance!;
    }

    if (factoryClazz.interceptors case final inter? when inter.isNotEmpty) {
      for (final interceptor in inter) {
        applicationClazz = interceptor().aroundGet(applicationClazz);
      }
    }

    return applicationClazz;
  }

  static BeanT getAplication<BeanT extends Object, ParameterT extends Object>({
    required FactoryClazz<BeanT> factoryClazz,
    required Object effectiveQualifierName,
    ParameterT? parameters,
  }) {
    late BeanT applicationClazz;

    if (factoryClazz.clazzInstance == null) {
      applicationClazz = InstanceFactoryUtil.create<BeanT, ParameterT>(
        clazzRegister: factoryClazz.clazzRegister!,
        parameters: parameters,
      );

      applicationClazz = _applyApplication<BeanT>(factoryClazz, applicationClazz);

      if (applicationClazz is DDIModule) {
        applicationClazz.moduleQualifier = effectiveQualifierName;
      }

      if (applicationClazz is PostConstruct) {
        applicationClazz.onPostConstruct();
      } else if (applicationClazz is Future<PostConstruct>) {
        DartDDIUtils.runFutureOrPostConstruct(applicationClazz);
      }
    } else {
      applicationClazz = factoryClazz.clazzInstance!;
    }

    if (factoryClazz.interceptors case final inter? when inter.isNotEmpty) {
      for (final interceptor in inter) {
        applicationClazz = interceptor().aroundGet(applicationClazz);
      }
    }

    return applicationClazz;
  }

  static BeanT _applyApplication<BeanT extends Object>(
    FactoryClazz<BeanT> factoryClazz,
    BeanT applicationClazz,
  ) {
    if (factoryClazz.interceptors case final inter? when inter.isNotEmpty) {
      for (final interceptor in inter) {
        applicationClazz = interceptor().aroundConstruct(applicationClazz);
      }
    }

    applicationClazz = DartDDIUtils.executarDecorators<BeanT>(applicationClazz, factoryClazz.decorators);

    factoryClazz.postConstruct?.call();

    factoryClazz.clazzInstance = applicationClazz;

    return applicationClazz;
  }
}
