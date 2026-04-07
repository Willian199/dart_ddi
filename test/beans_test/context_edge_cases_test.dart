import 'package:dart_ddi/dart_ddi.dart';
import 'package:test/test.dart';

class _EdgeService {
  const _EdgeService(this.origin);

  final String origin;
}

void main() {
  group('DDI Context Edge Cases Tests', () {
    test(
      'explicit context selector should resolve from its own context even when another context is active',
      () async {
        final ddi = DDI.newInstance();
        ddi.createContext('ctx');
        ddi.createContext('other');

        await ddi.application<_EdgeService>(
          () => const _EdgeService('ctx-a'),
          qualifier: 'ctx-a',
          context: 'ctx',
          selector: (value) => value == 'a',
        );

        await ddi.application<_EdgeService>(
          () => const _EdgeService('other-b'),
          qualifier: 'other-b',
          context: 'other',
          selector: (value) => value == 'b',
        );

        expect(ddi.currentContext, equals('other'));
        expect(
          ddi.getWith<_EdgeService, Object>(select: 'a', context: 'ctx').origin,
          equals('ctx-a'),
        );
        expect(
          ddi
              .getWith<_EdgeService, Object>(qualifier: 'ctx-a', context: 'ctx')
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

        await ddi.application<_EdgeService>(
          () async => const _EdgeService('ctx-a'),
          qualifier: 'ctx-a',
          context: 'ctx',
          selector: (value) async => value == 'a',
        );

        await ddi.application<_EdgeService>(
          () async => const _EdgeService('other-b'),
          qualifier: 'other-b',
          context: 'other',
          selector: (value) async => value == 'b',
        );

        expect(ddi.currentContext, equals('other'));
        expect(
          (await ddi.getAsyncWith<_EdgeService, Object>(
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

        await ddi.application<_EdgeService>(
          () => const _EdgeService('root'),
          qualifier: 'root-service',
        );

        ddi.createContext('ctx');
        await ddi.application<_EdgeService>(
          () => const _EdgeService('ctx'),
          qualifier: 'ctx-service',
          context: 'ctx',
        );

        expect(ddi.currentContext, equals('ctx'));

        expect(
          ddi.getWith<_EdgeService, Object>(qualifier: 'root-service').origin,
          equals('root'),
        );

        expect(
          ddi
              .getWith<_EdgeService, Object>(
                qualifier: 'root-service',
                context: 'ctx',
              )
              .origin,
          equals('root'),
        );
      },
    );
  });
}
