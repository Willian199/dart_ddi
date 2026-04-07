import 'package:dart_ddi/dart_ddi.dart';
import 'package:test/test.dart';

import '../clazz_samples/factory_coverage_samples.dart';

void main() {
  group('Object Factory Edge Cases', () {
    test('register should resolve required async and sync dependencies',
        () async {
      final ddi = DDI.newInstance();

      await ddi.application<String>(
        () => 'sync-dependency',
        qualifier: 'sync-dep',
      );
      await ddi.application<String>(
        () async => 'async-dependency',
        qualifier: 'async-dep',
      );

      await ddi.register<String>(
        qualifier: 'object-with-requires',
        factory: ObjectFactory<String>(
          instance: 'ok',
          requires: {'sync-dep', 'async-dep'},
        ),
      );

      expect(ddi.isReady<String>(qualifier: 'sync-dep'), isTrue);
      expect(ddi.isReady<String>(qualifier: 'async-dep'), isTrue);
      expect(ddi.get<String>(qualifier: 'object-with-requires'), equals('ok'));
    });

    test('register should apply decorators and clear original decorator list',
        () async {
      final ddi = DDI.newInstance();
      final decorators = <String Function(String)>[
        (instance) => '$instance-decorated',
      ];

      await ddi.register<String>(
        qualifier: 'decorated-object',
        factory: ObjectFactory<String>(
          instance: 'base',
          decorators: decorators,
        ),
      );

      expect(ddi.get<String>(qualifier: 'decorated-object'),
          equals('base-decorated'));
      expect(decorators, isEmpty);
    });

    test(
        'register and dispose should create and destroy module context for object factory',
        () async {
      final ddi = DDI.newInstance();

      await ddi.object<CoverageObjectModule>(
        CoverageObjectModule(ddi),
        qualifier: 'obj-module',
      );

      expect(ddi.contextExists(CoverageObjectModule.moduleContext), isTrue);

      await ddi.dispose<CoverageObjectModule>(qualifier: 'obj-module');

      expect(ddi.contextExists(CoverageObjectModule.moduleContext), isFalse);
    });

    test('factory methods should throw not-ready and destroyed state errors',
        () async {
      final ddi = DDI.newInstance();
      final factory = ObjectFactory<String>(instance: 'value');

      expect(
        () => factory.getWith<Object>(qualifier: 'q', ddiInstance: ddi),
        throwsA(isA<BeanNotReadyException>()),
      );
      expect(
        () => factory.addDecorator([(value) => value]),
        throwsA(isA<BeanNotReadyException>()),
      );

      await factory.register(qualifier: 'q', ddiInstance: ddi);
      await factory.destroy(apply: () {}, ddiInstance: ddi);

      await expectLater(factory.dispose(ddiInstance: ddi), completes);
    });

    test('addInterceptor should work when interceptor set starts empty',
        () async {
      final ddi = DDI.newInstance();

      await ddi.singleton<CoverageIntAddInterceptor>(
        CoverageIntAddInterceptor.new,
      );
      await ddi.object<int>(10, qualifier: 'num');

      ddi.addInterceptor<int>({CoverageIntAddInterceptor}, qualifier: 'num');

      expect(ddi.get<int>(qualifier: 'num'), equals(11));
    });
  });
}
