import 'package:dart_ddi/dart_ddi.dart';
import 'package:dart_ddi/src/exception/event_not_found.dart';
import 'package:test/test.dart';

void eventDurationTests() {
  group('DDI Event Duration tests', () {
    test('Subscribe periodic event and receive values', () async {
      int finalValue = 0;
      void mockEvent(int value) => finalValue += value;
      const recurrenceDuration = Duration(milliseconds: 100);
      const defaultValue = 42;
      const maxExecutions = 5;

      ddiEvent.subscribe<int>(
        mockEvent,
        recurrenceDuration: recurrenceDuration,
        defaultValue: defaultValue,
        maxRetry: maxExecutions,
        qualifier: 'duration_test',
      );

      // Wait a bit more than the interval to ensure events are called
      await Future.delayed(recurrenceDuration * (maxExecutions + 2));

      expect(finalValue, defaultValue * maxExecutions);
      // After the maxExecutions, the event should be removed
      expect(ddiEvent.isRegistered<int>(qualifier: 'duration_test'), isFalse);
    });

    test('Subscribe periodic event and cancel after some time', () async {
      int finalValue = 0;
      void mockEvent(int value) => finalValue += value;

      const recurrenceDuration = Duration(milliseconds: 100);
      const defaultValue = 42;
      const maxExecutions = 5;

      ddiEvent.subscribe<int>(
        mockEvent,
        recurrenceDuration: recurrenceDuration,
        defaultValue: defaultValue,
        maxRetry: maxExecutions,
        qualifier: 'duration_test',
      );

      // Wait a bit less than the interval to ensure events are not called
      await Future.delayed(recurrenceDuration * (maxExecutions - 1), () {});

      ddiEvent.unsubscribe<int>(
        mockEvent,
        qualifier: 'duration_test',
      );

      // Wait another interval to ensure events are not called after unsubscribing
      await Future.delayed(recurrenceDuration, () {});

      expect(finalValue < defaultValue * maxExecutions, isTrue);

      expect(
          ddiEvent.isRegistered<int>(
            qualifier: 'duration_test',
          ),
          isFalse);
    });

    test('Subscribe periodic event and throw error in event function', () async {
      int count = 0;
      void mockEvent(int value) {
        count++;
        throw Exception('Mock event error');
      }

      const recurrenceDuration = Duration(milliseconds: 100);
      const defaultValue = 42;
      const maxExecutions = 5;

      ddiEvent.subscribe<int>(
        mockEvent,
        recurrenceDuration: recurrenceDuration,
        defaultValue: defaultValue,
        maxRetry: maxExecutions,
        qualifier: 'throw error',
      );

      // Wait a bit more than the interval to ensure events are called
      await Future.delayed(recurrenceDuration * (maxExecutions + 1));

      // After the maxExecutions, the event should be removed
      expect(ddiEvent.isRegistered<int>(qualifier: 'throw error'), isFalse);
      expect(count, maxExecutions);
    });

    test('Subscribe periodic event with invalid recurrenceDuration', () async {
      void mockEvent(int value) => {};
      const defaultValue = 42;
      const maxExecutions = 5;
      const invalidRecurrenceDuration = Duration(seconds: -1);

      expect(
        () => ddiEvent.subscribe<int>(
          mockEvent,
          recurrenceDuration: invalidRecurrenceDuration,
          defaultValue: defaultValue,
          maxRetry: maxExecutions,
          qualifier: 'duration_test',
        ),
        throwsA(isA<AssertionError>()),
      );

      // Ensure event is not registered
      expect(
          ddiEvent.isRegistered<int>(
            qualifier: 'duration_test',
          ),
          isFalse);
    });

    test('Subscribe periodic event without defaultValue', () async {
      void mockEvent(int value) => {};
      const maxExecutions = 5;
      const invalidRecurrenceDuration = Duration(seconds: 1);

      expect(
        () => ddiEvent.subscribe<int>(
          mockEvent,
          recurrenceDuration: invalidRecurrenceDuration,
          maxRetry: maxExecutions,
          qualifier: 'duration_test',
        ),
        throwsA(isA<AssertionError>()),
      );

      // Ensure event is not registered
      expect(ddiEvent.isRegistered<int>(qualifier: 'duration_test'), isFalse);
    });

    test('Subscribe periodic event with negative maxRetry', () async {
      void mockEvent(int value) => {};
      const recurrenceDuration = Duration(milliseconds: 100);
      const defaultValue = 42;
      const invalidMaxExecutions = -1;

      expect(
        () => ddiEvent.subscribe<int>(
          mockEvent,
          recurrenceDuration: recurrenceDuration,
          defaultValue: defaultValue,
          maxRetry: invalidMaxExecutions,
          qualifier: 'duration_test',
        ),
        throwsA(isA<AssertionError>()),
      );

      // Ensure event is not registered
      expect(ddiEvent.isRegistered<int>(qualifier: 'duration_test'), isFalse);
    });

    test('Subscribe periodic event and cancel invalid event', () async {
      int finalValue = 0;
      void mockEvent(int value) => finalValue += value;
      const recurrenceDuration = Duration(milliseconds: 100);
      const defaultValue = 42;
      const maxExecutions = 5;

      ddiEvent.subscribe<int>(
        mockEvent,
        recurrenceDuration: recurrenceDuration,
        defaultValue: defaultValue,
        maxRetry: maxExecutions,
        qualifier: 'duration_test',
      );

      // Wait a bit less than the interval to ensure events are not called
      await Future.delayed(recurrenceDuration * (maxExecutions - 1));

      // Try to cancel a different event
      void anotherEvent(int value) {}
      ddiEvent.unsubscribe<int>(
        anotherEvent,
        qualifier: 'duration_test',
      );

      // Ensure event is still registered
      expect(ddiEvent.isRegistered<int>(qualifier: 'duration_test'), isTrue);
      ddiEvent.unsubscribe<int>(mockEvent, qualifier: 'duration_test');
      expect(ddiEvent.isRegistered<int>(qualifier: 'duration_test'), isFalse);
    });

    test('Subscribe a event with lock', () async {
      void mockEvent(int value) => {};
      const recurrenceDuration = Duration(milliseconds: 100);
      const defaultValue = 42;
      const maxExecutions = 5;

      expect(
        () => ddiEvent.subscribe<int>(
          mockEvent,
          recurrenceDuration: recurrenceDuration,
          defaultValue: defaultValue,
          maxRetry: maxExecutions,
          lock: true,
          qualifier: 'duration_test',
        ),
        throwsA(isA<AssertionError>()),
      );

      // After firing once, the event should be removed
      expect(ddiEvent.isRegistered<int>(qualifier: 'duration_test'), isFalse);
    });

    test('Subscribe event without recurrenceDuration', () async {
      void mockEvent(int value) => {};
      const defaultValue = 42;

      expect(
        () => ddiEvent.subscribe<int>(
          mockEvent,
          defaultValue: defaultValue,
          qualifier: 'duration_test',
        ),
        throwsA(isA<AssertionError>()),
      );

      // After expiration, the event should be removed
      expect(ddiEvent.isRegistered<int>(qualifier: 'duration_test'), isFalse);
    });

    test('Subscribe event with expirationDuration and fire after expiration', () async {
      int finalValue = 0;
      void mockEvent(int value) => finalValue += value;
      const expirationDuration = Duration(milliseconds: 200);

      ddiEvent.subscribe<int>(
        mockEvent,
        expirationDuration: expirationDuration,
        maxRetry: 1,
        qualifier: 'duration_test',
      );

      // Wait longer than expirationDuration
      await Future.delayed(const Duration(milliseconds: 400));

      expect(() => DDIEvent.instance.fire<int>(1, qualifier: 'duration_test'), throwsA(isA<EventNotFoundException>()));

      // After expiration, the event should be removed
      expect(ddiEvent.isRegistered<int>(qualifier: 'duration_test'), isFalse);
    });

    test('Subscribe event with expirationDuration and fire before expiration', () async {
      int finalValue = 0;
      void mockEvent(int value) => finalValue += value;
      const expirationDuration = Duration(milliseconds: 200);

      ddiEvent.subscribe<int>(
        mockEvent,
        expirationDuration: expirationDuration,
        maxRetry: 1,
        qualifier: 'duration_test',
      );

      await Future.delayed(const Duration(milliseconds: 50));

      DDIEvent.instance.fire<int>(1, qualifier: 'duration_test');

      // Wait longer than expirationDuration
      await Future.delayed(const Duration(milliseconds: 400));

      expect(() => DDIEvent.instance.fire<int>(1, qualifier: 'duration_test'), throwsA(isA<EventNotFoundException>()));

      // After expiration, the event should be removed
      expect(finalValue, 1);
      expect(ddiEvent.isRegistered<int>(qualifier: 'duration_test'), isFalse);
    });

    test('Subscribe event with expirationDuration and cancel before expiration', () async {
      int finalValue = 0;
      void mockEvent(int value) => finalValue += value;
      const expirationDuration = Duration(milliseconds: 200);

      ddiEvent.subscribe<int>(
        mockEvent,
        expirationDuration: expirationDuration,
        maxRetry: 1,
        qualifier: 'duration_test',
      );

      await Future.delayed(const Duration(milliseconds: 50));

      ddiEvent.unsubscribe<int>(mockEvent, qualifier: 'duration_test');

      // Wait longer than expirationDuration
      await Future.delayed(const Duration(milliseconds: 400));

      expect(() => DDIEvent.instance.fire<int>(1, qualifier: 'duration_test'), throwsA(isA<EventNotFoundException>()));

      // After expiration, the event should be removed
      expect(finalValue, 0);
      expect(ddiEvent.isRegistered<int>(qualifier: 'duration_test'), isFalse);
    });

    test('Subscribe periodic event, receive values and cancel after expirationDuration', () async {
      int finalValue = 0;
      void mockEvent(int value) => finalValue += value;
      const recurrenceDuration = Duration(milliseconds: 100);
      const defaultValue = 42;
      const maxExecutions = 5;

      ddiEvent.subscribe<int>(
        mockEvent,
        recurrenceDuration: recurrenceDuration,
        defaultValue: defaultValue,
        maxRetry: maxExecutions,
        expirationDuration: const Duration(milliseconds: 250),
        qualifier: 'duration_test',
      );

      // Wait a bit more than the interval to ensure events are called
      await Future.delayed(recurrenceDuration * (maxExecutions + 2));

      expect(finalValue, defaultValue * 2);
      // After the maxExecutions, the event should be removed
      expect(ddiEvent.isRegistered<int>(qualifier: 'duration_test'), isFalse);
    });
  });
}
