import 'package:dart_ddi/dart_ddi.dart';
import 'package:test/test.dart';

class _ZoneScopedValue {
  const _ZoneScopedValue(this.origin);

  final String origin;
}

class _MixedDependency {
  const _MixedDependency(this.origin);

  final String origin;
}

class _MixedService {
  const _MixedService({
    required this.origin,
    required this.dependencyOrigin,
  });

  final String origin;
  final String dependencyOrigin;
}

class _MixedInterceptor extends DDIInterceptor<_MixedService> {
  int onCreateCalled = 0;
  int onGetCalled = 0;

  @override
  _MixedService onCreate(_MixedService instance) {
    onCreateCalled++;
    return instance;
  }

  @override
  _MixedService onGet(_MixedService instance) {
    onGetCalled++;
    return instance;
  }
}

class _MixedContextModule with DDIModule {
  _MixedContextModule(this._ddiContainer);

  final DDI _ddiContainer;

  late final Instance<_MixedService> cachedSharedInstance;

  @override
  DDI get ddiContainer => _ddiContainer;

  @override
  Object? get contextQualifier => moduleQualifier;

  @override
  Future<void> onPostConstruct() async {
    ddiContainer.addChildrenModules<_MixedContextModule>(
      qualifier: moduleQualifier,
      child: {
        'shared-dependency',
        _MixedInterceptor,
        'shared-service',
      },
    );

    await ddiContainer.application<_MixedDependency>(
      () => const _MixedDependency('module-dependency'),
      qualifier: 'shared-dependency',
      context: contextQualifier,
    );

    await ddiContainer.application<_MixedInterceptor>(
      _MixedInterceptor.new,
      context: contextQualifier,
    );

    await ddiContainer.application<_MixedService>(
      () => _MixedService(
        origin: 'module',
        dependencyOrigin: ddiContainer
            .getWith<_MixedDependency, Object>(
              qualifier: 'shared-dependency',
              context: contextQualifier,
            )
            .origin,
      ),
      qualifier: 'shared-service',
      context: contextQualifier,
      requires: {'shared-dependency'},
      interceptors: {_MixedInterceptor},
    );

    cachedSharedInstance = ddiContainer.getInstance<_MixedService>(
      qualifier: 'shared-service',
      cache: true,
    );
  }
}

void main() {
  group('DDI Context Feature Integration Tests', () {
    test(
      'captured Instance from a cleaned zone should fallback to the root bean',
      () async {
        final ddi = DDI.newInstance(enableZoneRegistry: true);

        await ddi.application<_ZoneScopedValue>(
          () => const _ZoneScopedValue('root'),
          qualifier: 'shared',
        );

        late Instance<_ZoneScopedValue> capturedInstance;

        await ddi.runInContext('zone-a', () async {
          await ddi.application<_ZoneScopedValue>(
            () => const _ZoneScopedValue('zone'),
            qualifier: 'shared',
          );

          capturedInstance = ddi.getInstance<_ZoneScopedValue>(
            qualifier: 'shared',
          );

          expect(capturedInstance.get().origin, equals('zone'));
        });

        expect(ddi.get<_ZoneScopedValue>(qualifier: 'shared').origin, 'root');
        expect(capturedInstance.isResolvable(), isFalse);
        expect(capturedInstance.get().origin, equals('root'));
        expect((await capturedInstance.getAsync()).origin, equals('root'));
      },
    );

    test(
      'contextual module should keep requires and interceptors isolated from a root bean with the same qualifier',
      () async {
        final ddi = DDI.newInstance();

        await ddi.application<_MixedService>(
          () => const _MixedService(
            origin: 'root',
            dependencyOrigin: 'root-dependency',
          ),
          qualifier: 'shared-service',
        );

        final rootInstance = ddi.getInstance<_MixedService>(
          qualifier: 'shared-service',
          cache: true,
        );

        await ddi.singleton(() => _MixedContextModule(ddi));
        final module = ddi.get<_MixedContextModule>();

        final contextualService = module.cachedSharedInstance.get();
        final rootService = rootInstance.get();
        final contextualInterceptor = ddi.getWith<_MixedInterceptor, Object>(
          context: module.contextQualifier,
        );

        expect(contextualService.origin, 'module');
        expect(contextualService.dependencyOrigin, 'module-dependency');
        expect(rootService.origin, 'root');
        expect(rootService.dependencyOrigin, 'root-dependency');
        expect(contextualInterceptor.onCreateCalled, 1);
        expect(contextualInterceptor.onGetCalled, 1);
        expect(
          ddi.isRegistered<_MixedDependency>(
            qualifier: 'shared-dependency',
            context: module.contextQualifier,
          ),
          isTrue,
        );
        expect(
          ddi.getChildren<_MixedContextModule>(),
          containsAll(
              {'shared-dependency', _MixedInterceptor, 'shared-service'}),
        );

        await ddi.destroy<_MixedContextModule>();

        expect(rootInstance.get().origin, 'root');
        expect(rootInstance.get().dependencyOrigin, 'root-dependency');
        expect(
          ddi.isRegistered<_MixedService>(
            qualifier: 'shared-service',
            context: module.contextQualifier,
          ),
          isFalse,
        );
        expect(
          ddi.isRegistered<_MixedDependency>(
            qualifier: 'shared-dependency',
            context: module.contextQualifier,
          ),
          isFalse,
        );
        expect(
          ddi.isRegistered<_MixedInterceptor>(context: module.contextQualifier),
          isFalse,
        );
      },
    );
  });
}
