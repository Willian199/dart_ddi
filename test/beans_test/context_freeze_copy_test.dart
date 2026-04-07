import 'package:dart_ddi/dart_ddi.dart';
import 'package:test/test.dart';
import '../clazz_samples/freeze_service.dart';

void main() {
  group('DDI Context Freeze Tests', () {
    test('freezeContext should block register in the frozen context only',
        () async {
      final ddi = DDI.newInstance();
      ddi.createContext('frozen');
      ddi.createContext('open');

      await ddi.application<FreezeService>(
        () => FreezeService('frozen'),
        qualifier: 'service',
        context: 'frozen',
      );

      ddi.freezeContext('frozen');

      await expectLater(
        ddi.application<FreezeService>(
          () => FreezeService('blocked'),
          qualifier: 'blocked',
          context: 'frozen',
        ),
        throwsA(isA<ContextFrozenException>()),
      );

      await ddi.application<FreezeService>(
        () => FreezeService('open'),
        qualifier: 'service',
        context: 'open',
      );

      expect(
        ddi
            .getWith<FreezeService, Object>(
              qualifier: 'service',
              context: 'frozen',
            )
            .value,
        equals('frozen'),
      );
      expect(
        ddi
            .getWith<FreezeService, Object>(
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
        ddi.application<FreezeService>(
          () => FreezeService('blocked'),
          qualifier: 'service',
          context: 'maintenance',
        ),
        throwsA(isA<ContextFrozenException>()),
      );

      ddi.unfreezeContext('maintenance');
      await ddi.application<FreezeService>(
        () => FreezeService('allowed'),
        qualifier: 'service',
        context: 'maintenance',
      );

      expect(
        ddi
            .getWith<FreezeService, Object>(
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

      await ddi.singleton<FreezeService>(
        () => FreezeService('base'),
        qualifier: 'service',
        context: 'ctx',
      );

      ddi.freezeContext('ctx');

      expect(
        () => ddi.addDecorator<FreezeService>(
          [(service) => FreezeService('${service.value}-decorated')],
          qualifier: 'service',
        ),
        throwsA(isA<ContextFrozenException>()),
      );

      expect(
        () => ddi.addInterceptor<FreezeService>(
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

        await ddi.application<FreezeService>(
          () => FreezeService('value'),
          qualifier: 'service',
          context: 'ctx',
        );

        ddi.freezeContext('ctx');

        expect(
          () => ddi.destroy<FreezeService>(
            qualifier: 'service',
            context: 'ctx',
          ),
          throwsA(isA<ContextFrozenException>()),
        );

        expect(
          () => ddi.dispose<FreezeService>(
            qualifier: 'service',
            context: 'ctx',
          ),
          throwsA(isA<ContextFrozenException>()),
        );

        expect(
          () => ddi.destroyByType<FreezeService>(context: 'ctx'),
          throwsA(isA<ContextFrozenException>()),
        );

        expect(
          () => ddi.addChildrenModules<FreezeService>(
            qualifier: 'service',
            child: {'child-module'},
          ),
          throwsA(isA<ContextFrozenException>()),
        );
      },
    );
  });
}
