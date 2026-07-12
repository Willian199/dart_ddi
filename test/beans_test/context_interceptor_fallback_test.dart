import 'package:dart_ddi/dart_ddi.dart';
import 'package:test/test.dart';

final class ContextFallbackService {
  const ContextFallbackService(this.value);

  final int value;
}

final class ContextFallbackInterceptor
    extends DDIInterceptor<ContextFallbackService> {
  @override
  ContextFallbackService onGet(ContextFallbackService instance) {
    return ContextFallbackService(instance.value + 1);
  }
}

void main() {
  test(
    'sync resolution should find a parent interceptor from a child context',
    () async {
      final ddi = DDI.newInstance();

      await ddi.singleton<ContextFallbackInterceptor>(
        ContextFallbackInterceptor.new,
      );
      await ddi.singleton<ContextFallbackService>(
        () => const ContextFallbackService(0),
        interceptors: {ContextFallbackInterceptor},
      );

      ddi.createContext('child');

      expect(ddi.get<ContextFallbackService>().value, equals(1));
    },
  );
}
