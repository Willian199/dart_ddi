import 'dart:async';

import 'package:dart_ddi/dart_ddi.dart';

class BenchmarkService {}

class BenchmarkInterceptor implements DDIInterceptor {
  int onCreateCalled = 0;
  int onGetCalled = 0;

  @override
  Object onCreate(Object instance) {
    onCreateCalled++;
    return instance;
  }

  @override
  Object onGet(Object instance) {
    onGetCalled++;
    return instance;
  }

  @override
  void onDispose(Object? instance) {}

  @override
  FutureOr<void> onDestroy(Object? instance) {}
}

class ContextualBenchmarkService {
  const ContextualBenchmarkService(this.origin);

  final String origin;
}

class ContextualBenchmarkModule with DDIModule {
  ContextualBenchmarkModule(this._ddiContainer);

  final DDI _ddiContainer;

  late final Instance<ContextualBenchmarkService> contextualInstance;
  late final Instance<ContextualBenchmarkService> cachedContextualInstance;

  @override
  Object? get contextQualifier => moduleQualifier;

  @override
  DDI get ddiContainer => _ddiContainer;

  @override
  Future<void> onPostConstruct() async {
    await ddiContainer.application<BenchmarkInterceptor>(
      BenchmarkInterceptor.new,
      context: contextQualifier,
    );
    await ddiContainer.application<ContextualBenchmarkService>(
      () => const ContextualBenchmarkService('module-context'),
      context: contextQualifier,
      interceptors: {BenchmarkInterceptor},
    );

    contextualInstance = ddiContainer.getInstance<ContextualBenchmarkService>();
    cachedContextualInstance =
        ddiContainer.getInstance<ContextualBenchmarkService>(
      cache: true,
    );
  }
}
