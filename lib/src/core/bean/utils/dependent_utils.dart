import 'package:dart_ddi/dart_ddi.dart';
import 'package:dart_ddi/src/core/bean/utils/dart_ddi_utils.dart';
import 'package:dart_ddi/src/core/bean/utils/instance_factory_util.dart';

final class DependentUtils {
  static BeanT getDependent<BeanT extends Object>(
    ScopeFactory<BeanT> factory,
    Object effectiveQualifierName,
  ) {
    BeanT dependentClazz = _applyDependent<BeanT>(
      factory,
      InstanceFactoryUtil.create(builder: factory.builder!),
    );

    if (factory.interceptors case final inter? when inter.isNotEmpty) {
      for (final interceptor in inter) {
        dependentClazz = interceptor().onGet(dependentClazz);
      }
    }

    if (dependentClazz is DDIModule) {
      dependentClazz.moduleQualifier = effectiveQualifierName;
    }

    if (dependentClazz is PostConstruct) {
      dependentClazz.onPostConstruct();
    } else if (dependentClazz is Future<PostConstruct>) {
      DartDDIUtils.runFutureOrPostConstruct(dependentClazz);
    }

    return dependentClazz;
  }

  static Future<BeanT> getDependentAsync<BeanT extends Object>(
    ScopeFactory<BeanT> factory,
    Object effectiveQualifierName,
  ) async {
    BeanT dependentClazz = _applyDependent<BeanT>(
      factory,
      await InstanceFactoryUtil.createAsync(builder: factory.builder!),
    );

    if (dependentClazz is DDIModule) {
      dependentClazz.moduleQualifier = effectiveQualifierName;
    }

    if (dependentClazz is PostConstruct) {
      await dependentClazz.onPostConstruct();
    } else if (dependentClazz is Future<PostConstruct>) {
      await DartDDIUtils.runFutureOrPostConstruct(dependentClazz);
    }

    if (factory.interceptors case final inter? when inter.isNotEmpty) {
      for (final interceptor in inter) {
        dependentClazz = interceptor().onGet(dependentClazz);
      }
    }

    return dependentClazz;
  }

  static BeanT _applyDependent<BeanT extends Object>(
    ScopeFactory<BeanT> factory,
    BeanT dependentClazz,
  ) {
    assert(
        dependentClazz is! PreDispose || dependentClazz is! Future<PreDispose>,
        'Dependent instances dont support PreDispose. Use Interceptors instead.');
    assert(
        dependentClazz is! PreDestroy || dependentClazz is! Future<PreDestroy>,
        'Dependent instances dont support PreDestroy. Use Interceptors instead.');

    if (factory.interceptors case final inter? when inter.isNotEmpty) {
      for (final interceptor in inter) {
        dependentClazz = interceptor().onCreate(dependentClazz);
      }
    }

    dependentClazz = DartDDIUtils.executarDecorators<BeanT>(
        dependentClazz, factory.decorators);

    factory.postConstruct?.call();

    return dependentClazz;
  }
}
