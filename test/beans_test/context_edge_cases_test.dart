import 'package:dart_ddi/dart_ddi.dart';
import 'package:test/test.dart';
import '../clazz_samples/edge_service.dart';

void main() {
  group('DDI Context Edge Cases Tests', () {
    test(
      'explicit context selector should resolve from its own context even when another context is active',
      () async {
        final ddi = DDI.newInstance();
        ddi.createContext('ctx');
        ddi.createContext('other');

        await ddi.application<EdgeService>(
          () => const EdgeService('ctx-a'),
          qualifier: 'ctx-a',
          context: 'ctx',
          selector: (value) => value == 'a',
        );

        await ddi.application<EdgeService>(
          () => const EdgeService('other-b'),
          qualifier: 'other-b',
          context: 'other',
          selector: (value) => value == 'b',
        );

        expect(ddi.currentContext, equals('other'));
        expect(
          ddi.getWith<EdgeService, Object>(select: 'a', context: 'ctx').origin,
          equals('ctx-a'),
        );
        expect(
          ddi
              .getWith<EdgeService, Object>(qualifier: 'ctx-a', context: 'ctx')
              .origin,
          equals('ctx-a'),
        );
      },
    );

    test(
      'explicit async selector should resolve from its own context even when another context is active',
      () async {
        final ddi = DDI.newInstance();
        ddi.createContext('ctx');
        ddi.createContext('other');

        await ddi.application<EdgeService>(
          () async => const EdgeService('ctx-a'),
          qualifier: 'ctx-a',
          context: 'ctx',
          selector: (value) async => value == 'a',
        );

        await ddi.application<EdgeService>(
          () async => const EdgeService('other-b'),
          qualifier: 'other-b',
          context: 'other',
          selector: (value) async => value == 'b',
        );

        expect(ddi.currentContext, equals('other'));
        expect(
          (await ddi.getAsyncWith<EdgeService, Object>(
            select: 'a',
            context: 'ctx',
          ))
              .origin,
          equals('ctx-a'),
        );
      },
    );

    test(
      'implicit and explicit context get should fallback to root',
      () async {
        final ddi = DDI.newInstance();

        await ddi.application<EdgeService>(
          () => const EdgeService('root'),
          qualifier: 'root-service',
        );

        ddi.createContext('ctx');
        await ddi.application<EdgeService>(
          () => const EdgeService('ctx'),
          qualifier: 'ctx-service',
          context: 'ctx',
        );

        expect(ddi.currentContext, equals('ctx'));

        expect(
          ddi.getWith<EdgeService, Object>(qualifier: 'root-service').origin,
          equals('root'),
        );

        expect(
          ddi
              .getWith<EdgeService, Object>(
                qualifier: 'root-service',
                context: 'ctx',
              )
              .origin,
          equals('root'),
        );
      },
    );

    test(
      'destroyByType should respect explicit context argument',
      () async {
        final ddi = DDI.newInstance();
        ddi.createContext('c1');
        ddi.createContext('c2');

        await ddi.singleton<EdgeService>(
          () => const EdgeService('c1'),
          qualifier: 'c1-service',
          context: 'c1',
        );

        await ddi.singleton<EdgeService>(
          () => const EdgeService('c2'),
          qualifier: 'c2-service',
          context: 'c2',
        );

        expect(
          ddi.isRegistered<EdgeService>(qualifier: 'c1-service', context: 'c1'),
          isTrue,
        );
        expect(
          ddi.isRegistered<EdgeService>(qualifier: 'c2-service', context: 'c2'),
          isTrue,
        );

        ddi.destroyByType<EdgeService>(context: 'c1');

        expect(
          ddi.isRegistered<EdgeService>(qualifier: 'c1-service', context: 'c1'),
          isFalse,
        );
        expect(
          ddi.isRegistered<EdgeService>(qualifier: 'c2-service', context: 'c2'),
          isTrue,
        );
      },
    );
  });
}
