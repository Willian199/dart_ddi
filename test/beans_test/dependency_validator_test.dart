import 'package:dart_ddi/dart_ddi.dart';
import 'package:dart_ddi/src/utils/dependency_validator.dart';
import 'package:test/test.dart';

import '../clazz_samples/test_service.dart';

void main() {
  group('DependencyValidator Tests', () {
    tearDown(() {
      ddi.destroyByType<TestService>();
    });

    tearDownAll(() {
      expect(ddi.isEmpty, true);
    });

    group('validateDependencies - sync', () {
      test('should throw when dependency is not registered', () {
        expect(
          () => DependencyValidator.validateDependencies(
            required: {TestService},
            ddiInstance: ddi,
          ),
          throwsA(isA<MissingDependenciesException>()),
        );
      });

      test('should throw when async dependency is not ready', () {
        Future<TestService> func() async {
          await Future.delayed(const Duration(milliseconds: 10));
          return TestService();
        }

        func.builder.asApplication();

        expect(
          () => DependencyValidator.validateDependencies(
            required: {TestService},
            ddiInstance: ddi,
          ),
          throwsA(isA<MissingDependenciesException>()),
        );
      });

      test('should not throw when all dependencies are ready', () {
        TestService.new.builder.asApplication();
        ddi.get<TestService>(); // Make it ready

        expect(
          () => DependencyValidator.validateDependencies(
            required: {TestService},
            ddiInstance: ddi,
          ),
          returnsNormally,
        );
      });

      test('should trigger getWith when dependency is registered but not ready',
          () {
        TestService.new.builder.asApplication();
        // Don't call get() so it's registered but not ready

        DependencyValidator.validateDependencies(
          required: {TestService},
          ddiInstance: ddi,
        );

        // After validation, the dependency should be ready
        expect(ddi.isReady<TestService>(), true);
      });
    });

    group('validateDependenciesAsync', () {
      test('should throw when dependency is not registered', () async {
        await expectLater(
          DependencyValidator.validateDependenciesAsync(
            required: {TestService},
            ddiInstance: ddi,
          ),
          throwsA(isA<MissingDependenciesException>()),
        );
      });

      test('should await async dependency when not ready', () async {
        Future<TestService> func() async {
          await Future.delayed(const Duration(milliseconds: 10));
          return TestService();
        }

        func.builder.asApplication();

        await DependencyValidator.validateDependenciesAsync(
          required: {TestService},
          ddiInstance: ddi,
        );

        // After validation, the dependency should be ready
        expect(ddi.isReady<TestService>(), true);
      });

      test('should call getWith for sync dependency when not ready', () async {
        TestService.new.builder.asApplication();
        // Don't call get() so it's registered but not ready

        await DependencyValidator.validateDependenciesAsync(
          required: {TestService},
          ddiInstance: ddi,
        );

        // After validation, the dependency should be ready
        expect(ddi.isReady<TestService>(), true);
      });

      test('should not throw when all dependencies are ready', () async {
        TestService.new.builder.asApplication();
        await ddi.getAsync<TestService>(); // Make it ready

        await expectLater(
          DependencyValidator.validateDependenciesAsync(
            required: {TestService},
            ddiInstance: ddi,
          ),
          completes,
        );
      });

      test('should handle multiple dependencies', () async {
        TestService.new.builder.asApplication();
        const qualifier2 = #testService2;
        TestService.new.builder.asApplication(qualifier: qualifier2);

        await ddi.getAsync<TestService>();
        await ddi.getAsync<TestService>(qualifier: qualifier2);

        await expectLater(
          DependencyValidator.validateDependenciesAsync(
            required: {TestService, qualifier2},
            ddiInstance: ddi,
          ),
          completes,
        );

        ddi.destroy(qualifier: qualifier2);
      });
    });
  });
}
