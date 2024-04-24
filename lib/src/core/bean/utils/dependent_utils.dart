import 'package:dart_ddi/dart_ddi.dart';
import 'package:dart_ddi/src/core/bean/utils/dart_ddi_utils.dart';
import 'package:dart_ddi/src/data/factory_clazz.dart';
import 'package:dart_ddi/src/extensions/bean_register_extension.dart';
import 'package:dart_ddi/src/typedef/typedef.dart';

final class DependentUtils {
  static BeanT getDependent<BeanT extends Object>(
    FactoryClazz<BeanT> factoryClazz,
    Object? value,
  ) {
    BeanT dependentClazz = switch (factoryClazz.clazzRegister!) {
      final CustomBeanFactory<BeanT> clazzRegister => clazzRegister.call(value),
      final SimpleBeanFactory<BeanT> clazzRegister => clazzRegister.call(),
      final RegisterFunction<BeanT> clazzRegister =>
        clazzRegister.register() as FutureOrBean<BeanT>
    } as BeanT;

    dependentClazz = _applyDependent<BeanT>(factoryClazz, dependentClazz);

    if (factoryClazz.interceptors case final inter? when inter.isNotEmpty) {
      for (final interceptor in inter) {
        dependentClazz = interceptor().aroundGet(dependentClazz);
      }
    }

    if (dependentClazz is PostConstruct) {
      dependentClazz.onPostConstruct();
    } else if (dependentClazz is Future<PostConstruct>) {
      DartDDIUtils.runFutureOrPostConstruct(dependentClazz);
    }

    return dependentClazz;
  }

  static Future<BeanT> getDependentAsync<BeanT extends Object>(
    FactoryClazz<BeanT> factoryClazz,
    Object? value,
  ) async {
    BeanT dependentClazz = switch (factoryClazz.clazzRegister!) {
      final CustomBeanFactory<BeanT> clazzRegister =>
        await clazzRegister.call(value),
      final SimpleBeanFactory<BeanT> clazzRegister =>
        await clazzRegister.call(),
      final RegisterFunction<BeanT> clazzRegister =>
        await clazzRegister.register() as BeanT
    };

    final SimpleBeanFactory<BeanT> clazzRegister =
        factoryClazz.clazzRegister! as SimpleBeanFactory<BeanT>;

    dependentClazz =
        _applyDependent<BeanT>(factoryClazz, await clazzRegister.call());

    if (dependentClazz is PostConstruct) {
      await dependentClazz.onPostConstruct();
    } else if (dependentClazz is Future<PostConstruct>) {
      await DartDDIUtils.runFutureOrPostConstruct(dependentClazz);
    }

    if (factoryClazz.interceptors case final inter? when inter.isNotEmpty) {
      for (final interceptor in inter) {
        dependentClazz = interceptor().aroundGet(dependentClazz);
      }
    }

    return dependentClazz;
  }

  static BeanT _applyDependent<BeanT extends Object>(
    FactoryClazz<BeanT> factoryClazz,
    BeanT dependentClazz,
  ) {
    assert(
        dependentClazz is! PreDispose || dependentClazz is! Future<PreDispose>,
        'Dependent instances dont support PreDispose. Use Interceptors instead.');
    assert(
        dependentClazz is! PreDestroy || dependentClazz is! Future<PreDestroy>,
        'Dependent instances dont support PreDestroy. Use Interceptors instead.');

    if (factoryClazz.interceptors case final inter? when inter.isNotEmpty) {
      for (final interceptor in inter) {
        dependentClazz = interceptor().aroundConstruct(dependentClazz);
      }
    }

    dependentClazz = DartDDIUtils.executarDecorators<BeanT>(
        dependentClazz, factoryClazz.decorators);

    factoryClazz.postConstruct?.call();

    return dependentClazz;
  }
}
