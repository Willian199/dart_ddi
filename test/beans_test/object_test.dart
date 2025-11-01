import 'package:dart_ddi/dart_ddi.dart';
import 'package:dart_ddi/src/exception/bean_not_found.dart';
import 'package:dart_ddi/src/exception/duplicated_bean.dart';
import 'package:dart_ddi/src/exception/factory_already_created.dart';
import 'package:test/test.dart';

import '../clazz_samples/c.dart';
import '../clazz_samples/custom_interceptors.dart';

void main() {
  group('DDI Object Basic Tests', () {
    tearDownAll(() {
      // Still having 2 Bean, because [canDestroy] is false
      expect(ddi.isEmpty, false);
      // qualifier: 'author',
      // qualifier: 'owner',
      expect(ddi.length, 2);
    });
    test('Register and retrieve object bean', () {
      DDI.instance.object('Willian Marchesan', qualifier: 'author');

      final instance1 = DDI.instance.get(qualifier: 'author');
      final instance2 = DDI.instance.get(qualifier: 'author');

      expect('Willian Marchesan', instance1);
      expect(instance1, same(instance2));

      DDI.instance.destroy(qualifier: 'author');
    });

    test('Try to retrieve object bean after removed', () {
      DDI.instance.object('Willian Marchesan', qualifier: 'author');

      DDI.instance.get(qualifier: 'author');

      DDI.instance.destroy(qualifier: 'author');

      expect(
        () => DDI.instance.get(qualifier: 'author'),
        throwsA(isA<BeanNotFoundException>()),
      );
    });

    test('Try to destroy a undestroyable Object bean', () {
      DDI.instance.object(
        'Willian Marchesan',
        qualifier: 'author',
        canDestroy: false,
      );

      final instance1 = DDI.instance.get(qualifier: 'author');

      DDI.instance.destroy(qualifier: 'author');

      final instance2 = DDI.instance.get(qualifier: 'author');

      expect('Willian Marchesan', instance1);
      expect(instance1, same(instance2));
    });

    test('Try to register again a undestroyable Object bean', () {
      DDI.instance.object(
        'Willian Marchesan',
        qualifier: 'owner',
        canDestroy: false,
      );

      DDI.instance.get(qualifier: 'owner');

      DDI.instance.destroy(qualifier: 'owner');

      expect(
        () => DDI.instance.object('Willian Marchesan', qualifier: 'owner'),
        throwsA(isA<DuplicatedBeanException>()),
      );
    });

    test('Register, retrieve and refresh object bean', () {
      DDI.instance.object('Willian Marchesan', qualifier: 'name');

      final instance1 = DDI.instance.get(qualifier: 'name');
      final instance2 = DDI.instance.get(qualifier: 'name');

      expect('Willian Marchesan', instance1);
      expect(instance1, same(instance2));

      DDI.instance.addDecorator([(_) => 'Will'], qualifier: 'name');

      final instance3 = DDI.instance.get(qualifier: 'name');

      expect('Will', instance3);
      expect(false, identical(instance1, instance3));
      expect(false, identical(instance2, instance3));

      DDI.instance.destroy(qualifier: 'name');
    });

    test('Try to refresh an Object not registered', () {
      expect(
        () => DDI.instance.addDecorator([(_) => "new value"]),
        throwsA(isA<BeanNotFoundException>()),
      );
    });

    test('Try to register a duplicated Object', () {
      DDI.instance.object('Will', qualifier: 'name');

      expect(
        () => DDI.instance.object('Willian', qualifier: 'name'),
        throwsA(isA<DuplicatedBeanException>()),
      );

      DDI.instance.destroy(qualifier: 'name');
    });

    test('Register an Object with canRegister true', () {
      DDI.instance.object('Will', qualifier: 'name', canRegister: () => true);

      final value = DDI.instance.get(qualifier: 'name');

      expect('Will', value);

      DDI.instance.destroy(qualifier: 'name');

      expect(
        () => DDI.instance.get(qualifier: 'name'),
        throwsA(isA<BeanNotFoundException>()),
      );
    });

    test('Register an Object with canRegister false', () {
      DDI.instance.object('Will', qualifier: 'name', canRegister: () => false);

      expect(
        () => DDI.instance.get(qualifier: 'name'),
        throwsA(isA<BeanNotFoundException>()),
      );
    });

    test('Register an Object with Interceptor', () {
      ddi.object(AddInterceptor());
      ddi.object(MultiplyInterceptor());

      DDI.instance.object<int>(
        15,
        interceptors: {AddInterceptor, MultiplyInterceptor},
      );

      expect(50, DDI.instance.get<int>());

      DDI.instance.destroy<int>();
      DDI.instance.destroy<AddInterceptor>();
      DDI.instance.destroy<MultiplyInterceptor>();

      expect(
        () => DDI.instance.get<int>(),
        throwsA(isA<BeanNotFoundException>()),
      );

      expect(DDI.instance.isRegistered<int>(), false);
    });

    test('Call register before passing to DDI', () {
      final c = ObjectFactory(instance: C())..register(qualifier: C);

      expect(
        () => ddi.register<C>(factory: c),
        throwsA(isA<FactoryAlreadyCreatedException>()),
      );

      expect(DDI.instance.isRegistered<C>(), true);

      DDI.instance.destroy<C>();
    });

    test('Try to get a Bean using a list Future wait', () async {
      Future.wait<dynamic>([
        await Future.value(
          ddi.object<C>(
            await Future.delayed(const Duration(milliseconds: 10), () => C()),
          ),
        ),
        Future.value(ddi.get<C>()),
        ddi.getAsync<C>(),
      ], eagerError: true);

      await ddi.destroy<C>();

      expect(ddi.isRegistered<C>(), false);
    });
  });
}
