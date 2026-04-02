import 'package:dart_ddi/dart_ddi.dart';
import 'package:test/test.dart';

void main() {
  group('DDI Default Context Tests', () {
    test(
      'default qualifier should support contextual override and restore the global bean afterwards',
      () async {
        final newDdi = DDI.newInstance();

        await newDdi.singleton<String>(() => 'global', qualifier: 'message');

        await newDdi.runInContext('context-1', () async {
          await newDdi.singleton<String>(() => 'context', qualifier: 'message');

          expect(
            newDdi.get<String>(qualifier: 'message'),
            equals('context'),
          );
        });

        expect(
          newDdi.get<String>(qualifier: 'message'),
          equals('global'),
        );
      },
    );
  });
}
