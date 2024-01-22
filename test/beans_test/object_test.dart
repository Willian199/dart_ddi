import 'package:dart_ddi/dart_ddi.dart';
import 'package:test/test.dart';

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
          throwsA(const TypeMatcher<AssertionError>()));
    });

    test('Try to destroy a undestroyable Object bean', () {
      DDI.instance.registerObject(
        'Willian Marchesan',
        qualifier: 'author',
        destroyable: false,
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
        destroyable: false,
      );

      DDI.instance.get(qualifier: 'owner');

      DDI.instance.destroy(qualifier: 'owner');

      expect(
          () => DDI.instance.registerObject(
                'Willian Marchesan',
                qualifier: 'owner',
              ),
          throwsA(const TypeMatcher<AssertionError>()));
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
  });
}
