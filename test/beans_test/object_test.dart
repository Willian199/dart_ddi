import 'package:dart_ddi/dart_ddi.dart';
import 'package:dart_ddi/src/exception/bean_not_found.dart';
import 'package:dart_ddi/src/exception/duplicated_bean.dart';
import 'package:dart_ddi/src/exception/factory_not_allowed.dart';
import 'package:test/test.dart';

import '../clazz_samples/custom_interceptors.dart';

void object() {
  group('DDI Object Basic Tests', () {
    test('Register and retrieve object bean', () {
      DDI.instance.registerObject('Willian Marchesan', qualifier: 'author');

      final instance1 = DDI.instance.get(qualifier: 'author');
      final instance2 = DDI.instance.get(qualifier: 'author');

      expect('Willian Marchesan', instance1);
      expect(instance1, same(instance2));

      DDI.instance.destroy(qualifier: 'author');
    });

    test('Try to retrieve object bean after removed', () {
      DDI.instance.registerObject('Willian Marchesan', qualifier: 'author');

      DDI.instance.get(qualifier: 'author');

      DDI.instance.destroy(qualifier: 'author');

      expect(() => DDI.instance.get(qualifier: 'author'),
          throwsA(isA<BeanNotFoundException>()));
    });

    test('Try to destroy a undestroyable Object bean', () {
      DDI.instance.registerObject(
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
      DDI.instance.registerObject(
        'Willian Marchesan',
        qualifier: 'owner',
        canDestroy: false,
      );

      DDI.instance.get(qualifier: 'owner');

      DDI.instance.destroy(qualifier: 'owner');

      /*expect(
          () => DDI.instance.registerObject(
                'Willian Marchesan',
                qualifier: 'owner',
              ),
          throwsA(isA<DuplicatedBean>()));*/
    });

    test('Register, retrieve and refresh object bean', () {
      DDI.instance.registerObject('Willian Marchesan', qualifier: 'name');

      final instance1 = DDI.instance.get(qualifier: 'name');
      final instance2 = DDI.instance.get(qualifier: 'name');

      expect('Willian Marchesan', instance1);
      expect(instance1, same(instance2));

      DDI.instance.refreshObject('Will', qualifier: 'name');

      final instance3 = DDI.instance.get(qualifier: 'name');

      expect('Will', instance3);
      expect(false, identical(instance1, instance3));
      expect(false, identical(instance2, instance3));

      DDI.instance.destroy(qualifier: 'name');
    });

    test('Try to register an Object with default register function', () {
      expect(
          () => DDI.instance.register(
              factory: ScopeFactory.object(instanceHolder: 'Value test')),
          throwsA(isA<FactoryNotAllowedException>()));
    });

    test('Try to refresh an Object not registered', () {
      expect(() => DDI.instance.refreshObject("new value"),
          throwsA(isA<BeanNotFoundException>()));
    });

    test('Try to register a duplicated Object', () {
      DDI.instance.registerObject('Will', qualifier: 'name');

      expect(() => DDI.instance.registerObject('Willian', qualifier: 'name'),
          throwsA(isA<DuplicatedBeanException>()));

      DDI.instance.destroy(qualifier: 'name');
    });

    test('Register an Object with canRegister true', () {
      DDI.instance
          .registerObject('Will', qualifier: 'name', canRegister: () => true);

      final value = DDI.instance.get(qualifier: 'name');

      expect('Will', value);

      DDI.instance.destroy(qualifier: 'name');

      expect(() => DDI.instance.get(qualifier: 'name'),
          throwsA(isA<BeanNotFoundException>()));
    });

    test('Register an Object with canRegister false', () {
      DDI.instance
          .registerObject('Will', qualifier: 'name', canRegister: () => false);

      expect(() => DDI.instance.get(qualifier: 'name'),
          throwsA(isA<BeanNotFoundException>()));
    });

    test('Register an Object with postConstruct function', () {
      String value = 'Will';
      DDI.instance.registerObject(
        value,
        qualifier: 'name',
        postConstruct: () {
          value = 'Willian';
        },
      );

      expect('Willian', value);

      expect('Will', DDI.instance.get(qualifier: 'name'));

      DDI.instance.destroy(qualifier: 'name');

      expect(() => DDI.instance.get(qualifier: 'name'),
          throwsA(isA<BeanNotFoundException>()));
    });

    test('Block register an Object with ScopeFactory.object', () {
      expect(
          () => ScopeFactory.object(
                instanceHolder: AddInterceptor(),
              ).register(),
          throwsA(isA<FactoryNotAllowedException>()));
    });

    test('Register an Object with Interceptor', () {
      ddi.registerObject(AddInterceptor());
      ddi.registerObject(MultiplyInterceptor());

      DDI.instance.registerObject<int>(15,
          interceptors: {AddInterceptor, MultiplyInterceptor});

      expect(50, DDI.instance.get<int>());

      DDI.instance.destroy<int>();
      DDI.instance.destroy<AddInterceptor>();
      DDI.instance.destroy<MultiplyInterceptor>();

      expect(
          () => DDI.instance.get<int>(), throwsA(isA<BeanNotFoundException>()));
    });
  });
}
