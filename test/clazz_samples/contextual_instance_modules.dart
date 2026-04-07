import 'package:dart_ddi/dart_ddi.dart';

class InstanceContext {
  InstanceContext(this.origin);

  final String origin;
}

class GlobalModuleA with DDIModule {
  @override
  Future<void> onPostConstruct() async {
    await object<InstanceContext>(InstanceContext('global'));
  }
}

class ContextModuleC with DDIModule {
  @override
  Object? get contextQualifier => moduleQualifier;

  @override
  Future<void> onPostConstruct() async {
    await object<InstanceContext>(InstanceContext('context'));
  }
}

class AsyncContextModuleC with DDIModule {
  @override
  Object? get contextQualifier => moduleQualifier;

  @override
  Future<void> onPostConstruct() async {
    await application<InstanceContext>(
      () async {
        await Future<void>.delayed(const Duration(milliseconds: 5));
        return InstanceContext('context-async');
      },
    );
  }
}
