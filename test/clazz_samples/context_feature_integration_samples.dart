import 'package:dart_ddi/dart_ddi.dart';

class ZoneScopedValue {
  const ZoneScopedValue(this.origin);

  final String origin;
}

class MixedDependency {
  const MixedDependency(this.origin);

  final String origin;
}

class MixedService {
  const MixedService({
    required this.origin,
    required this.dependencyOrigin,
  });

  final String origin;
  final String dependencyOrigin;
}

class MixedInterceptor extends DDIInterceptor<MixedService> {
  int onCreateCalled = 0;
  int onGetCalled = 0;

  @override
  MixedService onCreate(MixedService instance) {
    onCreateCalled++;
    return instance;
  }

  @override
  MixedService onGet(MixedService instance) {
    onGetCalled++;
    return instance;
  }
}

class MixedContextModule with DDIModule {
  MixedContextModule(this._ddiContainer);

  final DDI _ddiContainer;

  late final Instance<MixedService> cachedSharedInstance;

  @override
  DDI get ddiContainer => _ddiContainer;

  @override
  Object? get contextQualifier => moduleQualifier;

  @override
  Future<void> onPostConstruct() async {
    ddiContainer.addChildrenModules<MixedContextModule>(
      qualifier: moduleQualifier,
      child: {
        'shared-dependency',
        MixedInterceptor,
        'shared-service',
      },
    );

    await ddiContainer.application<MixedDependency>(
      () => const MixedDependency('module-dependency'),
      qualifier: 'shared-dependency',
      context: contextQualifier,
    );

    await ddiContainer.application<MixedInterceptor>(
      MixedInterceptor.new,
      context: contextQualifier,
    );

    await ddiContainer.application<MixedService>(
      () => MixedService(
        origin: 'module',
        dependencyOrigin: ddiContainer
            .getWith<MixedDependency, Object>(
              qualifier: 'shared-dependency',
              context: contextQualifier,
            )
            .origin,
      ),
      qualifier: 'shared-service',
      context: contextQualifier,
      requires: {'shared-dependency'},
      interceptors: {MixedInterceptor},
    );

    cachedSharedInstance = ddiContainer.getInstance<MixedService>(
      qualifier: 'shared-service',
      cache: true,
    );
  }
}
