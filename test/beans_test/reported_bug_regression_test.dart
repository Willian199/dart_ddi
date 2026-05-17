import 'package:dart_ddi/dart_ddi.dart';
import 'package:test/test.dart';

import '../clazz_samples/reported_bug_regression_samples.dart';

void main() {
  group('Reported bug regressions', () {
    group('requires validation', () {
      test(
        'application should validate required dependencies again after dispose',
        () async {
          final ddi = DDI.newInstance();

          await ddi.object<RegressionRequiredDependency>(
            RegressionRequiredDependency(),
          );
          await ddi.application<RegressionRequiredApplicationBean>(
            RegressionRequiredApplicationBean.new,
            requires: {RegressionRequiredDependency},
          );

          ddi.get<RegressionRequiredApplicationBean>();
          await ddi.dispose<RegressionRequiredApplicationBean>();
          await ddi.destroy<RegressionRequiredDependency>();

          expect(
            () => ddi.get<RegressionRequiredApplicationBean>(),
            throwsA(isA<MissingDependenciesException>()),
          );

          await ddi.destroy<RegressionRequiredApplicationBean>();
        },
      );

      test(
        'dependent should validate required dependencies on every resolution',
        () async {
          final ddi = DDI.newInstance();

          await ddi.object<RegressionRequiredDependency>(
            RegressionRequiredDependency(),
          );
          await ddi.dependent<RegressionRequiredDependentBean>(
            RegressionRequiredDependentBean.new,
            requires: {RegressionRequiredDependency},
          );

          ddi.get<RegressionRequiredDependentBean>();
          await ddi.destroy<RegressionRequiredDependency>();

          expect(
            () => ddi.get<RegressionRequiredDependentBean>(),
            throwsA(isA<MissingDependenciesException>()),
          );

          await ddi.destroy<RegressionRequiredDependentBean>();
        },
      );
    });

    group('weak application lifecycle', () {
      test(
        'destroy should pass the live weak target to lifecycle hooks',
        () async {
          final ddi = DDI.newInstance();

          await ddi.singleton<RegressionWeakDestroyTrackingInterceptor>(
            RegressionWeakDestroyTrackingInterceptor.new,
          );
          await ddi.application<RegressionWeakDestroyBean>(
            RegressionWeakDestroyBean.new,
            useWeakReference: true,
            interceptors: {RegressionWeakDestroyTrackingInterceptor},
          );

          final bean = ddi.get<RegressionWeakDestroyBean>();
          await ddi.destroy<RegressionWeakDestroyBean>();

          final interceptor =
              ddi.get<RegressionWeakDestroyTrackingInterceptor>();
          expect(bean.preDestroyCalled, isTrue);
          expect(interceptor.destroyedInstance, same(bean));

          await ddi.destroy<RegressionWeakDestroyTrackingInterceptor>();
        },
      );

      test(
        'addDecorator should work after a weak application instance is created',
        () async {
          final ddi = DDI.newInstance();

          await ddi.application<RegressionWeakDecoratedValue>(
            () => const RegressionWeakDecoratedValue(1),
            useWeakReference: true,
          );

          final first = ddi.get<RegressionWeakDecoratedValue>();
          expect(first.value, 1);

          ddi.addDecorator<RegressionWeakDecoratedValue>([
            (value) => RegressionWeakDecoratedValue(value.value + 1),
          ]);

          final second = ddi.get<RegressionWeakDecoratedValue>();
          expect(second.value, 2);

          await ddi.destroy<RegressionWeakDecoratedValue>();
        },
      );
    });

    group('container isolation', () {
      test(
        'inject should resolve dependencies from the target isolated container',
        () async {
          final isolatedDdi = DDI.newInstance();
          final dependency = RegressionIsolatedDependency();

          await isolatedDdi.object<RegressionIsolatedDependency>(dependency);
          await isolatedDdi.singleton<RegressionNeedsIsolatedDependency>(
            RegressionNeedsIsolatedDependency.new.inject(isolatedDdi).call,
          );

          final bean = isolatedDdi.get<RegressionNeedsIsolatedDependency>();
          expect(bean.dependency, same(dependency));

          await isolatedDdi.destroy<RegressionNeedsIsolatedDependency>();
          await isolatedDdi.destroy<RegressionIsolatedDependency>();
        },
      );
    });

    group('context summary', () {
      test(
        'isEmpty and length should describe the whole container, not only the active context',
        () async {
          final ddi = DDI.newInstance();
          final rootContext = ddi.currentContext;

          await ddi.object<RegressionRootOnlyBean>(RegressionRootOnlyBean());
          ddi.createContext('empty-child-context');

          expect(ddi.isEmpty, isFalse);
          expect(ddi.length, 1);

          await ddi.destroy<RegressionRootOnlyBean>(
            context: rootContext,
          );
        },
      );
    });

    group('dependent lifecycle guards', () {
      test(
        'dependent scope should reject unsupported lifecycle mixins with a runtime exception',
        () async {
          final ddi = DDI.newInstance();

          await ddi.dependent<RegressionUnsupportedDependentLifecycleBean>(
            RegressionUnsupportedDependentLifecycleBean.new,
          );

          expect(
            () => ddi.get<RegressionUnsupportedDependentLifecycleBean>(),
            throwsA(isA<UnsupportedLifecycleException>()),
          );

          await ddi.destroy<RegressionUnsupportedDependentLifecycleBean>();
        },
      );
    });
  });
}
