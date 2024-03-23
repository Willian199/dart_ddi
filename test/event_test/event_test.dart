import 'dart:async';

import 'package:dart_ddi/dart_ddi.dart';
import 'package:dart_ddi/src/exception/event_not_found.dart';
import 'package:test/test.dart';

void eventTest() {
  group('DDI Event tests', () {
    test('subscribe adds event to the correct qualifier', () {
      int localValue = 0;
      void eventFunction(int value) => localValue += value;

      DDIEvent.instance.subscribe(eventFunction, qualifier: 'testQualifier');

      expect(localValue, 0);

      DDIEvent.instance.fire(1, qualifier: 'testQualifier');

      expect(localValue, 1);

      DDIEvent.instance.unsubscribe(eventFunction, qualifier: 'testQualifier');

      expect(() => DDIEvent.instance.fire(1, qualifier: 'testQualifier'),
          throwsA(isA<EventNotFoundException>()));

      expect(ddiEvent.isRegistered(qualifier: 'testQualifier'), isFalse);
    });

    test('subscribe adds event to the correct type', () {
      int localValue = 0;
      void eventFunction(int value) => localValue += value;

      DDIEvent.instance.subscribe<int>(eventFunction);

      expect(localValue, 0);

      DDIEvent.instance.fire(1);

      expect(localValue, 1);

      DDIEvent.instance.unsubscribe(eventFunction);

      expect(() => DDIEvent.instance.fire(1),
          throwsA(isA<EventNotFoundException>()));

      expect(ddiEvent.isRegistered<int>(), isFalse);
    });

    test('subscribe adds event and remove after fire', () {
      int localValue = 0;
      void eventFunction(int value) => localValue += value;

      DDIEvent.instance
          .subscribe<int>(eventFunction, unsubscribeAfterFire: true);

      expect(localValue, 0);

      DDIEvent.instance.fire(1);

      expect(localValue, 1);

      expect(() => DDIEvent.instance.fire(1),
          throwsA(isA<EventNotFoundException>()));

      expect(ddiEvent.isRegistered<int>(), isFalse);
    });

    test('subscribe adds two event with priority', () {
      expect(ddiEvent.isRegistered<int>(), isFalse);

      int localValue = 0;
      void eventFunction(int value) => localValue += value;
      void negateFunction(_) => localValue = localValue * -1;

      DDIEvent.instance.subscribe<int>(eventFunction, priority: 1);
      DDIEvent.instance.subscribe<int>(negateFunction, priority: 2);

      expect(localValue, 0);

      DDIEvent.instance.fire(1);

      expect(localValue, -1);

      DDIEvent.instance.fire(-5);

      expect(localValue, 6);

      DDIEvent.instance.unsubscribe<int>(eventFunction);
      DDIEvent.instance.unsubscribe<int>(negateFunction);

      expect(ddiEvent.isRegistered<int>(), isFalse);
    });

    test('subscribe adds two event with priority and wrong order', () {
      expect(ddiEvent.isRegistered<int>(), isFalse);

      int localValue = 0;
      void eventFunction(int value) => localValue += value;
      void negateFunction(_) => localValue = localValue * -1;

      DDIEvent.instance.subscribe<int>(negateFunction, priority: 2);
      DDIEvent.instance.subscribe<int>(eventFunction, priority: 1);

      expect(localValue, 0);

      DDIEvent.instance.fire(1);

      expect(localValue, -1);

      DDIEvent.instance.fire(-5);

      expect(localValue, 6);

      DDIEvent.instance.unsubscribe<int>(eventFunction);
      DDIEvent.instance.unsubscribe<int>(negateFunction);

      expect(ddiEvent.isRegistered<int>(), isFalse);
    });

    test('subscribe adds the same event two times', () {
      expect(ddiEvent.isRegistered<int>(), isFalse);
      int localValue = 0;
      void eventFunction(int value) => localValue += value;

      DDIEvent.instance.subscribe<int>(eventFunction, priority: 1);
      DDIEvent.instance.subscribe<int>(eventFunction, priority: 2);

      expect(localValue, 0);

      DDIEvent.instance.fire(1);

      expect(localValue, 1);

      DDIEvent.instance.fire(1);

      expect(localValue, 2);

      DDIEvent.instance.unsubscribe<int>(eventFunction);

      expect(ddiEvent.isRegistered<int>(), isFalse);
    });

    test('subscribe with registerIf', () {
      expect(ddiEvent.isRegistered<int>(), isFalse);
      int localValue = 0;
      void eventFunction(int value) => localValue += value;

      DDIEvent.instance.subscribe<int>(
        eventFunction,
        registerIf: () => false,
      );

      expect(ddiEvent.isRegistered<int>(), isFalse);
      expect(localValue, 0);

      expect(() => DDIEvent.instance.fire(1),
          throwsA(isA<EventNotFoundException>()));

      expect(localValue, 0);
    });

    test('subscribe with async', () {
      int localValue = 0;
      void eventFunction(int value) => localValue += value;

      DDIEvent.instance.subscribeAsync<int>(eventFunction);

      expect(localValue, 0);

      DDIEvent.instance.fire(1);

      expect(localValue, 1);
    });

    test('subscribe a non allowUnsubscribe event', () {
      int localValue = 0;
      void eventFunction(int value) => localValue += value;

      DDIEvent.instance.subscribe(eventFunction,
          qualifier: 'testQualifier', allowUnsubscribe: false);

      expect(localValue, 0);

      DDIEvent.instance.fire(1, qualifier: 'testQualifier');

      expect(localValue, 1);

      DDIEvent.instance.unsubscribe(eventFunction, qualifier: 'testQualifier');

      DDIEvent.instance.fire(1, qualifier: 'testQualifier');

      expect(localValue, 2);

      expect(ddiEvent.isRegistered(qualifier: 'testQualifier'), isTrue);
    });

    test('subscribe with allowUnsubscribe event, with unsubscribeAfterFire',
        () {
      int localValue = 0;
      void eventFunction(int value) => localValue += value;

      expect(
          () => DDIEvent.instance.subscribe(
                eventFunction,
                qualifier: 'testQualifier',
                allowUnsubscribe: false,
                unsubscribeAfterFire: true,
              ),
          throwsA(const TypeMatcher<AssertionError>()));
    });

    test('subscribe a isolate event', () async {
      expect(ddiEvent.isRegistered(qualifier: 'isolate_Qualifier'), isFalse);

      int localValue = 0;
      void eventFunction(int value) {
        localValue += value;
      }

      DDIEvent.instance
          .subscribeIsolate(eventFunction, qualifier: 'isolate_Qualifier');

      expect(localValue, 0);

      DDIEvent.instance.fire(1, qualifier: 'isolate_Qualifier');

      expect(localValue, 0);

      DDIEvent.instance
          .unsubscribe(eventFunction, qualifier: 'isolate_Qualifier');

      expect(ddiEvent.isRegistered(qualifier: 'isolate_Qualifier'), isFalse);
    });

    test('subscribeAsync and fire event asynchronously', () async {
      final Completer<bool> asyncFunctionCompleter = Completer<bool>();

      void callback(bool value) async {
        asyncFunctionCompleter.complete(value);
      }

      DDIEvent.instance.subscribeAsync<bool>(callback);

      DDIEvent.instance.fire<bool>(true);

      await expectLater(asyncFunctionCompleter.future, completion(isTrue));

      DDIEvent.instance.unsubscribe<bool>(callback);

      expect(ddiEvent.isRegistered<bool>(), isFalse);
    });

    test('unsubscribeAsync', () async {
      final Completer<bool> completer = Completer<bool>();

      void callback(bool flag) {
        completer.complete(flag);
      }

      DDIEvent.instance.subscribeAsync<bool>(callback);

      DDIEvent.instance.unsubscribe<bool>(callback);

      expect(() => DDIEvent.instance.fire<bool>(true),
          throwsA(isA<EventNotFoundException>()));

      await expectLater(completer.future, doesNotComplete);

      expect(ddiEvent.isRegistered<bool>(), isFalse);
    });

    test(
        'subscribeAsync with qualifier and fire event with qualifier asynchronously',
        () async {
      final Completer<bool> asyncFunctionCompleter = Completer<bool>();

      void callback(bool value) {
        asyncFunctionCompleter.complete(value);
      }

      DDIEvent.instance
          .subscribeAsync<bool>(callback, qualifier: 'test_qualifier');

      DDIEvent.instance.fire<bool>(true, qualifier: 'test_qualifier');

      await expectLater(asyncFunctionCompleter.future, completion(isTrue));

      DDIEvent.instance
          .unsubscribe<bool>(callback, qualifier: 'test_qualifier');

      expect(ddiEvent.isRegistered<bool>(qualifier: 'test_qualifier'), isFalse);
    });

    test('subscribeAsync with registerIf and fire event based on registerIf',
        () async {
      final Completer<bool> asyncFunctionCompleter = Completer<bool>();

      void callback(bool value) async {
        asyncFunctionCompleter.complete(value);
      }

      DDIEvent.instance.subscribeAsync<bool>(
        callback,
        registerIf: () => true,
      );

      DDIEvent.instance.fire<bool>(true);

      await expectLater(asyncFunctionCompleter.future, completion(isTrue));

      DDIEvent.instance.unsubscribe<bool>(callback);

      expect(ddiEvent.isRegistered<bool>(), isFalse);
    });

    test('subscribeAsync and fire event with unsubscribeAfterFire', () async {
      final Completer<bool> asyncFunctionCompleter = Completer<bool>();

      void callback(bool value) async {
        asyncFunctionCompleter.complete(value);
      }

      DDIEvent.instance
          .subscribeAsync<bool>(callback, unsubscribeAfterFire: true);

      DDIEvent.instance.fire<bool>(true);

      await expectLater(asyncFunctionCompleter.future, completion(isTrue));

      await expectLater(() => DDIEvent.instance.fire<bool>(true),
          throwsA(isA<EventNotFoundException>()));

      expect(ddiEvent.isRegistered<bool>(), isFalse);
    });

    test('subscribeAsync with multiple subscribers and fire event', () async {
      final Completer<bool> asyncFunctionCompleter1 = Completer<bool>();
      final Completer<bool> asyncFunctionCompleter2 = Completer<bool>();

      void callback1(bool value) async {
        asyncFunctionCompleter1.complete(value);
      }

      void callback2(bool value) async {
        asyncFunctionCompleter2.complete(value);
      }

      DDIEvent.instance.subscribeAsync<bool>(callback1);
      DDIEvent.instance.subscribeAsync<bool>(callback2);

      DDIEvent.instance.fire<bool>(true);

      await expectLater(asyncFunctionCompleter1.future, completion(isTrue));
      await expectLater(asyncFunctionCompleter2.future, completion(isTrue));

      DDIEvent.instance.unsubscribe<bool>(callback1);
      DDIEvent.instance.unsubscribe<bool>(callback2);

      expect(ddiEvent.isRegistered<bool>(), isFalse);
    });

    // Teste para verificar se unsubscribe remove corretamente eventos duplicados
    test('Ignore duplicates and unsubscribe removes events correctly', () {
      int value = 0;
      void event(int val) => value += val;

      ddiEvent.subscribe<int>(event, qualifier: 'duplicat_test');
      ddiEvent.subscribe<int>(event, qualifier: 'duplicat_test');

      DDIEvent.instance.fire<int>(1, qualifier: 'duplicat_test');

      ddiEvent.unsubscribe<int>(event, qualifier: 'duplicat_test');

      expect(value, 1);
      expect(ddiEvent.isRegistered<int>(qualifier: 'duplicat_test'), false);
    });

    test('FireWait removes events marked for unsubscription', () async {
      int localValue = 0;
      void eventFunction(int value) async {
        await Future.delayed(const Duration(milliseconds: 100));
        localValue += value;
      }

      DDIEvent.instance.subscribe<int>(eventFunction,
          qualifier: 'removeAfterFire', unsubscribeAfterFire: true);

      expect(localValue, 0);

      await DDIEvent.instance.fireWait(1, qualifier: 'removeAfterFire');

      expect(localValue, 1);

      expect(() => DDIEvent.instance.fireWait(1, qualifier: 'removeAfterFire'),
          throwsA(isA<EventNotFoundException>()));

      expect(ddiEvent.isRegistered<int>(qualifier: 'removeAfterFire'), isFalse);
    });

    test(
        'Unsubscribe throws EventNotFoundException for event with qualifier not found',
        () {
      void event(String value) => {};

      expect(() => ddiEvent.unsubscribe<String>(event, qualifier: 'qualifier'),
          throwsA(isA<EventNotFoundException>()));
    });
  });
}
