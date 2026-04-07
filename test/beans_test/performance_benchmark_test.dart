import 'dart:async';

import 'package:dart_ddi/dart_ddi.dart';
import 'package:test/test.dart';

import '../clazz_samples/performance_benchmark_samples.dart';

enum _ScopeKind {
  application('Application', 2000000, 0.2, 1),
  singleton('Singleton', 2000000, 0.2, 1),
  object('Object', 2000000, 0.2, 1),
  dependent('Dependent', 250000, 0.4, 1);

  const _ScopeKind(
    this.label,
    this.interaction,
    this.maxRelativeDelta,
    this.expectedCachedOnGet,
  );

  final String label;
  final int interaction;
  final double maxRelativeDelta;
  final int expectedCachedOnGet;
}

enum _InstanceVariation {
  cache('with cache'),
  weak('with useWeakReference');

  const _InstanceVariation(this.label);

  final String label;
}

final class _BenchmarkResult {
  const _BenchmarkResult({
    required this.elapsedMilliseconds,
    required this.onCreateCalled,
    required this.onGetCalled,
  });

  final int elapsedMilliseconds;
  final int onCreateCalled;
  final int onGetCalled;
}

typedef _BenchmarkExercise = void Function(DDI ddi);
typedef _AsyncBenchmarkExercise = FutureOr<void> Function(DDI ddi);

Future<void> _setupScope(DDI ddi, _ScopeKind scope) async {
  switch (scope) {
    case _ScopeKind.application:
      await ddi.application(BenchmarkInterceptor.new);
      await ddi.application(
        BenchmarkService.new,
        interceptors: {BenchmarkInterceptor},
      );
    case _ScopeKind.singleton:
      await ddi.singleton(BenchmarkInterceptor.new);
      await ddi.singleton(
        BenchmarkService.new,
        interceptors: {BenchmarkInterceptor},
      );
    case _ScopeKind.object:
      await ddi.object(BenchmarkInterceptor());
      await ddi.object(
        BenchmarkService(),
        interceptors: {BenchmarkInterceptor},
      );
    case _ScopeKind.dependent:
      await ddi.dependent(BenchmarkInterceptor.new);
      await ddi.dependent(
        BenchmarkService.new,
        interceptors: {BenchmarkInterceptor},
      );
  }
}

Future<_BenchmarkResult> _runBenchmark({
  required _ScopeKind scope,
  required _BenchmarkExercise exercise,
}) async {
  final ddi = DDI.newInstance();
  await _setupScope(ddi, scope);

  final sw = Stopwatch()..start();
  exercise(ddi);
  sw.stop();

  final interceptor = ddi.get<BenchmarkInterceptor>();

  await ddi.destroy<BenchmarkService>();
  await ddi.destroy<BenchmarkInterceptor>();

  return _BenchmarkResult(
    elapsedMilliseconds: sw.elapsedMilliseconds,
    onCreateCalled: interceptor.onCreateCalled,
    onGetCalled: interceptor.onGetCalled,
  );
}

Future<List<_BenchmarkResult>> _measureMany({
  required _ScopeKind scope,
  required int warmups,
  required int runs,
  required _BenchmarkExercise exercise,
}) async {
  for (var i = 0; i < warmups; i++) {
    await _runBenchmark(
      scope: scope,
      exercise: exercise,
    );
  }

  final results = <_BenchmarkResult>[];
  for (var i = 0; i < runs; i++) {
    results.add(await _runBenchmark(
      scope: scope,
      exercise: exercise,
    ));
  }

  return results;
}

Future<_BenchmarkResult> _runContextModuleBenchmark({
  required _AsyncBenchmarkExercise exercise,
}) async {
  final ddi = DDI.newInstance();
  await ddi.singleton(() => ContextualBenchmarkModule(ddi));

  final module = ddi.get<ContextualBenchmarkModule>();

  final sw = Stopwatch()..start();
  await exercise(ddi);
  sw.stop();

  final interceptor = ddi.getWith<BenchmarkInterceptor, Object>(
    context: module.contextQualifier,
  );

  await ddi.destroy<ContextualBenchmarkService>(
      context: module.contextQualifier);
  await ddi.destroy<BenchmarkInterceptor>(context: module.contextQualifier);
  await ddi.destroy<ContextualBenchmarkModule>();

  return _BenchmarkResult(
    elapsedMilliseconds: sw.elapsedMilliseconds,
    onCreateCalled: interceptor.onCreateCalled,
    onGetCalled: interceptor.onGetCalled,
  );
}

Future<List<_BenchmarkResult>> _measureContextModuleMany({
  required int warmups,
  required int runs,
  required _AsyncBenchmarkExercise exercise,
}) async {
  for (var i = 0; i < warmups; i++) {
    await _runContextModuleBenchmark(
      exercise: exercise,
    );
  }

  final results = <_BenchmarkResult>[];
  for (var i = 0; i < runs; i++) {
    results.add(await _runContextModuleBenchmark(
      exercise: exercise,
    ));
  }

  return results;
}

int _medianMillis(List<_BenchmarkResult> results) {
  final values = results.map((e) => e.elapsedMilliseconds).toList()..sort();
  return values[values.length ~/ 2];
}

int _totalMillis(List<_BenchmarkResult> results) {
  return results.fold(0, (total, result) => total + result.elapsedMilliseconds);
}

double _averageMillis(List<_BenchmarkResult> results) {
  return _totalMillis(results) / results.length;
}

void _printBenchmarkSummary(
  String label,
  List<_BenchmarkResult> results,
  int interaction,
) {
  final totalMillis = _totalMillis(results);
  final averageMillis = _averageMillis(results);
  final medianMillis = _medianMillis(results);
  final averageMicrosPerExecution = (averageMillis * 1000) / interaction;

  // ignore: avoid_print
  print(
    '$label: total=${totalMillis}ms, runs=${results.length}, avg=${averageMillis.toStringAsFixed(2)}ms, median=${medianMillis}ms, iterations=$interaction, avg_per_execution=${averageMicrosPerExecution.toStringAsFixed(6)}us',
  );
}

void main() {
  const warmups = 2;
  const runs = 5;

  group('Beans Performance Benchmark Test', () {
    for (final scope in _ScopeKind.values) {
      test(
        '${scope.label} Scope direct get vs Instance without cache should stay close',
        () async {
          final directResults = await _measureMany(
            scope: scope,
            warmups: warmups,
            runs: runs,
            exercise: (ddi) {
              for (var i = 0; i < scope.interaction; i++) {
                ddi.get<BenchmarkService>();
              }
            },
          );

          final instanceResults = await _measureMany(
            scope: scope,
            warmups: warmups,
            runs: runs,
            exercise: (ddi) {
              final instance = ddi.getInstance<BenchmarkService>();
              for (var i = 0; i < scope.interaction; i++) {
                instance.get();
              }
            },
          );

          final directMedian = _medianMillis(directResults);
          final instanceMedian = _medianMillis(instanceResults);
          final relativeDelta =
              (instanceMedian - directMedian).abs() / directMedian;

          _printBenchmarkSummary(
            '${scope.label} direct get',
            directResults,
            scope.interaction,
          );
          _printBenchmarkSummary(
            '${scope.label} instance without cache',
            instanceResults,
            scope.interaction,
          );

          if (scope != _ScopeKind.dependent) {
            expect(
              directResults.every((result) => result.onCreateCalled == 1),
              isTrue,
            );
            expect(
              directResults
                  .every((result) => result.onGetCalled == scope.interaction),
              isTrue,
            );
            expect(
              instanceResults.every((result) => result.onCreateCalled == 1),
              isTrue,
            );
            expect(
              instanceResults
                  .every((result) => result.onGetCalled == scope.interaction),
              isTrue,
            );
          }
          expect(
            relativeDelta,
            lessThan(scope.maxRelativeDelta),
            reason:
                '${scope.label} Scope direct get and Instance without cache should stay close.',
          );
        },
      );

      for (final variation in <_InstanceVariation>[
        _InstanceVariation.cache,
        _InstanceVariation.weak,
      ]) {
        test(
          '${scope.label} Scope Instance ${variation.label} should minimize onGet',
          () async {
            final results = await _measureMany(
              scope: scope,
              warmups: warmups,
              runs: runs,
              exercise: (ddi) {
                final instance = ddi.getInstance<BenchmarkService>(
                  cache: variation == _InstanceVariation.cache,
                  useWeakReference: variation == _InstanceVariation.weak,
                );

                for (var i = 0; i < scope.interaction; i++) {
                  instance.get();
                }
              },
            );

            _printBenchmarkSummary(
              '${scope.label} instance ${variation.label}',
              results,
              scope.interaction,
            );

            if (scope != _ScopeKind.dependent) {
              expect(
                results.every((result) => result.onCreateCalled == 1),
                isTrue,
              );
              expect(
                results.every(
                  (result) => result.onGetCalled == scope.expectedCachedOnGet,
                ),
                isTrue,
                reason:
                    '${scope.label} Scope Instance ${variation.label} should call onGet only once.',
              );
            }
          },
        );
      }
    }

    test(
      'Contextual module direct get vs captured Instance should stay close',
      () async {
        const interaction = 500000;
        const maxRelativeDelta = 0.25;

        final directResults = await _measureContextModuleMany(
          warmups: warmups,
          runs: runs,
          exercise: (ddi) {
            final module = ddi.get<ContextualBenchmarkModule>();

            for (var i = 0; i < interaction; i++) {
              final service = ddi.getWith<ContextualBenchmarkService, Object>(
                context: module.contextQualifier,
              );
              expect(service.origin, 'module-context');
            }
          },
        );

        final instanceResults = await _measureContextModuleMany(
          warmups: warmups,
          runs: runs,
          exercise: (ddi) {
            final module = ddi.get<ContextualBenchmarkModule>();
            final instance = module.contextualInstance;

            for (var i = 0; i < interaction; i++) {
              final service = instance.get();
              expect(service.origin, 'module-context');
            }
          },
        );

        final directMedian = _medianMillis(directResults);
        final instanceMedian = _medianMillis(instanceResults);
        final relativeDelta =
            (instanceMedian - directMedian).abs() / directMedian;

        _printBenchmarkSummary(
          'Contextual module direct get',
          directResults,
          interaction,
        );
        _printBenchmarkSummary(
          'Contextual module captured Instance',
          instanceResults,
          interaction,
        );

        expect(
          directResults.every((result) => result.onCreateCalled == 1),
          isTrue,
        );
        expect(
          directResults.every((result) => result.onGetCalled == interaction),
          isTrue,
        );
        expect(
          instanceResults.every((result) => result.onCreateCalled == 1),
          isTrue,
        );
        expect(
          instanceResults.every((result) => result.onGetCalled == interaction),
          isTrue,
        );
        expect(
          relativeDelta,
          lessThan(maxRelativeDelta),
          reason:
              'Contextual module direct get and captured Instance should stay close.',
        );
      },
    );

    test(
      'Contextual module captured Instance with cache should minimize onGet',
      () async {
        const interaction = 500000;

        final results = await _measureContextModuleMany(
          warmups: warmups,
          runs: runs,
          exercise: (ddi) {
            final module = ddi.get<ContextualBenchmarkModule>();
            final contextualInstance = module.cachedContextualInstance;
            for (var i = 0; i < interaction; i++) {
              final service = contextualInstance.get();
              expect(service.origin, 'module-context');
            }
          },
        );

        _printBenchmarkSummary(
          'Contextual module captured Instance with cache',
          results,
          interaction,
        );

        expect(
          results.every((result) => result.onCreateCalled == 1),
          isTrue,
        );
        expect(
          results.every((result) => result.onGetCalled == 1),
          isTrue,
          reason:
              'Contextual module captured Instance with cache should call onGet only once.',
        );
      },
    );
  });
}
