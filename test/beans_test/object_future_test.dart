import 'package:dart_ddi/dart_ddi.dart';
import 'package:dart_ddi/src/exception/bean_not_found.dart';
import 'package:test/test.dart';

import '../clazz_samples/custom_interceptors.dart';
import '../clazz_samples/future_post_construct.dart';

void objectFuture() {
  group('DDI Object Future Basic Tests', () {
    test('Register and retrieve object bean', () async {
      DDI.instance.registerObject(Future.value('Willian Marchesan'),
          qualifier: 'futureAuthor');

      final instance1 =
          await DDI.instance.get<Future<String>>(qualifier: 'futureAuthor');
      final instance2 =
          await DDI.instance.get<Future<String>>(qualifier: 'futureAuthor');

      expect('Willian Marchesan', instance1);
      expect(instance1, same(instance2));

      DDI.instance.destroy(qualifier: 'futureAuthor');
    });

    test('Try to retrieve object bean after removed', () {
      DDI.instance.registerObject(Future.value('Willian Marchesan'),
          qualifier: 'futureAuthor');

      DDI.instance.get(qualifier: 'futureAuthor');

      DDI.instance.destroy(qualifier: 'futureAuthor');

      expect(() => DDI.instance.get(qualifier: 'futureAuthor'),
          throwsA(isA<BeanNotFoundException>()));
    });

    test('Try to destroy a undestroyable Object bean', () async {
      DDI.instance.registerObject(
        Future.value('Willian Marchesan'),
        qualifier: 'futureAuthor',
        canDestroy: false,
      );

      final instance1 =
          await DDI.instance.get<Future<String>>(qualifier: 'futureAuthor');

      DDI.instance.destroy(qualifier: 'futureAuthor');

      final String instance2 =
          await DDI.instance.get(qualifier: 'futureAuthor');

      expect('Willian Marchesan', instance1);
      expect(instance1, same(instance2));
    });

    test('Register, retrieve and refresh object bean', () async {
      DDI.instance
          .registerObject(Future.value('Willian Marchesan'), qualifier: 'name');

      final instance1 =
          await DDI.instance.get<Future<String>>(qualifier: 'name');
      final instance2 =
          await DDI.instance.get<Future<String>>(qualifier: 'name');

      expect('Willian Marchesan', instance1);
      expect(instance1, same(instance2));

      DDI.instance.refreshObject(Future.value('Will'), qualifier: 'name');

      final String instance3 =
          await DDI.instance.get<Future<String>>(qualifier: 'name');

      expect('Will', instance3);
      expect(false, identical(instance1, instance3));
      expect(false, identical(instance2, instance3));

      DDI.instance.destroy(qualifier: 'name');
    });

    test('Register an Object with canRegister true', () async {
      Future<String> localTest() async {
        await Future.delayed(const Duration(milliseconds: 10));
        return 'Will';
      }

      await DDI.instance.registerObject(localTest(),
          qualifier: 'name',
          canRegister: () => Future.delayed(
                const Duration(milliseconds: 10),
                () => true,
              ));

      final value = await DDI.instance.getAsync(qualifier: 'name');

      expect('Will', value);

      DDI.instance.destroy(qualifier: 'name');

      expect(() => DDI.instance.getAsync(qualifier: 'name'),
          throwsA(isA<BeanNotFoundException>()));
    });

    test('Register an Object with canRegister false', () {
      Future<String> localTest() async {
        await Future.delayed(const Duration(milliseconds: 10));
        return 'Will';
      }

      DDI.instance.registerObject(localTest(),
          qualifier: 'name', canRegister: () => false);

      expect(() => DDI.instance.getAsync(qualifier: 'name'),
          throwsA(isA<BeanNotFoundException>()));
    });

    test('Register an Object with postConstruct function', () async {
      Future<String> localTest() async {
        await Future.delayed(const Duration(milliseconds: 10));
        return 'Will';
      }

      await DDI.instance.registerObject(
        localTest(),
        qualifier: 'name',
        postConstruct: () async {
          // This forces the dart vm to schedule the postConstruct in the event loop
          await Future.delayed(Duration.zero);

          DDI.instance
              .refreshObject(Future.value('Willian'), qualifier: 'name');
        },
      );

      // This forces the dart vm run the postConstruct
      await Future.delayed(Duration.zero);

      final value = await DDI.instance.getAsync(qualifier: 'name');

      expect('Willian', value);

      DDI.instance.destroy(qualifier: 'name');

      expect(() => DDI.instance.get(qualifier: 'name'),
          throwsA(isA<BeanNotFoundException>()));
    });

    test('Register a class Object with PostConstruct mixin', () async {
      Future<FuturePostConstruct> localTest() async {
        await Future.delayed(const Duration(milliseconds: 10));
        return FuturePostConstruct();
      }

      await DDI.instance.registerObject(
        localTest(),
        qualifier: 'FuturePostConstruct',
      );

      final FuturePostConstruct instance =
          await DDI.instance.getAsync(qualifier: 'FuturePostConstruct');

      expect(instance.value, 10);

      DDI.instance.destroy(qualifier: 'FuturePostConstruct');

      expect(() => DDI.instance.get(qualifier: 'FuturePostConstruct'),
          throwsA(isA<BeanNotFoundException>()));
    });

    test('Register an Object with Interceptor', () async {
      ddi.registerObject(AsyncAddInterceptor());

      ddi.registerApplication<MultiplyInterceptor>(() {
        return Future.delayed(
            const Duration(milliseconds: 10), () => MultiplyInterceptor());
      });

      await DDI.instance.registerObject<int>(10,
          interceptors: {AsyncAddInterceptor, MultiplyInterceptor});

      expect(DDI.instance.get<int>(), 60);

      DDI.instance.destroy<int>();
      DDI.instance.destroy<AsyncAddInterceptor>();
      DDI.instance.destroy<MultiplyInterceptor>();

      expect(
          () => DDI.instance.get<int>(), throwsA(isA<BeanNotFoundException>()));
    });

    test('Register an Object class with Future PostConstruct mixin', () async {
      Future<FuturePostConstruct> localTest() async {
        await Future.delayed(const Duration(milliseconds: 10));
        return FuturePostConstruct();
      }

      await DDI.instance.registerObject(localTest());

      expect(DDI.instance.isFuture<Future<FuturePostConstruct>>(), false);
      expect(DDI.instance.getByType<Future<FuturePostConstruct>>().length, 1);

      // Never register a Object like this
      // At least works
      final FuturePostConstruct instance =
          await await DDI.instance.getAsync<Future<FuturePostConstruct>>();

      expect(instance.value, 10);

      DDI.instance.destroy<Future<FuturePostConstruct>>();

      expect(DDI.instance.isRegistered<Future<FuturePostConstruct>>(), false);
    });

    test(
        'Register an Object class with Future PostConstruct mixin and qualifier',
        () async {
      Future<FuturePostConstruct> localTest() async {
        await Future.delayed(const Duration(milliseconds: 10));
        return FuturePostConstruct();
      }

      await DDI.instance.registerObject<Future<FuturePostConstruct>>(
        localTest(),
        qualifier: 'FuturePostConstruct',
      );

      expect(DDI.instance.getByType<Future<FuturePostConstruct>>().length, 1);

      final FuturePostConstruct instance =
          await DDI.instance.getAsync(qualifier: 'FuturePostConstruct');

      expect(instance.value, 10);

      DDI.instance.destroy(qualifier: 'FuturePostConstruct');

      expect(
          DDI.instance.isRegistered(qualifier: 'FuturePostConstruct'), false);
    });
  });
}
