import 'package:dart_ddi/dart_ddi.dart';
import 'package:test/test.dart';

import '../clazz_samples/contextual_instance_modules.dart';
import '../clazz_samples/nested_contextual_modules.dart';

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
      if (ddi.isRegistered<NestedParentModule>()) {
        await ddi.destroy<NestedParentModule>();
      }
      if (ddi.isRegistered<NestedContextValue>()) {
        await ddi.destroy<NestedContextValue>();
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

    test(
        'nested contextual modules should isolate parent and child beans in different contexts and destroy them correctly',
        () async {
      final Object rootContext = ddi.currentContext;

      await ddi.object<NestedContextValue>(NestedContextValue('root'));
      await ddi.singleton(NestedParentModule.new);

      final parentModule = ddi.get<NestedParentModule>();
      final childModule = ddi.getWith<NestedChildModule, Object>();

      final parentContext = parentModule.contextQualifier!;
      final childContext = childModule.contextQualifier!;

      final rootValue = ddi.getWith<NestedContextValue, Object>(
        context: rootContext,
      );

      // The current context is the child context, so it should resolve the child without needing to specify the context.
      final childValue = ddi.getWith<NestedContextValue, Object>();

      final parentValue = ddi.getWith<NestedContextValue, Object>(
        context: parentContext,
      );

      expect(rootValue.origin, 'root');
      expect(parentValue.origin, 'parent');
      expect(childValue.origin, 'child');

      expect(
        ddi.isRegistered<NestedChildModule>(context: parentContext),
        isTrue,
      );
      expect(
        ddi.isRegistered<NestedContextValue>(),
        isTrue,
      );

      await ddi.destroy<NestedParentModule>(context: rootContext);

      expect(
        ddi.isRegistered<NestedParentModule>(context: rootContext),
        isFalse,
      );
      expect(
        ddi.isRegistered<NestedChildModule>(context: parentContext),
        isFalse,
      );
      expect(
        ddi.isRegistered<NestedContextValue>(context: parentContext),
        isFalse,
      );
      expect(
        ddi.isRegistered<NestedContextValue>(context: childContext),
        isFalse,
      );
      expect(
        ddi.getWith<NestedContextValue, Object>(context: rootContext).origin,
        'root',
      );

      await ddi.destroy<NestedContextValue>(context: rootContext);
    });
  });
}
