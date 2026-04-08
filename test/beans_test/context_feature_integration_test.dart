import 'package:dart_ddi/dart_ddi.dart';
import 'package:test/test.dart';
import '../clazz_samples/context_feature_integration_samples.dart';

void main() {
  group('DDI Context Feature Integration Tests', () {
    test(
      'captured Instance from a destroyed context should fallback to the root bean',
      () async {
        final ddi = DDI.newInstance();

        await ddi.application<ContextScopedValue>(
          () => const ContextScopedValue('root'),
          qualifier: 'shared',
        );

        ddi.createContext('context-a');

        late Instance<ContextScopedValue> capturedInstance;

        await ddi.application<ContextScopedValue>(
          () => const ContextScopedValue('context'),
          qualifier: 'shared',
        );

        capturedInstance = ddi.getInstance<ContextScopedValue>(
          qualifier: 'shared',
        );

        expect(capturedInstance.get().origin, equals('context'));

        await ddi.destroyContext('context-a');

        expect(ddi.get<ContextScopedValue>(qualifier: 'shared').origin, 'root');
        expect(capturedInstance.isResolvable(), isFalse);
        expect(
          () => capturedInstance.get(),
          throwsA(isA<BeanNotFoundException>()),
        );
        await expectLater(
          capturedInstance.getAsync(),
          throwsA(isA<BeanNotFoundException>()),
        );
      },
    );

    test(
      'contextual module should keep requires and interceptors isolated from a root bean with the same qualifier',
      () async {
        final ddi = DDI.newInstance();

        await ddi.application<MixedService>(
          () => const MixedService(
            origin: 'root',
            dependencyOrigin: 'root-dependency',
          ),
          qualifier: 'shared-service',
        );

        final rootInstance = ddi.getInstance<MixedService>(
          qualifier: 'shared-service',
          cache: true,
        );

        await ddi.singleton(() => MixedContextModule(ddi));
        final module = ddi.get<MixedContextModule>();

        final contextualService = module.cachedSharedInstance.get();
        final rootService = rootInstance.get();
        final contextualInterceptor = ddi.getWith<MixedInterceptor, Object>(
          context: module.contextQualifier,
        );

        expect(contextualService.origin, 'module');
        expect(contextualService.dependencyOrigin, 'module-dependency');
        expect(rootService.origin, 'root');
        expect(rootService.dependencyOrigin, 'root-dependency');
        expect(contextualInterceptor.onCreateCalled, 1);
        expect(contextualInterceptor.onGetCalled, 1);
        expect(
          ddi.isRegistered<MixedDependency>(
            qualifier: 'shared-dependency',
            context: module.contextQualifier,
          ),
          isTrue,
        );
        expect(
          ddi.getChildren<MixedContextModule>(),
          containsAll(
              {'shared-dependency', MixedInterceptor, 'shared-service'}),
        );

        await ddi.destroy<MixedContextModule>();

        expect(rootInstance.get().origin, 'root');
        expect(rootInstance.get().dependencyOrigin, 'root-dependency');
        expect(
          ddi.isRegistered<MixedService>(
            qualifier: 'shared-service',
            context: module.contextQualifier,
          ),
          isFalse,
        );
        expect(
          ddi.isRegistered<MixedDependency>(
            qualifier: 'shared-dependency',
            context: module.contextQualifier,
          ),
          isFalse,
        );
        expect(
          ddi.isRegistered<MixedInterceptor>(context: module.contextQualifier),
          isFalse,
        );
      },
    );
  });
}
