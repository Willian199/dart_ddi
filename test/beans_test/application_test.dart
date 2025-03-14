import 'package:dart_ddi/dart_ddi.dart';
import 'package:dart_ddi/src/exception/bean_not_found.dart';
import 'package:dart_ddi/src/exception/duplicated_bean.dart';
import 'package:dart_ddi/src/exception/factory_not_allowed.dart';
import 'package:dart_ddi/src/exception/future_not_accept.dart';
import 'package:test/test.dart';

import '../clazz_samples/a.dart';
import '../clazz_samples/b.dart';
import '../clazz_samples/c.dart';
import '../clazz_samples/future_post_construct.dart';
import '../clazz_samples/g.dart';
import '../clazz_samples/h.dart';
import '../clazz_samples/i.dart';
import '../clazz_samples/undestroyable/application_destroy_get.dart';
import '../clazz_samples/undestroyable/application_destroy_register.dart';
import 'payment_service.dart';

void application() {
  group('DDI Application Basic Tests', () {
    void registerApplicationBeans() {
      DDI.instance.registerApplication(() => A(DDI.instance()));
      DDI.instance.registerApplication(() => B(DDI.instance()));
      DDI.instance.registerApplication(C.new);
    }

    void removeApplicationBeans() {
      DDI.instance.destroy<A>();
      DDI.instance.destroy<B>();
      DDI.instance.destroy<C>();
    }

    test('Register and retrieve Application bean', () {
      registerApplicationBeans();

      final instance1 = DDI.instance.get<A>();
      final instance2 = DDI.instance.get<A>();

      expect(instance1, same(instance2));
      expect(instance1.b, same(instance2.b));
      expect(instance1.b.c, same(instance2.b.c));
      expect(instance1.b.c.value, same(instance2.b.c.value));

      removeApplicationBeans();
    });

    test('Retrieve Application bean after a "child" bean is diposed', () {
      registerApplicationBeans();

      final instance = DDI.instance.get<A>();

      DDI.instance.dispose<C>();
      final instance1 = DDI.instance.get<A>();
      expect(instance1, same(instance));
      expect(instance1.b, same(instance.b));
      expect(instance.b.c, same(instance1.b.c));
      expect(instance.b.c.value, same(instance1.b.c.value));

      removeApplicationBeans();
    });

    test('Retrieve Application bean after a second "child" bean is diposed',
        () {
      registerApplicationBeans();

      final instance = DDI.instance.get<A>();

      DDI.instance.dispose<B>();
      final instance1 = DDI.instance.get<A>();
      expect(instance1, same(instance));
      expect(instance1.b, same(instance.b));
      expect(instance.b.c, same(instance1.b.c));
      expect(instance.b.c.value, same(instance1.b.c.value));

      removeApplicationBeans();
    });

    test('Retrieve Application bean after the last "child" bean is diposed',
        () {
      registerApplicationBeans();

      final instance1 = DDI.instance.get<A>();

      DDI.instance.dispose<A>();
      final instance2 = DDI.instance.get<A>();

      expect(false, identical(instance1, instance2));
      expect(true, identical(instance1.b, instance2.b));
      expect(true, identical(instance1.b.c, instance2.b.c));
      expect(instance1.b.c.value, same(instance2.b.c.value));

      removeApplicationBeans();
    });

    test('Retrieve Application bean after 2 "child" bean is diposed', () {
      registerApplicationBeans();

      final instance1 = DDI.instance.get<A>();

      DDI.instance.dispose<B>();
      DDI.instance.dispose<A>();
      final instance2 = DDI.instance.get<A>();

      expect(false, identical(instance1, instance2));
      expect(false, identical(instance1.b, instance2.b));
      expect(true, identical(instance1.b.c, instance2.b.c));
      expect(instance1.b.c.value, same(instance2.b.c.value));

      removeApplicationBeans();
    });

    test('Retrieve Application bean after 3 "child" bean is diposed', () {
      registerApplicationBeans();

      final instance1 = DDI.instance.get<A>();

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

    test('Try to retrieve Application bean after disposed', () {
      DDI.instance.registerApplication(C.new);

      final instance1 = DDI.instance.get<C>();

      DDI.instance.dispose<C>();

      final instance2 = DDI.instance.get<C>();

      expect(false, identical(instance1, instance2));

      DDI.instance.destroy<C>();
    });

    test('Try to retrieve Application bean after removed', () {
      DDI.instance.registerApplication(C.new);

      DDI.instance.get<C>();

      DDI.instance.destroy<C>();

      expect(
          () => DDI.instance.get<C>(), throwsA(isA<BeanNotFoundException>()));
    });

    test('Create, get and remove a qualifier bean', () {
      DDI.instance.registerApplication(C.new, qualifier: 'typeC');

      DDI.instance.get(qualifier: 'typeC');

      DDI.instance.destroy(qualifier: 'typeC');

      expect(() => DDI.instance.get(qualifier: 'typeC'),
          throwsA(isA<BeanNotFoundException>()));
    });

    test('Try to destroy an undestroyable Application bean', () {
      DDI.instance
          .registerApplication(ApplicationDestroyGet.new, canDestroy: false);

      final instance1 = DDI.instance.get<ApplicationDestroyGet>();

      DDI.instance.destroy<ApplicationDestroyGet>();

      final instance2 = DDI.instance.get<ApplicationDestroyGet>();

      expect(instance1, same(instance2));
    });

    test('Try to register again an undestroyable Application bean', () {
      DDI.instance.registerApplication(ApplicationDestroyRegister.new,
          canDestroy: false);

      DDI.instance.get<ApplicationDestroyRegister>();

      DDI.instance.destroy<ApplicationDestroyRegister>();

      expect(
          () => DDI.instance
              .registerApplication(() => ApplicationDestroyRegister()),
          throwsA(isA<DuplicatedBeanException>()));
    });

    test('Select an Application bean', () {
      // Registering CreditCardPaymentService with a selector condition
      ddi.registerApplication<PaymentService>(
        CreditCardPaymentService.new,
        qualifier: 'creditCard',
        selector: (paymentMethod) => paymentMethod == 'creditCard',
      );

      // Registering PayPalPaymentService with a selector condition
      ddi.registerApplication<PaymentService>(
        PayPalPaymentService.new,
        qualifier: 'paypal',
        selector: (paymentMethod) => paymentMethod == 'paypal',
      );

      // Runtime value to determine the payment method
      const selectedPaymentMethod = 'paypal'; // Could also be 'creditCard'

      expect(true, ddi.isRegistered(qualifier: 'creditCard'));
      expect(true, ddi.isRegistered(qualifier: 'paypal'));

      // Retrieve the appropriate PaymentService based on the selector condition
      late final paymentService = ddi.get<PaymentService>(
        select: selectedPaymentMethod,
      );

      // Process a payment with the selected service
      expect(200, paymentService.value);

      ddi.destroyByType<PaymentService>();

      expect(false, ddi.isRegistered(qualifier: 'creditCard'));
      expect(false, ddi.isRegistered(qualifier: 'paypal'));
    });

    test('Register and retrieve Application bean from a new DDI instance', () {
      void register(DDI d) {
        d.registerApplication(() => A(d()));
        d.registerApplication(() => B(d()));
        d.registerApplication(C.new);
      }

      void destroy(DDI d) {
        d.destroy<A>();
        d.destroy<B>();
        d.destroy<C>();
      }

      void check(DDI d) {
        final instance1 = d.get<A>();
        final instance2 = d.get<A>();
        expect(instance1, same(instance2));
        expect(instance1.b, same(instance2.b));
        expect(instance1.b.c, same(instance2.b.c));
        expect(instance1.b.c.value, same(instance2.b.c.value));
      }

      final newDdi = DDI.newInstance;

      register(ddi);
      register(newDdi);

      check(ddi);
      check(newDdi);

      destroy(ddi);
      destroy(newDdi);
    });

    test(
        'Register an Application Future class with Future PostConstruct mixin and qualifier',
        () async {
      Future<FuturePostConstruct> localTest() async {
        await Future.delayed(const Duration(milliseconds: 10));
        return FuturePostConstruct();
      }

      DDI.instance.register<Future<FuturePostConstruct>>(
        factory: ApplicationFactory(
          builder: CustomBuilder(
            producer: localTest,
            parametersType: [],
            returnType: FuturePostConstruct,
            isFuture: true,
          ),
        ),
        qualifier: 'FuturePostConstruct',
      );

      expect(DDI.instance.isFuture(qualifier: 'FuturePostConstruct'), true);

      expect(DDI.instance.getByType<Future<FuturePostConstruct>>().length, 1);

      expect(() => DDI.instance.get(qualifier: 'FuturePostConstruct'),
          throwsA(isA<FutureNotAcceptException>()));

      final FuturePostConstruct futureInstance =
          await DDI.instance.getAsync(qualifier: 'FuturePostConstruct');

      expect(futureInstance.value, 10);

      final FuturePostConstruct cachedInstance = await DDI.instance
          .get<Future<FuturePostConstruct>>(qualifier: 'FuturePostConstruct');

      expect(cachedInstance.value, 10);

      expect(identical(cachedInstance, futureInstance), true);

      DDI.instance.destroy(qualifier: 'FuturePostConstruct');

      expect(
          DDI.instance.isRegistered(qualifier: 'FuturePostConstruct'), false);
    });

    test('Try to register again an Object Type Bean', () {
      expect(() => DDI.instance.registerApplication<Object>(() => "Test"),
          throwsA(isA<FactoryNotAllowedException>()));
    });

    test('Register Beans with same interface', () {
      DDI.instance.registerApplication<G>(I.new, qualifier: 'First');
      DDI.instance.register<G>(
          factory: ApplicationFactory<H>(builder: H.new.builder),
          qualifier: 'Second');

      expect(DDI.instance.getByType<G>().length, 2);

      DDI.instance.destroy(qualifier: 'First');
      DDI.instance.destroy(qualifier: 'Second');

      expect(DDI.instance.isRegistered(qualifier: 'First'), false);
      expect(DDI.instance.isRegistered(qualifier: 'Second'), false);
    });
  });
}
