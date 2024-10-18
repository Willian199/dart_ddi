import 'package:dart_ddi/dart_ddi.dart';
import 'package:dart_ddi/src/core/bean/utils/dart_ddi_utils.dart';
import 'package:dart_ddi/src/core/bean/utils/instance_factory_util.dart';

final class ApplicationUtils {
  static Future<BeanT>
      getAplicationAsync<BeanT extends Object, ParameterT extends Object>({
    required ScopeFactory<BeanT> factory,
    required Object effectiveQualifierName,
    ParameterT? parameter,
  }) async {
    late BeanT applicationClazz;

    if (factory.instanceHolder == null) {
      applicationClazz = _applyApplication<BeanT>(
        factory,
        await InstanceFactoryUtil.createAsync<BeanT, ParameterT>(
          builder: factory.builder!,
          parameter: parameter,
        ),
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
      applicationClazz = factory.instanceHolder!;
    }

    if (factory.interceptors case final inter? when inter.isNotEmpty) {
      for (final interceptor in inter) {
        applicationClazz = interceptor().onGet(applicationClazz);
      }
    }

    return applicationClazz;
  }

  static BeanT getAplication<BeanT extends Object, ParameterT extends Object>({
    required ScopeFactory<BeanT> factory,
    required Object effectiveQualifierName,
    ParameterT? parameter,
  }) {
    late BeanT applicationClazz;

    if (factory.instanceHolder == null) {
      applicationClazz = _applyApplication<BeanT>(
        factory,
        InstanceFactoryUtil.create<BeanT, ParameterT>(
          builder: factory.builder!,
          parameter: parameter,
        ),
      );

      if (applicationClazz is DDIModule) {
        applicationClazz.moduleQualifier = effectiveQualifierName;
      }

      if (applicationClazz is PostConstruct) {
        applicationClazz.onPostConstruct();
      } else if (applicationClazz is Future<PostConstruct>) {
        DartDDIUtils.runFutureOrPostConstruct(applicationClazz);
      }
    } else {
      applicationClazz = factory.instanceHolder!;
    }

    if (factory.interceptors case final inter? when inter.isNotEmpty) {
      for (final interceptor in inter) {
        applicationClazz = interceptor().onGet(applicationClazz);
      }
    }

    return applicationClazz;
  }

  static BeanT _applyApplication<BeanT extends Object>(
    ScopeFactory<BeanT> factory,
    BeanT applicationClazz,
  ) {
    if (factory.interceptors case final inter? when inter.isNotEmpty) {
      for (final interceptor in inter) {
        applicationClazz = interceptor().onCreate(applicationClazz);
      }
    }

    applicationClazz = DartDDIUtils.executarDecorators<BeanT>(
        applicationClazz, factory.decorators);

    factory.postConstruct?.call();

    factory.instanceHolder = applicationClazz;

    return applicationClazz;
  }
}
