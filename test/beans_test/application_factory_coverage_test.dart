import 'package:dart_ddi/dart_ddi.dart';
import 'package:test/test.dart';

import '../clazz_samples/factory_coverage_samples.dart';

void main() {
  group('Application Factory Coverage', () {
    test('sync creation should create module context when needed', () async {
      final ddi = DDI.newInstance();
      const context = #coverage_application_sync_context;

      await ddi.application<CoverageApplicationModule>(
        () => CoverageApplicationModule(ddi, context),
      );

      ddi.get<CoverageApplicationModule>();

      expect(ddi.contextExists(context), isTrue);
    });

    test('async creation should create module context when needed', () async {
      final ddi = DDI.newInstance();
      const context = #coverage_application_async_context;

      await ddi.application<CoverageApplicationModule>(
        () async => CoverageApplicationModule(ddi, context),
        qualifier: 'async-module',
      );

      await ddi.getAsync<CoverageApplicationModule>(qualifier: 'async-module');

      expect(ddi.contextExists(context), isTrue);
    });

    test('dispose should cleanup module context created by application factory',
        () async {
      final ddi = DDI.newInstance();
      const context = #coverage_application_dispose_context;

      await ddi.application<CoverageApplicationModule>(
        () => CoverageApplicationModule(ddi, context),
        qualifier: 'module-for-dispose',
      );

      ddi.get<CoverageApplicationModule>(qualifier: 'module-for-dispose');
      expect(ddi.contextExists(context), isTrue);

      await ddi.dispose<CoverageApplicationModule>(
          qualifier: 'module-for-dispose');

      expect(ddi.contextExists(context), isFalse);
    });

    test(
        'getAsync with weak reference and interceptors should keep working across calls',
        () async {
      final ddi = DDI.newInstance();

      await ddi.singleton<CoverageIdentityInterceptor>(
        CoverageIdentityInterceptor.new,
      );

      await ddi.application<CoverageValue>(
        () => const CoverageValue(1),
        useWeakReference: true,
        interceptors: {CoverageIdentityInterceptor},
      );

      final first = await ddi.getAsync<CoverageValue>();
      final second = await ddi.getAsync<CoverageValue>();

      expect(first.id, equals(1));
      expect(second.id, equals(1));
    });

    test('async self-resolution should throw ConcurrentCreationException',
        () async {
      final ddi = DDI.newInstance();

      await ddi.application<String>(
        () async {
          await ddi.getAsync<String>();
          return 'never';
        },
      );

      await expectLater(
        ddi.getAsync<String>(),
        throwsA(isA<ConcurrentCreationException>()),
      );
    });
  });
}
