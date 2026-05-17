import 'package:dart_ddi/dart_ddi.dart';
import 'package:test/test.dart';

import '../clazz_samples/public_api_symmetry_samples.dart';

void main() {
  group('Public API symmetry', () {
    group('CustomBuilder helpers', () {
      test(
        'asApplication should forward context priority and weak reference option',
        () async {
          final ddi = DDI.newInstance();
          final rootContext = ddi.currentContext;

          ddi.createContext('builder-child');

          await (() => const PublicApiBuilderSurfaceValue('application-low'))
              .builder
              .asApplication(
                ddiInstance: ddi,
                qualifier: 'application-low',
                context: rootContext,
                priority: 10,
              );
          await (() => const PublicApiBuilderSurfaceValue('application-high'))
              .builder
              .asApplication(
                ddiInstance: ddi,
                qualifier: 'application-high',
                context: rootContext,
                priority: 1,
                useWeakReference: true,
              );

          expect(
            ddi.isRegistered<PublicApiBuilderSurfaceValue>(
              qualifier: 'application-high',
              context: rootContext,
            ),
            isTrue,
          );
          expect(
            ddi.isRegistered<PublicApiBuilderSurfaceValue>(
              qualifier: 'application-high',
              context: 'builder-child',
            ),
            isFalse,
          );
          expect(
            ddi
                .getWith<PublicApiBuilderSurfaceValue, Object>(
                  context: rootContext,
                )
                .value,
            'application-high',
          );

          await ddi.destroy<PublicApiBuilderSurfaceValue>(
            qualifier: 'application-low',
            context: rootContext,
          );
          await ddi.destroy<PublicApiBuilderSurfaceValue>(
            qualifier: 'application-high',
            context: rootContext,
          );
        },
      );

      test(
        'asSingleton should forward context and priority',
        () async {
          final ddi = DDI.newInstance();
          final rootContext = ddi.currentContext;

          ddi.createContext('builder-child');

          await (() => const PublicApiBuilderSurfaceValue('singleton-low'))
              .builder
              .asSingleton(
                ddiInstance: ddi,
                qualifier: 'singleton-low',
                context: rootContext,
                priority: 10,
              );
          await (() => const PublicApiBuilderSurfaceValue('singleton-high'))
              .builder
              .asSingleton(
                ddiInstance: ddi,
                qualifier: 'singleton-high',
                context: rootContext,
                priority: 1,
              );

          expect(
            ddi.isRegistered<PublicApiBuilderSurfaceValue>(
              qualifier: 'singleton-high',
              context: rootContext,
            ),
            isTrue,
          );
          expect(
            ddi
                .getWith<PublicApiBuilderSurfaceValue, Object>(
                  context: rootContext,
                )
                .value,
            'singleton-high',
          );

          await ddi.destroy<PublicApiBuilderSurfaceValue>(
            qualifier: 'singleton-low',
            context: rootContext,
          );
          await ddi.destroy<PublicApiBuilderSurfaceValue>(
            qualifier: 'singleton-high',
            context: rootContext,
          );
        },
      );

      test(
        'asDependent should forward context and priority',
        () async {
          final ddi = DDI.newInstance();
          final rootContext = ddi.currentContext;

          ddi.createContext('builder-child');

          await (() => const PublicApiBuilderSurfaceValue('dependent-low'))
              .builder
              .asDependent(
                ddiInstance: ddi,
                qualifier: 'dependent-low',
                context: rootContext,
                priority: 10,
              );
          await (() => const PublicApiBuilderSurfaceValue('dependent-high'))
              .builder
              .asDependent(
                ddiInstance: ddi,
                qualifier: 'dependent-high',
                context: rootContext,
                priority: 1,
              );

          expect(
            ddi.isRegistered<PublicApiBuilderSurfaceValue>(
              qualifier: 'dependent-high',
              context: rootContext,
            ),
            isTrue,
          );
          expect(
            ddi
                .getWith<PublicApiBuilderSurfaceValue, Object>(
                  context: rootContext,
                )
                .value,
            'dependent-high',
          );

          await ddi.destroy<PublicApiBuilderSurfaceValue>(
            qualifier: 'dependent-low',
            context: rootContext,
          );
          await ddi.destroy<PublicApiBuilderSurfaceValue>(
            qualifier: 'dependent-high',
            context: rootContext,
          );
        },
      );
    });

    group('DDIModule helpers', () {
      test(
          'should expose requires on all helpers and weak reference on application',
          () async {
        final ddi = DDI.newInstance();
        final module = PublicApiManualSurfaceModule(ddi);

        await ddi.object<PublicApiManualSurfaceModule>(module);

        await module.application<PublicApiModuleApplicationChild>(
          PublicApiModuleApplicationChild.new,
          requires: {PublicApiMissingModuleDependency},
          useWeakReference: true,
        );
        await module.dependent<PublicApiModuleDependentChild>(
          PublicApiModuleDependentChild.new,
          requires: {PublicApiMissingModuleDependency},
        );

        expect(
          () => ddi.get<PublicApiModuleApplicationChild>(),
          throwsA(isA<MissingDependenciesException>()),
        );
        expect(
          () => ddi.get<PublicApiModuleDependentChild>(),
          throwsA(isA<MissingDependenciesException>()),
        );
        await expectLater(
          module.singleton<PublicApiModuleSingletonChild>(
            PublicApiModuleSingletonChild.new,
            requires: {PublicApiMissingModuleDependency},
          ),
          throwsA(isA<MissingDependenciesException>()),
        );
        await expectLater(
          module.object<PublicApiModuleObjectChild>(
            PublicApiModuleObjectChild(),
            requires: {PublicApiMissingModuleDependency},
          ),
          throwsA(isA<MissingDependenciesException>()),
        );

        await ddi.destroy<PublicApiManualSurfaceModule>();
      });
    });

    group('optional getters', () {
      test('sync optionals should accept context and selector', () async {
        final ddi = DDI.newInstance();
        ddi.createContext('optional-sync');
        ddi.createContext('other');

        await ddi.application<PublicApiOptionalSurfaceValue>(
          () => const PublicApiOptionalSurfaceValue('sync-a'),
          qualifier: 'sync-a',
          context: 'optional-sync',
          selector: (value) => value == 'a',
        );
        await ddi.application<PublicApiOptionalSurfaceValue>(
          () => const PublicApiOptionalSurfaceValue('sync-b'),
          qualifier: 'sync-b',
          context: 'optional-sync',
          selector: (value) => value == 'b',
        );
        await ((String value) =>
                PublicApiOptionalParameterizedValue('sync-$value'))
            .builder
            .asDependent(
              ddiInstance: ddi,
              qualifier: 'sync-parameterized',
              context: 'optional-sync',
              selector: (value) => value == 'parameterized',
            );

        expect(
          ddi
              .getOptional<PublicApiOptionalSurfaceValue>(
                context: 'optional-sync',
                select: 'b',
              )
              ?.value,
          'sync-b',
        );
        expect(
          ddi
              .getOptionalWith<PublicApiOptionalParameterizedValue, String>(
                context: 'optional-sync',
                select: 'parameterized',
                parameter: 'value',
              )
              ?.value,
          'sync-value',
        );

        await ddi.destroyByType<PublicApiOptionalSurfaceValue>(
          context: 'optional-sync',
        );
        await ddi.destroy<PublicApiOptionalParameterizedValue>(
          qualifier: 'sync-parameterized',
          context: 'optional-sync',
        );
      });

      test('async optionals should accept context and selector', () async {
        final ddi = DDI.newInstance();
        ddi.createContext('optional-async');
        ddi.createContext('other');

        await ddi.application<PublicApiOptionalSurfaceValue>(
          () async => const PublicApiOptionalSurfaceValue('async-a'),
          qualifier: 'async-a',
          context: 'optional-async',
          selector: (value) => value == 'a',
        );
        await ddi.application<PublicApiOptionalSurfaceValue>(
          () async => const PublicApiOptionalSurfaceValue('async-b'),
          qualifier: 'async-b',
          context: 'optional-async',
          selector: (value) => value == 'b',
        );
        await ((String value) async =>
                PublicApiOptionalParameterizedValue('async-$value'))
            .builder
            .asDependent(
              ddiInstance: ddi,
              qualifier: 'async-parameterized',
              context: 'optional-async',
              selector: (value) => value == 'parameterized',
            );

        expect(
          (await ddi.getOptionalAsync<PublicApiOptionalSurfaceValue>(
            context: 'optional-async',
            select: 'b',
          ))
              ?.value,
          'async-b',
        );
        expect(
          (await ddi.getOptionalAsyncWith<PublicApiOptionalParameterizedValue,
                  String>(
            context: 'optional-async',
            select: 'parameterized',
            parameter: 'value',
          ))
              ?.value,
          'async-value',
        );

        await ddi.destroyByType<PublicApiOptionalSurfaceValue>(
          context: 'optional-async',
        );
        await ddi.destroy<PublicApiOptionalParameterizedValue>(
          qualifier: 'async-parameterized',
          context: 'optional-async',
        );
      });

      test(
        'async optionals should return null when no selector matches',
        () async {
          final ddi = DDI.newInstance();
          ddi.createContext('optional-async-missing');

          await ddi.application<PublicApiOptionalSurfaceValue>(
            () async => const PublicApiOptionalSurfaceValue('async-a'),
            qualifier: 'async-a',
            context: 'optional-async-missing',
            selector: (value) => value == 'a',
          );
          await ddi.application<PublicApiOptionalSurfaceValue>(
            () async => const PublicApiOptionalSurfaceValue('async-b'),
            qualifier: 'async-b',
            context: 'optional-async-missing',
            selector: (value) => value == 'b',
          );
          await ((String value) async =>
                  PublicApiOptionalParameterizedValue('async-$value'))
              .builder
              .asDependent(
                ddiInstance: ddi,
                qualifier: 'async-parameterized-a',
                context: 'optional-async-missing',
                selector: (value) => value == 'a',
              );
          await ((String value) async =>
                  PublicApiOptionalParameterizedValue('async-$value'))
              .builder
              .asDependent(
                ddiInstance: ddi,
                qualifier: 'async-parameterized-b',
                context: 'optional-async-missing',
                selector: (value) => value == 'b',
              );

          expect(
            await ddi.getOptionalAsync<PublicApiOptionalSurfaceValue>(
              context: 'optional-async-missing',
              select: 'missing',
            ),
            isNull,
          );
          expect(
            await ddi.getOptionalAsyncWith<PublicApiOptionalParameterizedValue,
                String>(
              context: 'optional-async-missing',
              select: 'missing',
              parameter: 'value',
            ),
            isNull,
          );

          await ddi.destroyByType<PublicApiOptionalSurfaceValue>(
            context: 'optional-async-missing',
          );
          await ddi.destroyByType<PublicApiOptionalParameterizedValue>(
            context: 'optional-async-missing',
          );
        },
      );

      test(
        'async optionals should propagate errors other than BeanNotFoundException',
        () async {
          final ddi = DDI.newInstance();
          Future<PublicApiOptionalParameterizedValue> failingParameterized(
            String _,
          ) async {
            throw StateError('parameterized failure');
          }

          await ddi.application<PublicApiOptionalSurfaceValue>(
            () async => throw StateError('surface failure'),
            qualifier: 'async-failing-surface',
          );
          await failingParameterized.builder.asDependent(
            ddiInstance: ddi,
            qualifier: 'async-failing-parameterized',
          );

          await expectLater(
            ddi.getOptionalAsync<PublicApiOptionalSurfaceValue>(
              qualifier: 'async-failing-surface',
            ),
            throwsA(
              isA<StateError>().having(
                (error) => error.message,
                'message',
                'surface failure',
              ),
            ),
          );
          await expectLater(
            ddi.getOptionalAsyncWith<PublicApiOptionalParameterizedValue,
                String>(
              qualifier: 'async-failing-parameterized',
              parameter: 'value',
            ),
            throwsA(
              isA<StateError>().having(
                (error) => error.message,
                'message',
                'parameterized failure',
              ),
            ),
          );

          await ddi.destroy<PublicApiOptionalSurfaceValue>(
            qualifier: 'async-failing-surface',
          );
          await ddi.destroy<PublicApiOptionalParameterizedValue>(
            qualifier: 'async-failing-parameterized',
          );
        },
      );
    });
  });
}
