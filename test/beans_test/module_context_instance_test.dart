import 'package:dart_ddi/dart_ddi.dart';
import 'package:test/test.dart';

import '../clazz_samples/contextual_instance_modules.dart';

void main() {
  group('DDI Module Context Instance Tests', () {
    tearDown(() async {
      if (ddi.isRegistered<InstanceContext>()) {
        await ddi.destroy<InstanceContext>();
      }
      if (ddi.isRegistered<GlobalModuleA>()) {
        await ddi.destroy<GlobalModuleA>();
      }
      if (ddi.isRegistered<ContextModuleC>()) {
        await ddi.destroy<ContextModuleC>();
      }
      if (ddi.isRegistered<AsyncContextModuleC>()) {
        await ddi.destroy<AsyncContextModuleC>();
      }
    });

    tearDownAll(() {
      expect(ddi.isEmpty, true);
    });

    test(
        'a contextual module should be able to register the same bean type without colliding with the global module',
        () async {
      await ddi.singleton(GlobalModuleA.new);

      await ddi.singleton(ContextModuleC.new);

      expect(
        ddi.get<InstanceContext>().origin,
        equals('context'),
      );
    });

    test(
        'a contextual module should export an Instance<B> that resolves a different B than the global one',
        () async {
      await ddi.singleton(GlobalModuleA.new);

      final Instance<InstanceContext> globalInstance =
          ddi.getInstance<InstanceContext>();

      await ddi.singleton(ContextModuleC.new);

      final Instance<InstanceContext> contextCInstance =
          ddi.getInstance<InstanceContext>();

      await ddi.singleton(AsyncContextModuleC.new);

      final Instance<InstanceContext> contextAsyncInstance =
          ddi.getInstance<InstanceContext>();

      final globalB = globalInstance.get();
      final contextualAsyncB = await contextAsyncInstance.getAsync();
      final contextualB = contextCInstance.get();

      expect(globalB.origin, 'global');
      expect(contextualB.origin, 'context');
      expect(contextualAsyncB.origin, 'context-async');
      expect(identical(globalB, contextualB), isFalse);
      expect(identical(globalB, contextualAsyncB), isFalse);
      expect(identical(contextualB, contextualAsyncB), isFalse);
      // expect(ddi.currentContextPath, isEmpty);
    });
  });
}
