import 'package:dart_ddi/dart_ddi.dart';
import 'package:flutter_test/flutter_test.dart';

void object() {
  group('DDI Object Basic Tests', () {
    test('Register and retrieve object bean', () {
      DDI.instance.registerObject(
          register: 'Willian Marchesan', qualifierName: 'author');

      final instance1 = DDI.instance.get(qualifierName: 'author');
      final instance2 = DDI.instance.get(qualifierName: 'author');

      expect('Willian Marchesan', instance1);
      expect(instance1, same(instance2));

      DDI.instance.destroy(qualifierName: 'author');
    });

    test('Try to retrieve object bean after removed', () {
      DDI.instance.registerObject(
          register: 'Willian Marchesan', qualifierName: 'author');

      DDI.instance.get(qualifierName: 'author');

      DDI.instance.destroy(qualifierName: 'author');

      expect(() => DDI.instance.get(qualifierName: 'author'),
          throwsA(const TypeMatcher<AssertionError>()));
    });

    test('Try to destroy a undestroyable Object bean', () {
      DDI.instance.registerObject(
        register: 'Willian Marchesan',
        qualifierName: 'author',
        destroyable: false,
      );

      final instance1 = DDI.instance.get(qualifierName: 'author');

      DDI.instance.destroy(qualifierName: 'author');

      final instance2 = DDI.instance.get(qualifierName: 'author');

      expect('Willian Marchesan', instance1);
      expect(instance1, same(instance2));
    });

    test('Try to register again a undestroyable Object bean', () {
      DDI.instance.registerObject(
        register: 'Willian Marchesan',
        qualifierName: 'owner',
        destroyable: false,
      );

      DDI.instance.get(qualifierName: 'owner');

      DDI.instance.destroy(qualifierName: 'owner');

      expect(
          () => DDI.instance.registerObject(
                register: 'Willian Marchesan',
                qualifierName: 'owner',
              ),
          throwsA(const TypeMatcher<AssertionError>()));
    });
  });
}
