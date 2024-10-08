import 'package:dart_ddi/dart_ddi.dart';
import 'package:dart_ddi/src/core/bean/utils/dart_ddi_utils.dart';
import 'package:dart_ddi/src/data/factory_clazz.dart';

final class ApplicationUtils {
  static Future<BeanT> getAplicationAsync<BeanT extends Object>(
      FactoryClazz<BeanT> factoryClazz, Object effectiveQualifierName) async {
    late BeanT applicationClazz;

    if (factoryClazz.clazzInstance == null) {
      applicationClazz = _applyApplication<BeanT>(
          factoryClazz, await factoryClazz.clazzRegister!.call());

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

  static BeanT getAplication<BeanT extends Object>(
    FactoryClazz<BeanT> factoryClazz,
    Object effectiveQualifierName,
  ) {
    late BeanT applicationClazz;

    if (factoryClazz.clazzInstance == null) {
      applicationClazz = _applyApplication<BeanT>(
          factoryClazz, (factoryClazz.clazzRegister as BeanT Function())());

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

    applicationClazz = DartDDIUtils.executarDecorators<BeanT>(
        applicationClazz, factoryClazz.decorators);

    factoryClazz.postConstruct?.call();

    factoryClazz.clazzInstance = applicationClazz;

    return applicationClazz;
  }
}
