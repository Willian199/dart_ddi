import 'package:dart_ddi/dart_ddi.dart';
import 'package:dart_ddi/src/exception/bean_not_found.dart';
import 'package:dart_ddi/src/exception/duplicated_bean.dart';
import 'package:test/test.dart';

import '../clazz_samples/a.dart';
import '../clazz_samples/b.dart';
import '../clazz_samples/c.dart';
import '../clazz_samples/factory_parameter.dart';
import '../clazz_samples/multi_inject.dart';
import '../clazz_samples/undestroyable/dependent_factory_destroy_get.dart';
import '../clazz_samples/undestroyable/dependent_factory_destroy_register.dart';

void dependentFactory() {
  group('DDI Dependent Factory Basic Tests', () {
    void registerDependentBeans() {
      MultiInject.new.builder.asDependent();
      A.new.builder.asDependent();
      B.new.builder.asDependent();
      C.new.builder.asDependent();
    }

    void removeDependentBeans() {
      DDI.instance.destroy<MultiInject>();
      DDI.instance.destroy<A>();
      DDI.instance.destroy<B>();
      DDI.instance.destroy<C>();
    }

    test('Register and retrieve Dependent bean', () {
      registerDependentBeans();

      final instance1 = DDI.instance.get<MultiInject>();
      final instance2 = DDI.instance.get<A>();

      expect(false, identical(instance1.a, instance2));
      expect(false, identical(instance1.b, instance2.b));
      expect(false, identical(instance1.b.c, instance2.b.c));
      expect(instance1.b.c.value, same(instance2.b.c.value));

      removeDependentBeans();
    });

    test('Retrieve Dependent bean after a "child" bean is diposed', () {
      registerDependentBeans();

      final instance = DDI.instance.get<MultiInject>();

      DDI.instance.dispose<C>();
      final instance1 = DDI.instance.get<A>();
      expect(false, identical(instance1, instance.a));
      expect(false, identical(instance1.b, instance.b));
      expect(false, identical(instance1.b.c, instance.b.c));
      expect(instance.b.c.value, same(instance1.b.c.value));

      removeDependentBeans();
    });

    test('Retrieve Dependent bean after a second "child" bean is diposed', () {
      registerDependentBeans();

      final instance = DDI.instance.get<MultiInject>();

      DDI.instance.dispose<B>();
      final instance1 = DDI.instance.get<A>();
      expect(false, identical(instance1, instance.a));
      expect(false, identical(instance1.b, instance.b));
      expect(false, identical(instance1.b.c, instance.b.c));
      expect(instance.b.c.value, same(instance1.b.c.value));

      removeDependentBeans();
    });

    test('Try to retrieve Dependent bean after disposed', () {
      C.new.builder.asDependent();

      final instance1 = DDI.instance.get<C>();

      DDI.instance.dispose<C>();

      final instance2 = DDI.instance.get<C>();

      expect(false, identical(instance1, instance2));

      DDI.instance.destroy<C>();
    });

    test('Try to retrieve Dependent bean after removed', () {
      C.new.builder.asDependent();

      DDI.instance.get<C>();

      DDI.instance.destroy<C>();

      expect(
          () => DDI.instance.get<C>(), throwsA(isA<BeanNotFoundException>()));
    });

    test('register, get and remove a qualifier bean', () {
      C.new.builder.asDependent(qualifier: 'typeC');

      final instance1 = DDI.instance.get(qualifier: 'typeC');
      final instance2 = DDI.instance.get(qualifier: 'typeC');

      expect(false, identical(instance1, instance2));

      DDI.instance.destroy(qualifier: 'typeC');

      expect(() => DDI.instance.get(qualifier: 'typeC'),
          throwsA(isA<BeanNotFoundException>()));
    });

    test('Try to destroy a undestroyable Dependent bean', () {
      DependentFactoryDestroyGet.new.builder.asDependent(canDestroy: false);

      final instance1 = DDI.instance.get<DependentFactoryDestroyGet>();

      DDI.instance.destroy<DependentFactoryDestroyGet>();

      final instance2 = DDI.instance.get<DependentFactoryDestroyGet>();

      expect(instance2, isNotNull);
      expect(false, identical(instance1, instance2));
    });

    test('Try to register again an undestroyable Dependent bean', () {
      DependentFactoryDestroyRegister.new.builder
          .asDependent(canDestroy: false);

      DDI.instance.get<DependentFactoryDestroyRegister>();

      DDI.instance.destroy<DependentFactoryDestroyRegister>();

      expect(
          () => DDI.instance.dependent(() => DependentFactoryDestroyRegister()),
          throwsA(isA<DuplicatedBeanException>()));
    });

    test('Retrieve Factory Dependent with Custom Parameter', () {
      FactoryParameter.new.builder.asDependent();

      final FactoryParameter instance =
          DDI.instance(parameter: getRecordParameter);

      expect(instance, isA<FactoryParameter>());
      expect(instance.parameter, getRecordParameter);

      DDI.instance.destroy<FactoryParameter>();

      expect(() => DDI.instance.get<FactoryParameter>(),
          throwsA(isA<BeanNotFoundException>()));
    });
  });
}
