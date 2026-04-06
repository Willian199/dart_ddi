import 'package:dart_ddi/dart_ddi.dart';
import 'package:test/test.dart';

class _FreezeService {
  _FreezeService(this.value);

  final String value;
}

void main() {
  group('DDI Context Freeze Tests', () {
    test('freezeContext should block register in the frozen context only',
        () async {
      final ddi = DDI.newInstance();
      ddi.createContext('frozen');
      ddi.createContext('open');

      await ddi.application<_FreezeService>(
        () => _FreezeService('frozen'),
        qualifier: 'service',
        context: 'frozen',
      );

      ddi.freezeContext('frozen');

      await expectLater(
        ddi.application<_FreezeService>(
          () => _FreezeService('blocked'),
          qualifier: 'blocked',
          context: 'frozen',
        ),
        throwsA(isA<ContextFrozenException>()),
      );

      await ddi.application<_FreezeService>(
        () => _FreezeService('open'),
        qualifier: 'service',
        context: 'open',
      );

      expect(
        ddi
            .getWith<_FreezeService, Object>(
              qualifier: 'service',
              context: 'frozen',
            )
            .value,
        equals('frozen'),
      );
      expect(
        ddi
            .getWith<_FreezeService, Object>(
              qualifier: 'service',
              context: 'open',
            )
            .value,
        equals('open'),
      );
    });

    test('unfreezeContext should allow new registrations again', () async {
      final ddi = DDI.newInstance();
      ddi.createContext('maintenance');
      ddi.freezeContext('maintenance');

      await expectLater(
        ddi.application<_FreezeService>(
          () => _FreezeService('blocked'),
          qualifier: 'service',
          context: 'maintenance',
        ),
        throwsA(isA<ContextFrozenException>()),
      );

      ddi.unfreezeContext('maintenance');
      await ddi.application<_FreezeService>(
        () => _FreezeService('allowed'),
        qualifier: 'service',
        context: 'maintenance',
      );

      expect(
        ddi
            .getWith<_FreezeService, Object>(
              qualifier: 'service',
              context: 'maintenance',
            )
            .value,
        equals('allowed'),
      );
    });

    test('freezeContext should block addDecorator and addInterceptor',
        () async {
      final ddi = DDI.newInstance();
      ddi.createContext('ctx');

      await ddi.singleton<_FreezeService>(
        () => _FreezeService('base'),
        qualifier: 'service',
        context: 'ctx',
      );

      ddi.freezeContext('ctx');

      expect(
        () => ddi.addDecorator<_FreezeService>(
          [(service) => _FreezeService('${service.value}-decorated')],
          qualifier: 'service',
        ),
        throwsA(isA<ContextFrozenException>()),
      );

      expect(
        () => ddi.addInterceptor<_FreezeService>(
          {'interceptor'},
          qualifier: 'service',
        ),
        throwsA(isA<ContextFrozenException>()),
      );
    });

    test(
      'freezeContext should block destroy, dispose, destroyByType and addChildrenModules',
      () async {
        final ddi = DDI.newInstance();
        ddi.createContext('ctx');

        await ddi.application<_FreezeService>(
          () => _FreezeService('value'),
          qualifier: 'service',
          context: 'ctx',
        );

        ddi.freezeContext('ctx');

        expect(
          () => ddi.destroy<_FreezeService>(
            qualifier: 'service',
            context: 'ctx',
          ),
          throwsA(isA<ContextFrozenException>()),
        );

        expect(
          () => ddi.dispose<_FreezeService>(
            qualifier: 'service',
            context: 'ctx',
          ),
          throwsA(isA<ContextFrozenException>()),
        );

        expect(
          () => ddi.destroyByType<_FreezeService>('ctx'),
          throwsA(isA<ContextFrozenException>()),
        );

        expect(
          () => ddi.addChildrenModules<_FreezeService>(
            qualifier: 'service',
            child: {'child-module'},
          ),
          throwsA(isA<ContextFrozenException>()),
        );
      },
    );
  });
}
