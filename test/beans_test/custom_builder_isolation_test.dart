import 'package:dart_ddi/dart_ddi.dart';
import 'package:test/test.dart';

import '../clazz_samples/custom_builder_isolation_samples.dart';

void main() {
  group('CustomBuilder isolated registration', () {
    test('asApplication should register in the provided DDI instance',
        () async {
      final isolatedDdi = DDI.newInstance();

      await CustomBuilderApplicationValue.new.builder.asApplication(
        ddiInstance: isolatedDdi,
      );

      expect(
        isolatedDdi.get<CustomBuilderApplicationValue>(),
        isA<CustomBuilderApplicationValue>(),
      );
      expect(
        DDI.instance.isRegistered<CustomBuilderApplicationValue>(),
        isFalse,
      );

      await isolatedDdi.destroy<CustomBuilderApplicationValue>();
    });

    test('asSingleton should register in the provided DDI instance', () async {
      final isolatedDdi = DDI.newInstance();

      await CustomBuilderSingletonValue.new.builder.asSingleton(
        ddiInstance: isolatedDdi,
      );

      expect(
        isolatedDdi.get<CustomBuilderSingletonValue>(),
        isA<CustomBuilderSingletonValue>(),
      );
      expect(
        DDI.instance.isRegistered<CustomBuilderSingletonValue>(),
        isFalse,
      );

      await isolatedDdi.destroy<CustomBuilderSingletonValue>();
    });

    test('asDependent should register in the provided DDI instance', () async {
      final isolatedDdi = DDI.newInstance();

      await CustomBuilderDependentValue.new.builder.asDependent(
        ddiInstance: isolatedDdi,
      );

      expect(
        isolatedDdi.get<CustomBuilderDependentValue>(),
        isA<CustomBuilderDependentValue>(),
      );
      expect(
        DDI.instance.isRegistered<CustomBuilderDependentValue>(),
        isFalse,
      );

      await isolatedDdi.destroy<CustomBuilderDependentValue>();
    });

    test(
      'inject plus asApplication should stay inside the provided DDI instance',
      () async {
        final isolatedDdi = DDI.newInstance();
        final dependency = CustomBuilderIsolatedDependency();

        await isolatedDdi.object<CustomBuilderIsolatedDependency>(dependency);
        await CustomBuilderNeedsIsolatedDependency.new
            .inject(isolatedDdi)
            .asApplication(
              ddiInstance: isolatedDdi,
            );

        final bean = isolatedDdi.get<CustomBuilderNeedsIsolatedDependency>();
        expect(bean.dependency, same(dependency));
        expect(
          DDI.instance.isRegistered<CustomBuilderNeedsIsolatedDependency>(),
          isFalse,
        );

        await isolatedDdi.destroy<CustomBuilderNeedsIsolatedDependency>();
        await isolatedDdi.destroy<CustomBuilderIsolatedDependency>();
      },
    );
  });
}
