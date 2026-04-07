import 'package:dart_ddi/dart_ddi.dart';
import 'package:test/test.dart';

import '../clazz_samples/get_with_interceptor_resolution_samples.dart';

void main() {
  group('DDI getWith interceptor resolution', () {
    test(
      'sync getWith should not cache dependent interceptors between calls',
      () {
        final ddi = DDI.newInstance();
        GetWithCountingInterceptor.reset();

        ddi.dependent<GetWithCountingInterceptor>(
          GetWithCountingInterceptor.new,
        );
        ddi.application<GetWithTrackedService>(
          GetWithTrackedService.new,
          interceptors: {GetWithCountingInterceptor},
        );

        final first = ddi.get<GetWithTrackedService>();
        final second = ddi.get<GetWithTrackedService>();

        expect(first, same(second));
        expect(GetWithCountingInterceptor.createdInstances, equals(3));
        expect(GetWithCountingInterceptor.onCreateCalls, equals(1));
        expect(GetWithCountingInterceptor.onGetCalls, equals(2));
      },
    );

    test(
      'async getAsyncWith should not cache dependent interceptors between calls',
      () async {
        final ddi = DDI.newInstance();
        GetWithCountingInterceptor.reset();

        ddi.dependent<GetWithCountingInterceptor>(
          GetWithCountingInterceptor.new,
        );
        ddi.application<GetWithTrackedService>(
          GetWithTrackedService.new,
          interceptors: {GetWithCountingInterceptor},
        );

        final first = await ddi.getAsync<GetWithTrackedService>();
        final second = await ddi.getAsync<GetWithTrackedService>();

        expect(first, same(second));
        expect(GetWithCountingInterceptor.createdInstances, equals(3));
        expect(GetWithCountingInterceptor.onCreateCalls, equals(1));
        expect(GetWithCountingInterceptor.onGetCalls, equals(2));
      },
    );

    test(
      'application getWith should apply onGet on each retrieval',
      () {
        final ddi = DDI.newInstance();
        ddi.singleton<GetWithLayeringInterceptor>(
          GetWithLayeringInterceptor.new,
        );
        ddi.application<GetWithLayeredService>(
          () => const GetWithLayeredService(0),
          interceptors: {GetWithLayeringInterceptor},
        );

        final first = ddi.get<GetWithLayeredService>();
        final second = ddi.get<GetWithLayeredService>();
        final third = ddi.get<GetWithLayeredService>();

        expect(first.level, equals(1));
        expect(second.level, equals(2));
        expect(third.level, equals(3));
      },
    );
  });
}
