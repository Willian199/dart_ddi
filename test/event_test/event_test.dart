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
          throwsA(isA<EventNotFound>()));
    });

    test('subscribe adds event to the correct type', () {
      int localValue = 0;
      void eventFunction(int value) => localValue += value;

      DDIEvent.instance.subscribe<int>(eventFunction);

      expect(localValue, 0);

      DDIEvent.instance.fire(1);

      expect(localValue, 1);

      DDIEvent.instance.unsubscribe(eventFunction);

      expect(() => DDIEvent.instance.fire(1), throwsA(isA<EventNotFound>()));
    });

    test('subscribe adds event and remove after fire', () {
      int localValue = 0;
      void eventFunction(int value) => localValue += value;

      DDIEvent.instance
          .subscribe<int>(eventFunction, unsubscribeAfterFire: true);

      expect(localValue, 0);

      DDIEvent.instance.fire(1);

      expect(localValue, 1);

      expect(() => DDIEvent.instance.fire(1), throwsA(isA<EventNotFound>()));
    });

    test('subscribe adds two event with priority', () {
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

      DDIEvent.instance.unsubscribe(eventFunction);
      DDIEvent.instance.unsubscribe(negateFunction);
    });

    test('subscribe adds two event with priority and wrong order', () {
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

      DDIEvent.instance.unsubscribe(eventFunction);
      DDIEvent.instance.unsubscribe(negateFunction);
    });

    test('subscribe adds the same event two times', () {
      int localValue = 0;
      void eventFunction(int value) => localValue += value;

      DDIEvent.instance.subscribe<int>(eventFunction, priority: 1);
      DDIEvent.instance.subscribe<int>(eventFunction, priority: 2);

      expect(localValue, 0);

      DDIEvent.instance.fire(1);

      expect(localValue, 1);

      DDIEvent.instance.fire(1);

      expect(localValue, 2);

      DDIEvent.instance.unsubscribe(eventFunction);
    });

    test('subscribe with registerIf', () {
      int localValue = 0;
      void eventFunction(int value) => localValue += value;

      DDIEvent.instance.subscribe<int>(
        eventFunction,
        registerIf: () => false,
      );

      expect(localValue, 0);

      DDIEvent.instance.fire(1);

      expect(localValue, 0);
    });

    test('subscribe with async', () {
      int localValue = 0;
      void eventFunction(int value) => localValue += value;

      DDIEvent.instance.subscribeAsync<int>(eventFunction);

      expect(localValue, 0);

      DDIEvent.instance.fire(1);
      //The async will be executed only after this test is finished. So the value dont change
      expect(localValue, 0);
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
      int localValue = 0;
      void eventFunction(int value) {
        localValue += value;
      }

      DDIEvent.instance
          .subscribeIsolate(eventFunction, qualifier: 'testQualifier');

      expect(localValue, 0);

      DDIEvent.instance.fire(1, qualifier: 'testQualifier');

      expect(localValue, 0);

      DDIEvent.instance.unsubscribe(eventFunction, qualifier: 'testQualifier');
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
    });

    test('unsubscribeAsync', () async {
      final Completer<bool> completer = Completer<bool>();

      void callback(bool flag) {
        completer.complete(flag);
      }

      DDIEvent.instance.subscribeAsync<bool>(callback);

      DDIEvent.instance.unsubscribe<bool>(callback);

      expect(() => DDIEvent.instance.fire<bool>(true),
          throwsA(isA<EventNotFound>()));

      await expectLater(completer.future, doesNotComplete);
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
          throwsA(isA<EventNotFound>()));
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
    });

    test('Running event without lock', () async {
      final List<int> eventOrder = [];

      void callback(int value) async {
        await Future.delayed(Duration(milliseconds: (1000 / value).round()));
        print('callback $value');
        eventOrder.add(value);
      }

      ddiEvent.subscribeAsync(callback, qualifier: 'concurrent_event');

      expect(ddiEvent.isRegistered(qualifier: 'concurrent_event'), isTrue);

      for (int i = 1; i <= 5; i++) {
        ddiEvent.fire(i, qualifier: 'concurrent_event');
      }

      await Future.delayed(const Duration(milliseconds: 3000));

      expect(eventOrder[4], 1);
      expect(eventOrder[0], 5);

      ddiEvent.unsubscribe(callback, qualifier: 'concurrent_event');
    });

    test('Running event with lock', () async {
      final List<int> eventOrder = [];

      void callback(int value) async {
        await Future.delayed(Duration(milliseconds: (2000 / value).round()));
        print('callback $value');
        eventOrder.add(value);
      }

      ddiEvent.subscribeAsync(callback,
          qualifier: 'concurrent_lock_event', lock: true);

      expect(ddiEvent.isRegistered(qualifier: 'concurrent_lock_event'), isTrue);

      for (int i = 1; i <= 5; i++) {
        ddiEvent.fire(i, qualifier: 'concurrent_lock_event');
      }

      await Future.delayed(const Duration(milliseconds: 5000));

      expect(eventOrder[4], 5);
      expect(eventOrder[0], 1);

      ddiEvent.unsubscribe(callback, qualifier: 'concurrent_lock_event');
    });

    test('Running Isolated event with lock', () async {
      final List<int> eventOrder = [];

      void callback(int value) async {
        await Future.delayed(Duration(milliseconds: (2000 / value).round()));
        print('callback $value');
        eventOrder.add(value);
      }

      ddiEvent.subscribeAsync(callback,
          qualifier: 'concurrent_lock_isolate', lock: true);

      expect(
          ddiEvent.isRegistered(qualifier: 'concurrent_lock_isolate'), isTrue);

      for (int i = 1; i <= 5; i++) {
        ddiEvent.fire(i, qualifier: 'concurrent_lock_isolate');
      }

      await Future.delayed(const Duration(milliseconds: 5000));

      expect(eventOrder[4], 5);
      expect(eventOrder[0], 1);

      ddiEvent.unsubscribe(callback, qualifier: 'concurrent_lock_isolate');
    });
  });
}
