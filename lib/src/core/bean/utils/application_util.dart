import 'package:dart_ddi/dart_ddi.dart';
import 'package:dart_ddi/src/core/bean/utils/dart_ddi_utils.dart';
import 'package:dart_ddi/src/core/bean/utils/instance_factory_util.dart';

final class ApplicationUtils {
  static Future<BeanT> getAplicationAsync<BeanT extends Object>(
      FactoryClazz<BeanT> factoryClazz, Object effectiveQualifierName) async {
    late BeanT applicationClazz;

    if (factoryClazz.clazzInstance == null) {
      applicationClazz = _applyApplication<BeanT>(
        factoryClazz,
        await InstanceFactoryUtil.createAsync(
            clazzFactory: factoryClazz.clazzFactory!),
      );

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
        applicationClazz = interceptor().onGet(applicationClazz);
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
      applicationClazz = _applyApplication<BeanT>(factoryClazz,
          InstanceFactoryUtil.create(clazzFactory: factoryClazz.clazzFactory!));

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
        applicationClazz = interceptor().onGet(applicationClazz);
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
        applicationClazz = interceptor().onCreate(applicationClazz);
      }
    }

    applicationClazz = DartDDIUtils.executarDecorators<BeanT>(
        applicationClazz, factoryClazz.decorators);

    factoryClazz.postConstruct?.call();

    factoryClazz.clazzInstance = applicationClazz;

    return applicationClazz;
  }
}
