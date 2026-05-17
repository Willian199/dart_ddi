import 'package:dart_ddi/dart_ddi.dart';

final class RegressionRequiredDependency {}

final class RegressionRequiredApplicationBean {}

final class RegressionRequiredDependentBean {}

final class RegressionWeakDestroyBean with PreDestroy {
  bool preDestroyCalled = false;

  @override
  void onPreDestroy() {
    preDestroyCalled = true;
  }
}

final class RegressionWeakDestroyTrackingInterceptor
    extends DDIInterceptor<RegressionWeakDestroyBean> {
  RegressionWeakDestroyBean? destroyedInstance;

  @override
  void onDestroy(RegressionWeakDestroyBean? instance) {
    destroyedInstance = instance;
  }
}

final class RegressionWeakDecoratedValue {
  const RegressionWeakDecoratedValue(this.value);

  final int value;
}

final class RegressionIsolatedDependency {}

final class RegressionNeedsIsolatedDependency {
  const RegressionNeedsIsolatedDependency(this.dependency);

  final RegressionIsolatedDependency dependency;
}

final class RegressionRootOnlyBean {}

final class RegressionUnsupportedDependentLifecycleBean with PreDestroy {
  @override
  void onPreDestroy() {}
}
