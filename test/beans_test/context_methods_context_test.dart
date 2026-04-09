import 'package:dart_ddi/dart_ddi.dart';
import 'package:test/test.dart';

import '../clazz_samples/context_api_samples.dart';

void main() {
  group('DDI Context Methods Behavior Tests', () {
    test('getByType should respect explicit context and never fallback',
        () async {
      final ddi = DDI.newInstance();
      final rootContext = ddi.currentContext;

      await ddi.singleton<ContextApiService>(
        () => ContextApiService('root'),
        qualifier: 'root-service',
      );

      ddi.createContext('ctx');
      await ddi.singleton<ContextApiService>(
        () => ContextApiService('ctx'),
        qualifier: 'ctx-service',
        context: 'ctx',
      );

      final rootKeys = ddi.getByType<ContextApiService>(context: rootContext);
      final ctxKeys = ddi.getByType<ContextApiService>(context: 'ctx');

      expect(rootKeys, contains('root-service'));
      expect(rootKeys, isNot(contains('ctx-service')));
      expect(ctxKeys, contains('ctx-service'));
      expect(ctxKeys, isNot(contains('root-service')));
    });

    test('disposeByType should affect only the provided context', () async {
      final ddi = DDI.newInstance();
      final rootContext = ddi.currentContext;

      await ddi.application<ContextApiService>(
        () => ContextApiService('root'),
        qualifier: 'shared',
      );
      expect(ddi.getWith<ContextApiService, Object>(qualifier: 'shared').value,
          equals('root'));

      ddi.createContext('ctx');
      await ddi.application<ContextApiService>(
        () => ContextApiService('ctx'),
        qualifier: 'shared',
        context: 'ctx',
      );
      expect(
        ddi
            .getWith<ContextApiService, Object>(
              qualifier: 'shared',
              context: 'ctx',
            )
            .value,
        equals('ctx'),
      );

      ddi.disposeByType<ContextApiService>(context: 'ctx');

      expect(
        ddi.isReady<ContextApiService>(qualifier: 'shared', context: 'ctx'),
        isFalse,
      );
      expect(
        ddi.isReady<ContextApiService>(
          qualifier: 'shared',
          context: rootContext,
        ),
        isTrue,
      );
    });

    test('addDecorator should update only the targeted context', () async {
      final ddi = DDI.newInstance();
      final rootContext = ddi.currentContext;

      await ddi.singleton<ContextApiService>(
        () => ContextApiService('root'),
        qualifier: 'shared',
      );

      ddi.createContext('ctx');
      await ddi.singleton<ContextApiService>(
        () => ContextApiService('ctx'),
        qualifier: 'shared',
        context: 'ctx',
      );

      ddi.addDecorator<ContextApiService>(
        [(service) => ContextApiService('${service.value}-decorated')],
        qualifier: 'shared',
        context: 'ctx',
      );

      expect(
        ddi
            .getWith<ContextApiService, Object>(
              qualifier: 'shared',
              context: rootContext,
            )
            .value,
        equals('root'),
      );
      expect(
        ddi
            .getWith<ContextApiService, Object>(
              qualifier: 'shared',
              context: 'ctx',
            )
            .value,
        equals('ctx-decorated'),
      );
    });

    test('addDecorator with explicit context should not fallback', () async {
      final ddi = DDI.newInstance();

      await ddi.singleton<ContextApiService>(
        () => ContextApiService('root'),
        qualifier: 'shared',
      );
      ddi.createContext('ctx');

      expect(
        () => ddi.addDecorator<ContextApiService>(
          [(service) => ContextApiService('${service.value}-decorated')],
          qualifier: 'shared',
          context: 'ctx',
        ),
        throwsA(isA<BeanNotFoundException>()),
      );
    });

    test('addInterceptor should update only the targeted context', () async {
      final ddi = DDI.newInstance();
      final rootContext = ddi.currentContext;

      await ddi.singleton<ContextApiInterceptor>(
        () => ContextApiInterceptor('-root'),
        qualifier: 'shared-interceptor',
      );
      await ddi.singleton<ContextApiService>(
        () => ContextApiService('root'),
        qualifier: 'shared',
      );

      ddi.createContext('ctx');
      await ddi.singleton<ContextApiInterceptor>(
        () => ContextApiInterceptor('-ctx'),
        qualifier: 'shared-interceptor',
        context: 'ctx',
      );
      await ddi.singleton<ContextApiService>(
        () => ContextApiService('ctx'),
        qualifier: 'shared',
        context: 'ctx',
      );

      ddi.addInterceptor<ContextApiService>(
        {'shared-interceptor'},
        qualifier: 'shared',
        context: 'ctx',
      );

      expect(
        ddi
            .getWith<ContextApiService, Object>(
              qualifier: 'shared',
              context: rootContext,
            )
            .value,
        equals('root'),
      );
      expect(
        ddi
            .getWith<ContextApiService, Object>(
              qualifier: 'shared',
              context: 'ctx',
            )
            .value,
        equals('ctx-ctx'),
      );
    });

    test('addChildrenModules/getChildren should respect explicit context',
        () async {
      final ddi = DDI.newInstance();
      final rootContext = ddi.currentContext;

      await ddi.singleton<ContextApiService>(
        () => ContextApiService('root'),
        qualifier: 'parent',
      );

      ddi.createContext('ctx');
      await ddi.singleton<ContextApiService>(
        () => ContextApiService('ctx'),
        qualifier: 'parent',
        context: 'ctx',
      );

      ddi.addChildrenModules<ContextApiService>(
        qualifier: 'parent',
        context: 'ctx',
        child: {'ctx-child'},
      );

      expect(
        ddi.getChildren<ContextApiService>(
          qualifier: 'parent',
          context: 'ctx',
        ),
        contains('ctx-child'),
      );
      expect(
        ddi.getChildren<ContextApiService>(
          qualifier: 'parent',
          context: rootContext,
        ),
        isNot(contains('ctx-child')),
      );
    });

    test('destroy without explicit context should not fallback to parent',
        () async {
      final ddi = DDI.newInstance();
      final rootContext = ddi.currentContext;

      await ddi.application<ContextApiService>(
        () => ContextApiService('root'),
        qualifier: 'shared',
      );

      ddi.createContext('ctx');

      await ddi.destroy<ContextApiService>(qualifier: 'shared');

      expect(
        ddi.isRegistered<ContextApiService>(
          qualifier: 'shared',
          context: rootContext,
        ),
        isTrue,
      );
    });
  });
}
