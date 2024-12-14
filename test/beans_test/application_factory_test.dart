import 'package:dart_ddi/dart_ddi.dart';
import 'package:dart_ddi/src/exception/bean_not_found.dart';
import 'package:dart_ddi/src/exception/duplicated_bean.dart';
import 'package:test/test.dart';

import '../clazz_samples/a.dart';
import '../clazz_samples/b.dart';
import '../clazz_samples/c.dart';
import '../clazz_samples/factory_parameter.dart';
import '../clazz_samples/multi_inject.dart';
import '../clazz_samples/undestroyable/application_factory_destroy_get.dart';
import '../clazz_samples/undestroyable/application_factory_destroy_register.dart';
import 'payment_service.dart';

void applicationFactory() {
  group('DDI Factory Application Basic Tests', () {
    void registerApplicationBeans() {
      MultiInject.new.builder.asApplication().register();
      A.new.builder.asApplication().register();
      B.new.builder.asApplication().register();
      C.new.builder.asApplication().register();
    }

    void removeApplicationBeans() {
      DDI.instance.destroy<MultiInject>();
      DDI.instance.destroy<A>();
      DDI.instance.destroy<B>();
      DDI.instance.destroy<C>();
    }

    test('Register and retrieve Factory Application bean', () {
      registerApplicationBeans();

      final instance1 = DDI.instance.get<MultiInject>();
      final instance2 = DDI.instance.get<A>();

      expect(instance1.a, same(instance2));
      expect(instance1.b, same(instance2.b));
      expect(instance1.b.c, same(instance2.b.c));
      expect(instance1.b.c.value, same(instance2.b.c.value));

      removeApplicationBeans();
    });

    test('Retrieve Factory Application bean after a "child" bean is diposed',
        () {
      registerApplicationBeans();

      final instance = DDI.instance.get<MultiInject>();

      DDI.instance.dispose<C>();
      final instance1 = DDI.instance.get<A>();
      expect(instance1, same(instance.a));
      expect(instance1.b, same(instance.b));
      expect(instance.b.c, same(instance1.b.c));
      expect(instance.b.c.value, same(instance1.b.c.value));

      removeApplicationBeans();
    });

    test(
        'Retrieve Factory Application bean after a second "child" bean is diposed',
        () {
      registerApplicationBeans();

      final instance = DDI.instance.get<MultiInject>();

      DDI.instance.dispose<B>();
      final instance1 = DDI.instance.get<A>();
      expect(instance1, same(instance.a));
      expect(instance1.b, same(instance.b));
      expect(instance.b.c, same(instance1.b.c));
      expect(instance.b.c.value, same(instance1.b.c.value));

      removeApplicationBeans();
    });

    test(
        'Retrieve Factory Application bean after the last "child" bean is diposed',
        () {
      registerApplicationBeans();

      final instance1 = DDI.instance.get<MultiInject>();

      DDI.instance.dispose<A>();
      final instance2 = DDI.instance.get<A>();

      expect(false, identical(instance1.a, instance2));
      expect(true, identical(instance1.b, instance2.b));
      expect(true, identical(instance1.b.c, instance2.b.c));
      expect(instance1.b.c.value, same(instance2.b.c.value));

      removeApplicationBeans();
    });

    test('Retrieve Factory Application bean after 2 "child" bean is diposed',
        () {
      registerApplicationBeans();

      final instance1 = DDI.instance.get<MultiInject>();

      DDI.instance.dispose<B>();
      DDI.instance.dispose<A>();
      final instance2 = DDI.instance.get<A>();

      expect(false, identical(instance1, instance2));
      expect(false, identical(instance1.b, instance2.b));
      expect(true, identical(instance1.b.c, instance2.b.c));
      expect(instance1.b.c.value, same(instance2.b.c.value));

      removeApplicationBeans();
    });

    test('Retrieve Factory Application bean after 3 "child" bean is diposed',
        () {
      registerApplicationBeans();

      final instance1 = DDI.instance.get<MultiInject>();

      DDI.instance.dispose<C>();
      DDI.instance.dispose<B>();
      DDI.instance.dispose<A>();
      final instance2 = DDI.instance.get<A>();

      expect(false, identical(instance1, instance2));
      expect(false, identical(instance1.b, instance2.b));
      expect(false, identical(instance1.b.c, instance2.b.c));
      expect(instance1.b.c.value, same(instance2.b.c.value));

      removeApplicationBeans();
    });

    test('Try to retrieve a Factory Application bean after disposed', () {
      DDI.instance
          .register(factory: ScopeFactory.application(builder: C.new.builder));

      final instance1 = DDI.instance.get<C>();

      DDI.instance.dispose<C>();

      final instance2 = DDI.instance.get<C>();

      expect(false, identical(instance1, instance2));

      DDI.instance.destroy<C>();
    });

    test('Try to retrieve Application bean after removed', () {
      DDI.instance
          .register(factory: ScopeFactory.application(builder: C.new.builder));

      DDI.instance.get<C>();

      DDI.instance.destroy<C>();

      expect(
          () => DDI.instance.get<C>(), throwsA(isA<BeanNotFoundException>()));
    });

    test('Create, get and remove a qualifier bean', () {
      DDI.instance.register(
          factory: ScopeFactory.application(builder: C.new.builder),
          qualifier: 'typeC');

      DDI.instance.get(qualifier: 'typeC');

      DDI.instance.destroy(qualifier: 'typeC');

      expect(() => DDI.instance.get(qualifier: 'typeC'),
          throwsA(isA<BeanNotFoundException>()));
    });

    test('Try to destroy a undestroyable Application bean', () {
      DDI.instance.register(
        factory: ScopeFactory.application(
          builder: ApplicationFactoryDestroyGet.new.builder,
          destroyable: false,
        ),
      );

      final instance1 = DDI.instance.get<ApplicationFactoryDestroyGet>();

      DDI.instance.destroy<ApplicationFactoryDestroyGet>();

      final instance2 = DDI.instance.get<ApplicationFactoryDestroyGet>();

      expect(instance1, same(instance2));
    });

    test('Try to register again a undestroyable Application bean', () {
      DDI.instance.register(
          factory: ScopeFactory.application(
        builder: ApplicationFactoryDestroyRegister.new.builder,
        destroyable: false,
      ));

      DDI.instance.get<ApplicationFactoryDestroyRegister>();

      DDI.instance.destroy<ApplicationFactoryDestroyRegister>();

      expect(
          () => DDI.instance.register(
                factory: ScopeFactory.application(
                  builder: ApplicationFactoryDestroyRegister.new.builder,
                  destroyable: false,
                ),
              ),
          throwsA(isA<DuplicatedBeanException>()));
    });

    test('Retrieve Factory Application with Custom Parameter', () {
      FactoryParameter.new.builder.asApplication().register();

      final FactoryParameter instance =
          DDI.instance(parameter: getRecordParameter);

      expect(instance, isA<FactoryParameter>());
      expect(instance.parameter, getRecordParameter);

      DDI.instance.destroy<FactoryParameter>();

      expect(() => DDI.instance.get<FactoryParameter>(),
          throwsA(isA<BeanNotFoundException>()));
    });

    test('Select an Application bean', () async {
      // Registering CreditCardPaymentService with a selector condition

      ddi.register<PaymentService>(
        factory: ScopeFactory.application(
          builder: CreditCardPaymentService.new.builder,
          selector: (paymentMethod) => paymentMethod == 'creditCard',
        ),
        qualifier: 'creditCard',
      );

      // Registering PayPalPaymentService with a selector condition
      ddi.register<PaymentService>(
        factory: ScopeFactory.application(
          builder: PayPalPaymentService.new.builder,
          selector: (paymentMethod) => paymentMethod == 'paypal',
        ),
        qualifier: 'paypal',
      );

      expect(true, ddi.isRegistered(qualifier: 'creditCard'));
      expect(true, ddi.isRegistered(qualifier: 'paypal'));

      // Runtime value to determine the payment method
      const selectedPaymentMethod = 'creditCard'; // Could also be 'paypal'

      // Retrieve the appropriate PaymentService based on the selector condition
      final paymentService = await ddi.getAsync<PaymentService>(
        select: selectedPaymentMethod,
      );

      // Process a payment with the selected service
      expect(100, paymentService.value);

      ddi.destroyByType<PaymentService>();

      expect(false, ddi.isRegistered(qualifier: 'creditCard'));
      expect(false, ddi.isRegistered(qualifier: 'paypal'));
    });
  });
}
