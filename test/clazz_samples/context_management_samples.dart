import 'dart:async';

import 'package:dart_ddi/dart_ddi.dart';

class ContextManagementBean {
  const ContextManagementBean(this.origin);

  final String origin;
}

class TrackedDestroyBean with PreDestroy {
  TrackedDestroyBean(this.id, this.events);

  final String id;
  final List<String> events;

  @override
  void onPreDestroy() {
    events.add(id);
  }
}

class ProbeBean {
  const ProbeBean(this.origin);

  final String origin;
}

class NoneStateFactory extends DDIBaseFactory<ProbeBean> {
  NoneStateFactory() : super(selector: null);

  @override
  BeanStateEnum get state => BeanStateEnum.none;

  @override
  bool get isFuture => false;

  @override
  bool get isReady => false;

  @override
  bool get isRegistered => false;

  @override
  bool get canDestroy => true;

  @override
  Future<void> register({
    required Object qualifier,
    required DDI ddiInstance,
  }) async {}

  @override
  ProbeBean getWith<ParameterT extends Object>({
    required Object qualifier,
    required DDI ddiInstance,
    ParameterT? parameter,
  }) {
    return const ProbeBean('none-state');
  }

  @override
  Future<ProbeBean> getAsyncWith<ParameterT extends Object>({
    required Object qualifier,
    required DDI ddiInstance,
    ParameterT? parameter,
  }) async {
    return const ProbeBean('none-state');
  }

  @override
  FutureOr<void> destroy({
    required void Function() apply,
    required DDI ddiInstance,
  }) {
    apply();
  }

  @override
  Future<void> dispose({required DDI ddiInstance}) async {}
}

class AutoContextModuleSample with DDIModule {
  AutoContextModuleSample(this._ddi);

  final DDI _ddi;

  @override
  DDI get ddiContainer => _ddi;

  @override
  Object? get contextQualifier => moduleQualifier;

  @override
  Future<void> onPostConstruct() async {
    await object<ContextManagementBean>(const ContextManagementBean('module'));
  }
}

class LockedChildModuleSample with DDIModule {
  LockedChildModuleSample(this._ddi);

  final DDI _ddi;

  @override
  DDI get ddiContainer => _ddi;

  @override
  Object? get contextQualifier => moduleQualifier;

  @override
  Future<void> onPostConstruct() async {
    await application<ContextManagementBean>(
      () => const ContextManagementBean('locked-child'),
      qualifier: 'locked-child',
      canDestroy: false,
    );
  }
}

class SlowDestroyBean {
  const SlowDestroyBean(this.value);

  final String value;
}

class SlowDestroyFactory extends DDIBaseFactory<SlowDestroyBean> {
  SlowDestroyFactory({
    required this.destroyStarted,
    required this.releaseDestroy,
  }) : super(selector: null);

  final Completer<void> destroyStarted;
  final Completer<void> releaseDestroy;

  @override
  BeanStateEnum get state => BeanStateEnum.created;

  @override
  bool get isFuture => false;

  @override
  bool get isReady => true;

  @override
  bool get isRegistered => true;

  @override
  bool get canDestroy => true;

  @override
  Future<void> register({
    required Object qualifier,
    required DDI ddiInstance,
  }) async {}

  @override
  SlowDestroyBean getWith<ParameterT extends Object>({
    required Object qualifier,
    required DDI ddiInstance,
    ParameterT? parameter,
  }) {
    return const SlowDestroyBean('slow');
  }

  @override
  Future<SlowDestroyBean> getAsyncWith<ParameterT extends Object>({
    required Object qualifier,
    required DDI ddiInstance,
    ParameterT? parameter,
  }) async {
    return const SlowDestroyBean('slow');
  }

  @override
  Future<void> destroy({
    required void Function() apply,
    required DDI ddiInstance,
  }) async {
    if (!destroyStarted.isCompleted) {
      destroyStarted.complete();
    }

    await releaseDestroy.future;
    apply();
  }

  @override
  Future<void> dispose({required DDI ddiInstance}) async {}
}
