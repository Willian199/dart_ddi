import 'package:dart_ddi/dart_ddi.dart';
import 'package:dart_ddi/src/exception/bean_not_found.dart';
import 'package:test/test.dart';

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
          throwsA(isA<BeanNotFound>()));
    });

    test('Try to destroy a undestroyable Object bean', () async {
      DDI.instance.registerObject(
        Future.value('Willian Marchesan'),
        qualifier: 'futureAuthor',
        destroyable: false,
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
  });
}
