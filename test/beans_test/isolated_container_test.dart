import 'package:dart_ddi/dart_ddi.dart';
import 'package:test/test.dart';

import '../clazz_samples/a.dart';
import '../clazz_samples/b.dart';
import '../clazz_samples/c.dart';
import '../clazz_samples/custom_interceptors.dart';
import '../clazz_samples/module_factory_application.dart';
import '../clazz_samples/module_factory_application_isolated.dart';
import '../clazz_samples/module_factory_singleton.dart';
import '../clazz_samples/multi_inject.dart';

void main() {
  group('DDI Isolated Container Tests', () {
    tearDown(() {
      ddi.destroyByType<A>();
      ddi.destroyByType<B>();
      ddi.destroyByType<C>();
      ddi.destroyByType<MultiInject>();
      ddi.destroyByType<ModuleFactoryApplication>();
      ddi.destroyByType<ModuleFactoryApplicationIsolated>();
      ddi.destroyByType<AddInterceptor>();
      ddi.destroyByType<MultiplyInterceptor>();
      ddi.destroyByType<AsyncAddInterceptor>();
      ddi.destroyByType<int>();
    });

    tearDownAll(() {
      expect(ddi.isEmpty, true);
    });

    group('Interceptors with Isolated Container', () {
      test('Should use interceptors from the correct container', () {
        final newDdi = DDI.newInstance();

        // Register interceptors in default container
        ddi.singleton<AddInterceptor>(AddInterceptor.new);
        ddi.singleton<MultiplyInterceptor>(MultiplyInterceptor.new);

        // Register interceptors in new container
        newDdi.singleton<AddInterceptor>(AddInterceptor.new);
        newDdi.singleton<MultiplyInterceptor>(MultiplyInterceptor.new);

        // Register int with interceptor in default container
        ddi.object<int>(
          10,
          interceptors: {AddInterceptor, MultiplyInterceptor},
        );

        // Register int with interceptor in new container
        newDdi.object<int>(
          20,
          interceptors: {AddInterceptor, MultiplyInterceptor},
        );

        expect(ddi.isRegistered<int>(), true);
        expect(newDdi.isRegistered<int>(), true);

        // Should work independently
        final defaultValue = ddi.get<int>();
        final newValue = newDdi.get<int>();

        expect(defaultValue, 40); // (10 + 10) * 2
        expect(newValue, 60); // (20 + 10) * 2

        // Cleanup
        ddi.destroy<int>();
        ddi.destroy<AddInterceptor>();
        ddi.destroy<MultiplyInterceptor>();

        newDdi.destroy<int>();
        newDdi.destroy<AddInterceptor>();
        newDdi.destroy<MultiplyInterceptor>();

        expect(ddi.isRegistered<int>(), false);
        expect(newDdi.isRegistered<int>(), false);
        expect(
          () => ddi.get<int>(),
          throwsA(isA<BeanNotFoundException>()),
        );
        expect(
          () => newDdi.get<int>(),
          throwsA(isA<BeanNotFoundException>()),
        );
      });

      test('Should not use interceptors from different container', () async {
        final newDdi = DDI.newInstance();

        // Register interceptor only in default container
        ddi.singleton<AddInterceptor>(AddInterceptor.new);

        // Register int with interceptor in new container
        // But interceptor is not registered in new container
        await expectLater(
          () async => newDdi.object<int>(
            15,
            interceptors: {AddInterceptor},
          ),
          throwsA(isA<BeanNotFoundException>()),
        );

        // Bean is registered
        expect(newDdi.isRegistered<int>(), false);

        // When trying to get, it will fail because interceptor is not available
        // The interceptor lookup will fail during creation, causing BeanNotFoundException
        // Note: The bean is registered, but cannot be created because interceptor is missing
        expect(
          () => newDdi.get<int>(),
          throwsA(isA<BeanNotFoundException>()),
        );

        // Cleanup
        newDdi.destroy<int>();
        ddi.destroy<AddInterceptor>();

        expect(newDdi.isRegistered<int>(), false);
        expect(ddi.isRegistered<AddInterceptor>(), false);
      });

      test('Should use async interceptors from the correct container',
          () async {
        final newDdi = DDI.newInstance();

        // Register async interceptor in both containers
        ddi.singleton<AsyncAddInterceptor>(AsyncAddInterceptor.new);
        newDdi.singleton<AsyncAddInterceptor>(AsyncAddInterceptor.new);

        // Register int with async interceptor in both containers
        ddi.object<int>(
          10,
          interceptors: {AsyncAddInterceptor},
        );
        newDdi.object<int>(
          20,
          interceptors: {AsyncAddInterceptor},
        );

        expect(ddi.isRegistered<int>(), true);
        expect(newDdi.isRegistered<int>(), true);

        // Should work independently with async
        final defaultValue = await ddi.getAsync<int>();
        final newValue = await newDdi.getAsync<int>();

        expect(defaultValue, 30); // 10 + 20
        expect(newValue, 40); // 20 + 20

        // Cleanup
        ddi.destroy<int>();
        ddi.destroy<AsyncAddInterceptor>();

        newDdi.destroy<int>();
        newDdi.destroy<AsyncAddInterceptor>();

        expect(ddi.isRegistered<int>(), false);
        expect(newDdi.isRegistered<int>(), false);
      });
    });

    group('Modules with Isolated Container', () {
      test('Should register module children in default container by default',
          () async {
        final newDdi = DDI.newInstance();

        // Register module in default container
        await ddi.singleton<ModuleFactorySingleton>(
          ModuleFactorySingleton.new,
        );

        // Get module to trigger onPostConstruct
        ddi.get<ModuleFactorySingleton>();

        // Verify children are registered in default container
        expect(ddi.isRegistered<A>(), true);
        expect(ddi.isRegistered<B>(), true);
        expect(ddi.isRegistered<C>(), true);
        expect(ddi.isRegistered<MultiInject>(), true);

        String error = '';
        try {
          await newDdi.singleton<ModuleAsyncFactorySingleton>(
            ModuleAsyncFactorySingleton.new,
          );
          fail("Expected to have a error");
        } catch (f) {
          error = f.toString();
        }

        expect(error, 'Is already registered a instance with Type C');

        // Children are registered in default container (not newDdi)
        // because DDIModule.ddi defaults to DDI.instance
        expect(ddi.isRegistered<A>(), true);
        expect(ddi.isRegistered<B>(), true);
        expect(ddi.isRegistered<C>(), true);
        expect(ddi.isRegistered<MultiInject>(), true);

        // newDdi should not have the children (they are in default container)
        expect(newDdi.isRegistered<A>(), false);
        expect(newDdi.isRegistered<B>(), false);
        expect(newDdi.isRegistered<C>(), false);
        expect(newDdi.isRegistered<MultiInject>(), false);

        // Cleanup
        ddi.destroy<ModuleFactorySingleton>();
        ddi.destroy<MultiInject>();
        ddi.destroy<A>();
        ddi.destroy<B>();
        ddi.destroy<C>();

        newDdi.destroy<ModuleAsyncFactorySingleton>();

        expect(ddi.isRegistered<ModuleFactorySingleton>(), false);
        expect(newDdi.isRegistered<ModuleAsyncFactorySingleton>(), false);
        expect(
          () => ddi.get<A>(),
          throwsA(isA<BeanNotFoundException>()),
        );
        expect(
          () => newDdi.get<A>(),
          throwsA(isA<BeanNotFoundException>()),
        );
      });

      test(
          'Should register module children in the correct container when ddi is overridden',
          () {
        final newDdi = DDI.newInstance();

        // Register module in default container.
        ddi.singleton<ModuleFactoryApplicationIsolated>(
          () => ModuleFactoryApplicationIsolated(ddi),
        );

        // Get module to trigger onPostConstruct
        ddi.get<ModuleFactoryApplicationIsolated>();

        // Verify children are registered in default container
        expect(ddi.isRegistered<A>(), true);
        expect(ddi.isRegistered<B>(), true);
        expect(ddi.isRegistered<C>(), true);
        expect(ddi.isRegistered<MultiInject>(), true);

        // Register module in new container using isolated module class
        newDdi.singleton<ModuleFactoryApplicationIsolated>(
          () => ModuleFactoryApplicationIsolated(newDdi),
        );

        expect(newDdi.isRegistered<ModuleFactoryApplicationIsolated>(), true);

        // Get module to trigger onPostConstruct
        // Now DDIModule uses the overridden ddi getter, so children should be registered in newDdi
        newDdi.get<ModuleFactoryApplicationIsolated>();

        // Verify children are registered in new container
        expect(newDdi.isRegistered<A>(), true);
        expect(newDdi.isRegistered<B>(), true);
        expect(newDdi.isRegistered<C>(), true);
        expect(newDdi.isRegistered<MultiInject>(), true);

        // Verify instances are different between containers
        final defaultA = ddi.get<A>();
        final newA = newDdi.get<A>();

        expect(defaultA, isA<A>());
        expect(newA, isA<A>());
        expect(defaultA, isNot(same(newA)));

        // Cleanup
        ddi.destroy<ModuleFactoryApplicationIsolated>();
        ddi.destroy<MultiInject>();
        ddi.destroy<A>();
        ddi.destroy<B>();
        ddi.destroy<C>();

        newDdi.destroy<ModuleFactoryApplicationIsolated>();
        newDdi.destroy<MultiInject>();
        newDdi.destroy<A>();
        newDdi.destroy<B>();
        newDdi.destroy<C>();

        expect(ddi.isRegistered<ModuleFactoryApplicationIsolated>(), false);
        expect(newDdi.isRegistered<ModuleFactoryApplicationIsolated>(), false);
        expect(
          () => ddi.get<A>(),
          throwsA(isA<BeanNotFoundException>()),
        );
        expect(
          () => newDdi.get<A>(),
          throwsA(isA<BeanNotFoundException>()),
        );
      });

      test('Should dispose module children in default container', () async {
        final newDdi = DDI.newInstance();

        // Register module in default container
        ddi.singleton<ModuleFactoryApplication>(
          ModuleFactoryApplication.new,
        );

        // Get module to trigger onPostConstruct
        ddi.get<ModuleFactoryApplication>();

        expect(ddi.isRegistered<A>(), true);
        expect(ddi.isRegistered<B>(), true);
        expect(ddi.isRegistered<C>(), true);

        String error = '';
        try {
          await newDdi.singleton<ModuleAsyncFactorySingleton>(
            ModuleAsyncFactorySingleton.new,
          );
          fail("Expected to have a error");
        } catch (f) {
          error = f.toString();
        }

        expect(error, 'Is already registered a instance with Type C');

        // Children are in default container, not newDdi
        expect(ddi.isRegistered<A>(), true);
        expect(ddi.isRegistered<B>(), true);
        expect(ddi.isRegistered<C>(), true);

        // Dispose module in default container
        await ddi.dispose<ModuleFactoryApplication>();

        // Default container children should be disposed (not ready but may still be registered)
        expect(ddi.isReady<A>(), false);
        expect(ddi.isReady<B>(), false);
        expect(ddi.isReady<C>(), false);

        // Cleanup
        ddi.destroy<ModuleFactoryApplication>();
        ddi.destroy<MultiInject>();
        ddi.destroy<A>();
        ddi.destroy<B>();
        ddi.destroy<C>();

        newDdi.destroy<ModuleAsyncFactorySingleton>();

        expect(ddi.isRegistered<ModuleFactoryApplication>(), false);
        expect(newDdi.isRegistered<ModuleAsyncFactorySingleton>(), false);
        expect(
          () => ddi.get<A>(),
          throwsA(isA<BeanNotFoundException>()),
        );
        expect(
          () => newDdi.get<A>(),
          throwsA(isA<BeanNotFoundException>()),
        );
      });
    });

    group('Children with Isolated Container', () {
      test('Should manage children in the correct container', () async {
        final newDdi = DDI.newInstance();

        // Clean up any existing registrations first
        ddi.destroyByType<A>();
        ddi.destroyByType<B>();
        ddi.destroyByType<C>();

        // Register parent beans in both containers (order matters: C -> B -> A)
        await ddi.singleton<C>(C.new);
        await ddi.singleton<B>(() => B(ddi()));
        await ddi.singleton<A>(() => A(ddi()));

        await newDdi.singleton<C>(C.new);
        await newDdi.singleton<B>(() => B(newDdi()));
        await newDdi.singleton<A>(() => A(newDdi()));

        // Create instances to ensure they are ready
        ddi.get<A>();
        ddi.get<B>();
        ddi.get<C>();

        newDdi.get<A>();
        newDdi.get<B>();
        newDdi.get<C>();

        expect(ddi.isRegistered<A>(), true);
        expect(newDdi.isRegistered<A>(), true);

        // Add children to parent in default container
        ddi.addChildrenModules<A>(child: {B});
        ddi.addChildrenModules<B>(child: {C});

        // Add children to parent in new container
        newDdi.addChildrenModules<A>(child: {B});
        newDdi.addChildrenModules<B>(child: {C});

        // Get children from correct containers
        final defaultChildren = ddi.getChildren<A>();
        final newChildren = newDdi.getChildren<A>();

        expect(defaultChildren, {B});
        expect(newChildren, {B});

        final defaultBChildren = ddi.getChildren<B>();
        final newBChildren = newDdi.getChildren<B>();

        expect(defaultBChildren, {C});
        expect(newBChildren, {C});

        // Cleanup
        ddi.destroy<A>();
        ddi.destroy<B>();
        ddi.destroy<C>();

        newDdi.destroy<A>();
        newDdi.destroy<B>();
        newDdi.destroy<C>();

        expect(ddi.isRegistered<A>(), false);
        expect(newDdi.isRegistered<A>(), false);
        expect(
          () => ddi.get<A>(),
          throwsA(isA<BeanNotFoundException>()),
        );
        expect(
          () => newDdi.get<A>(),
          throwsA(isA<BeanNotFoundException>()),
        );
      });

      test('Should destroy children in the correct container', () async {
        final newDdi = DDI.newInstance();

        // Clean up any existing registrations first
        ddi.destroyByType<A>();
        ddi.destroyByType<B>();
        ddi.destroyByType<C>();

        // Register parent beans in both containers (order matters: C -> B -> A)
        await ddi.singleton<C>(C.new);
        await ddi.singleton<B>(() => B(ddi()));
        await ddi.singleton<A>(() => A(ddi()));

        await newDdi.singleton<C>(C.new);
        await newDdi.singleton<B>(() => B(newDdi()));
        await newDdi.singleton<A>(() => A(newDdi()));

        // Add children
        ddi.addChildrenModules<A>(child: {B});
        ddi.addChildrenModules<B>(child: {C});

        newDdi.addChildrenModules<A>(child: {B});
        newDdi.addChildrenModules<B>(child: {C});

        // Create instances to ensure they are ready
        ddi.get<A>();
        ddi.get<B>();
        ddi.get<C>();

        newDdi.get<A>();
        newDdi.get<B>();
        newDdi.get<C>();

        expect(ddi.isRegistered<A>(), true);
        expect(newDdi.isRegistered<A>(), true);

        // Destroy parent in default container
        await ddi.destroy<A>();

        // Default container children should be destroyed
        expect(ddi.isRegistered<A>(), false);
        expect(
          () => ddi.get<A>(),
          throwsA(isA<BeanNotFoundException>()),
        );
        expect(ddi.isRegistered<B>(), false);
        expect(ddi.isRegistered<C>(), false);

        // New container children should still be registered
        expect(newDdi.isRegistered<A>(), true);
        expect(newDdi.isRegistered<B>(), true);
        expect(newDdi.isRegistered<C>(), true);

        // Cleanup
        newDdi.destroy<A>();
        newDdi.destroy<B>();
        newDdi.destroy<C>();

        expect(newDdi.isRegistered<A>(), false);
        expect(
          () => newDdi.get<A>(),
          throwsA(isA<BeanNotFoundException>()),
        );
      });

      test('Should dispose children in the correct container', () async {
        final newDdi = DDI.newInstance();

        // Clean up any existing registrations first
        ddi.destroyByType<A>();
        ddi.destroyByType<B>();
        ddi.destroyByType<C>();

        // Register parent and children in both containers
        ddi.application(() => A(ddi()));
        ddi.application(() => B(ddi()));
        ddi.application(C.new);

        newDdi.application(() => A(newDdi()));
        newDdi.application(() => B(newDdi()));
        newDdi.application(C.new);

        // Add children
        ddi.addChildrenModules<A>(child: {B});
        ddi.addChildrenModules<B>(child: {C});

        newDdi.addChildrenModules<A>(child: {B});
        newDdi.addChildrenModules<B>(child: {C});

        // Create instances to ensure they are ready
        ddi.get<A>();
        ddi.get<B>();
        ddi.get<C>();

        newDdi.get<A>();
        newDdi.get<B>();
        newDdi.get<C>();

        expect(ddi.isRegistered<A>(), true);
        expect(newDdi.isRegistered<A>(), true);

        // Dispose parent in default container
        await ddi.dispose<A>();

        // Default container children should be disposed (not ready but may still be registered)
        expect(ddi.isReady<A>(), false);
        expect(ddi.isReady<B>(), false);
        expect(ddi.isReady<C>(), false);

        // New container children should still be ready
        expect(newDdi.isReady<A>(), true);
        expect(newDdi.isReady<B>(), true);
        expect(newDdi.isReady<C>(), true);

        // Cleanup
        newDdi.dispose<A>();
        newDdi.destroy<A>();
        newDdi.destroy<B>();
        newDdi.destroy<C>();

        expect(newDdi.isRegistered<A>(), false);
        expect(
          () => newDdi.get<A>(),
          throwsA(isA<BeanNotFoundException>()),
        );
      });
    });

    group('Complex Scenario with Isolated Container', () {
      test('Should handle modules with overridden ddi getter', () {
        final newDdi = DDI.newInstance();

        // Clean up any existing registrations first
        ddi.destroyByType<ModuleFactoryApplicationIsolated>();
        ddi.destroyByType<A>();
        ddi.destroyByType<B>();
        ddi.destroyByType<C>();
        ddi.destroyByType<MultiInject>();

        // Register module in default container using isolated module class
        ddi.singleton<ModuleFactoryApplicationIsolated>(
          () => ModuleFactoryApplicationIsolated(ddi),
        );

        // Get module to trigger onPostConstruct
        ddi.get<ModuleFactoryApplicationIsolated>();

        // Verify children are registered in default container
        expect(ddi.isRegistered<A>(), true);
        expect(ddi.isRegistered<B>(), true);
        expect(ddi.isRegistered<C>(), true);
        expect(ddi.isRegistered<MultiInject>(), true);

        // Register module in new container using isolated module class
        newDdi.singleton<ModuleFactoryApplicationIsolated>(
          () => ModuleFactoryApplicationIsolated(newDdi),
        );

        // Get module to trigger onPostConstruct
        newDdi.get<ModuleFactoryApplicationIsolated>();

        // Children are in their respective containers
        expect(ddi.isRegistered<A>(), true);
        expect(ddi.isRegistered<B>(), true);
        expect(ddi.isRegistered<C>(), true);
        expect(ddi.isRegistered<MultiInject>(), true);

        expect(newDdi.isRegistered<A>(), true);
        expect(newDdi.isRegistered<B>(), true);
        expect(newDdi.isRegistered<C>(), true);
        expect(newDdi.isRegistered<MultiInject>(), true);

        // Add children to A in both containers
        ddi.addChildrenModules<A>(child: {B});
        newDdi.addChildrenModules<A>(child: {B});

        // Verify children
        final defaultChildren = ddi.getChildren<A>();
        final newChildren = newDdi.getChildren<A>();

        expect(defaultChildren, {B});
        expect(newChildren, {B});

        // Verify instances are different
        final defaultA = ddi.get<A>();
        final newA = newDdi.get<A>();

        expect(defaultA, isA<A>());
        expect(newA, isA<A>());
        expect(defaultA, isNot(same(newA)));

        // Cleanup
        ddi.destroy<ModuleFactoryApplicationIsolated>();
        ddi.destroy<MultiInject>();
        ddi.destroy<A>();
        ddi.destroy<B>();
        ddi.destroy<C>();

        newDdi.destroy<ModuleFactoryApplicationIsolated>();
        newDdi.destroy<MultiInject>();
        newDdi.destroy<A>();
        newDdi.destroy<B>();
        newDdi.destroy<C>();

        expect(ddi.isRegistered<A>(), false);
        expect(newDdi.isRegistered<A>(), false);
        expect(
          () => ddi.get<A>(),
          throwsA(isA<BeanNotFoundException>()),
        );
        expect(
          () => newDdi.get<A>(),
          throwsA(isA<BeanNotFoundException>()),
        );
      });

      test('Should handle modules with default container behavior', () async {
        final newDdi = DDI.newInstance();

        // Register module in default container
        ddi.singleton<ModuleFactoryApplication>(
          ModuleFactoryApplication.new,
        );

        // Get module to trigger onPostConstruct
        ddi.get<ModuleFactoryApplication>();

        // Verify children are registered in default container
        expect(ddi.isRegistered<A>(), true);
        expect(ddi.isRegistered<B>(), true);
        expect(ddi.isRegistered<C>(), true);
        expect(ddi.isRegistered<MultiInject>(), true);

        String error = '';
        try {
          await newDdi.singleton<ModuleAsyncFactorySingleton>(
            ModuleAsyncFactorySingleton.new,
          );
          fail("Expected to have a error");
        } catch (f) {
          error = f.toString();
        }

        expect(error, 'Is already registered a instance with Type C');

        // Children are in default container (not newDdi)
        expect(ddi.isRegistered<A>(), true);
        expect(ddi.isRegistered<B>(), true);
        expect(ddi.isRegistered<C>(), true);
        expect(ddi.isRegistered<MultiInject>(), true);

        expect(newDdi.isRegistered<A>(), false);
        expect(newDdi.isRegistered<B>(), false);
        expect(newDdi.isRegistered<C>(), false);
        expect(newDdi.isRegistered<MultiInject>(), false);

        // Add children to A in default container
        ddi.addChildrenModules<A>(child: {B});

        // Verify children
        final defaultChildren = ddi.getChildren<A>();
        expect(defaultChildren, {B});

        // Cleanup
        ddi.destroy<ModuleFactoryApplication>();
        ddi.destroy<MultiInject>();
        ddi.destroy<A>();
        ddi.destroy<B>();
        ddi.destroy<C>();

        newDdi.destroy<ModuleAsyncFactorySingleton>();

        expect(ddi.isRegistered<A>(), false);
        expect(newDdi.isRegistered<A>(), false);
        expect(
          () => ddi.get<A>(),
          throwsA(isA<BeanNotFoundException>()),
        );
        expect(
          () => newDdi.get<A>(),
          throwsA(isA<BeanNotFoundException>()),
        );
      });
    });
  });
}
