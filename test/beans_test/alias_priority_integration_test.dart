import 'package:dart_ddi/dart_ddi.dart';
import 'package:test/test.dart';

abstract class AliasPriorityService {
  String get id;
}

final class _ServiceImpl implements AliasPriorityService {
  const _ServiceImpl(this.id);

  @override
  final String id;
}

final class _Box {
  const _Box(this.value);

  final String value;
}

final class _BoxInterceptor extends DDIInterceptor<_Box> {
  @override
  _Box onGet(_Box instance) => _Box('${instance.value}|intercepted');
}

void main() {
  group('Alias + Priority Integration', () {
    test('local context should shadow parent regardless of parent priority',
        () async {
      final ddi = DDI.newInstance();

      await ddi.application<AliasPriorityService>(
        () => const _ServiceImpl('root-high'),
        qualifier: 'root-high',
        priority: 10,
      );
      await ddi.application<AliasPriorityService>(
        () => const _ServiceImpl('root-low'),
        qualifier: 'root-low',
        priority: 1,
      );

      ddi.createContext('ctx');
      await ddi.application<AliasPriorityService>(
        () => const _ServiceImpl('ctx-only'),
        qualifier: 'ctx-only',
        context: 'ctx',
        priority: 99,
      );

      expect(ddi.get<AliasPriorityService>().id, equals('ctx-only'));

      await ddi.destroy<AliasPriorityService>(
        qualifier: 'ctx-only',
        context: 'ctx',
      );

      expect(ddi.get<AliasPriorityService>().id, equals('root-low'));
    });

    test('selector should still work when plain alias lookup is ambiguous',
        () async {
      final ddi = DDI.newInstance();

      await ddi.application<AliasPriorityService>(
        () => const _ServiceImpl('A'),
        qualifier: 'service-a',
        priority: 1,
        selector: (value) => value == 'A',
      );
      await ddi.application<AliasPriorityService>(
        () => const _ServiceImpl('B'),
        qualifier: 'service-b',
        priority: 1,
        selector: (value) => value == 'B',
      );

      expect(
        () => ddi.get<AliasPriorityService>(),
        throwsA(isA<AmbiguousAliasException>()),
      );

      final selected = ddi.getWith<AliasPriorityService, Object>(select: 'B');
      expect(selected.id, equals('B'));
    });

    test('addDecorator without qualifier should target chosen priority bean',
        () async {
      final ddi = DDI.newInstance();

      await ddi.application<_Box>(
        () => const _Box('low'),
        qualifier: 'low',
        priority: 10,
      );
      await ddi.application<_Box>(
        () => const _Box('high'),
        qualifier: 'high',
        priority: 1,
      );

      await ddi.addDecorator<_Box>([
        (value) => _Box('${value.value}|decorated'),
      ]);

      expect(ddi.get<_Box>().value, equals('high|decorated'));
      expect(ddi.get<_Box>(qualifier: 'low').value, equals('low'));
    });

    test('addInterceptor without qualifier should target chosen priority bean',
        () async {
      final ddi = DDI.newInstance();

      await ddi.object<_BoxInterceptor>(_BoxInterceptor());

      await ddi.application<_Box>(
        () => const _Box('low'),
        qualifier: 'low',
        priority: 10,
      );
      await ddi.application<_Box>(
        () => const _Box('high'),
        qualifier: 'high',
        priority: 1,
      );

      ddi.addInterceptor<_Box>({_BoxInterceptor});

      expect(ddi.get<_Box>().value, equals('high|intercepted'));
      expect(ddi.get<_Box>(qualifier: 'low').value, equals('low'));
    });

    test('ambiguous local tie should throw even if parent has winner',
        () async {
      final ddi = DDI.newInstance();

      await ddi.application<AliasPriorityService>(
        () => const _ServiceImpl('root-winner'),
        qualifier: 'root-winner',
        priority: 1,
      );

      ddi.createContext('ctx');
      await ddi.application<AliasPriorityService>(
        () => const _ServiceImpl('ctx-a'),
        qualifier: 'ctx-a',
        context: 'ctx',
      );
      await ddi.application<AliasPriorityService>(
        () => const _ServiceImpl('ctx-b'),
        qualifier: 'ctx-b',
        context: 'ctx',
      );

      expect(
        () => ddi.getWith<AliasPriorityService, Object>(context: 'ctx'),
        throwsA(
          isA<AmbiguousAliasException>().having(
            (e) => e.qualifiers,
            'qualifiers',
            containsAll(<Object>{'ctx-a', 'ctx-b'}),
          ),
        ),
      );
    });
  });
}
