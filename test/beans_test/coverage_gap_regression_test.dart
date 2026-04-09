import 'package:dart_ddi/dart_ddi.dart';
import 'package:dart_ddi/src/core/ddi_default_strategy.dart';
import 'package:dart_ddi/src/data/ddi_context_models.dart';
import 'package:dart_ddi/src/utils/interceptor_resolver.dart';
import 'package:test/test.dart';

import '../clazz_samples/payment_service.dart';

class _ProbeInterceptor extends DDIInterceptor<Object> {}

DDIBaseFactory<Object> _factory({bool canDestroy = true}) {
  return SingletonFactory<Object>(
    builder: (() => Object()).builder,
    canDestroy: canDestroy,
  );
}

void main() {
  group('Coverage Gap Regression', () {
    group('BeanEntry and QualifierContext', () {
      test('BeanEntry should ignore primary qualifier from aliases', () {
        final entry = BeanEntry(
          factory: _factory(),
          primaryQualifier: 'primary',
          aliases: {'primary', 'alias-a'},
        );

        expect(entry.aliases, {'alias-a'});
        expect(entry.allQualifiers, {'primary', 'alias-a'});
      });

      test('addAliases should throw when primary qualifier is missing', () {
        final context = QualifierContext.root(rootQualifier: 'root');

        expect(
          () => context.addAliases('missing', {'alias'}),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('removeEntry should be a no-op for ambiguous alias owners', () {
        final context = QualifierContext.root(rootQualifier: 'root');

        context.setEntry(
          'a',
          BeanEntry(
            factory: _factory(),
            primaryQualifier: 'a',
            aliases: {'shared'},
          ),
        );
        context.setEntry(
          'b',
          BeanEntry(
            factory: _factory(),
            primaryQualifier: 'b',
            aliases: {'shared'},
          ),
        );

        final removed = context.removeEntry('shared');

        expect(context.getEntry('shared'), isNull);
        expect(removed, isNull);
        expect(context.getPrimaryEntry('a'), isNotNull);
        expect(context.getPrimaryEntry('b'), isNotNull);
        expect(
            context.aliasOwnersFor('shared'), containsAll(<Object>{'a', 'b'}));
      });

      test('removeEntry should return null for null key', () {
        final context = QualifierContext.root(rootQualifier: 'root');
        expect(context.removeEntry(null), isNull);
      });

      test('pickPrimaryByPriority should prefer smallest non-null priority',
          () {
        final context = QualifierContext.root(rootQualifier: 'root');
        context.setEntry(
          'a',
          BeanEntry(
            factory: _factory(),
            primaryQualifier: 'a',
          ),
        );
        context.setEntry(
          'b',
          BeanEntry(
            factory: _factory(),
            primaryQualifier: 'b',
            priority: 5,
          ),
        );
        context.setEntry(
          'c',
          BeanEntry(
            factory: _factory(),
            primaryQualifier: 'c',
            priority: 1,
          ),
        );

        final picked = context.pickPrimaryByPriority(
          <Object>['missing', 'a', 'b', 'c'],
        );

        expect(picked, 'c');
      });

      test('hasNonDestroyableEntries should be recalculated on replacement',
          () {
        final context = QualifierContext.root(rootQualifier: 'root');

        context.setEntry(
          'a',
          BeanEntry(
            factory: _factory(canDestroy: false),
            primaryQualifier: 'a',
          ),
        );
        expect(context.hasNonDestroyableEntries, isTrue);

        context.setEntry(
          'a',
          BeanEntry(
            factory: _factory(),
            primaryQualifier: 'a',
          ),
        );

        expect(context.hasNonDestroyableEntries, isFalse);
      });
    });

    group('DDIDefaultStrategy', () {
      test('destroyContext should throw for root context', () {
        final strategy = DDIDefaultStrategy();
        final root = strategy.currentContext;

        expect(
          () => strategy.destroyContext(root),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('contextDestroyOrder should return empty for unknown context', () {
        final strategy = DDIDefaultStrategy();
        expect(strategy.contextDestroyOrder('missing'), isEmpty);
      });

      test('entries and qualifiersOf should be empty for unknown context', () {
        final strategy = DDIDefaultStrategy();
        expect(strategy.entries(context: 'missing'), isEmpty);
        expect(strategy.qualifiersOf('bean', context: 'missing'), isEmpty);
      });

      test('public DDI get should throw AmbiguousAliasException on alias tie',
          () async {
        final ddi = DDI.newInstance();

        await ddi.application<PaymentService>(
          () => CreditCardPaymentService(),
          qualifier: 'payment-credit',
          priority: 1,
        );
        await ddi.application<PaymentService>(
          () => PayPalPaymentService(),
          qualifier: 'payment-paypal',
          priority: 1,
        );

        expect(
          () => ddi.get<PaymentService>(),
          throwsA(
            isA<AmbiguousAliasException>().having(
              (e) => e.qualifiers,
              'qualifiers',
              containsAll(<Object>{'payment-credit', 'payment-paypal'}),
            ),
          ),
        );
      });
    });

    group('Exceptions and Resolver', () {
      test('AmbiguousAliasException toString should sort qualifiers', () {
        const exception = AmbiguousAliasException(
          alias: 'service',
          context: 'ctx',
          qualifiers: {'z', 'a'},
        );

        expect(
          exception.toString(),
          contains('Found qualifiers: a, z'),
        );
      });

      test('WeakReferenceCollectedException should expose readable message',
          () {
        const exception = WeakReferenceCollectedException('MyType');
        expect(exception.toString(), contains('MyType'));
      });

      test('InterceptorResolver should resolve sync and async interceptors',
          () async {
        final ddi = DDI.newInstance();

        await ddi.object<_ProbeInterceptor>(_ProbeInterceptor());
        final syncResolved = InterceptorResolver.resolveSync(
          ddiInstance: ddi,
          qualifier: _ProbeInterceptor,
        );
        expect(syncResolved, isA<_ProbeInterceptor>());

        final ddiAsync = DDI.newInstance();
        await ddiAsync.application<_ProbeInterceptor>(
          () async => _ProbeInterceptor(),
        );
        final asyncResolved = InterceptorResolver.resolveAsync(
          ddiInstance: ddiAsync,
          qualifier: _ProbeInterceptor,
        );
        final resolved =
            asyncResolved is Future ? await asyncResolved : asyncResolved;
        expect(resolved, isA<_ProbeInterceptor>());
      });
    });
  });
}
