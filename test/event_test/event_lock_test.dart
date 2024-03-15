import 'package:dart_ddi/dart_ddi.dart';
import 'package:test/test.dart';

void eventLockTest() {
  group('DDI Event Lock tests', () {
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

      expect(ddiEvent.isRegistered(qualifier: 'concurrent_event'), isFalse);
    });

    test('Running event with lock', () async {
      final List<int> eventOrder = [];

      void callback(int value) async {
        await Future.delayed(Duration(milliseconds: (2000 / value).round()));
        print('callback $value');
        eventOrder.add(value);
      }

      ddiEvent.subscribeAsync(callback, qualifier: 'concurrent_lock_event', lock: true);

      expect(ddiEvent.isRegistered(qualifier: 'concurrent_lock_event'), isTrue);

      for (int i = 1; i <= 5; i++) {
        ddiEvent.fire(i, qualifier: 'concurrent_lock_event');
      }

      await Future.delayed(const Duration(milliseconds: 5000));

      expect(eventOrder[4], 5);
      expect(eventOrder[0], 1);

      ddiEvent.unsubscribe(callback, qualifier: 'concurrent_lock_event');

      expect(ddiEvent.isRegistered(qualifier: 'concurrent_lock_event'), isFalse);
    });

    test('Running Isolated event with lock', () async {
      void callback(int value) async {
        await Future.delayed(Duration(milliseconds: (2000 / value).round()));
        print('callback $value');
      }

      ddiEvent.subscribeIsolate(callback, qualifier: 'concurrent_lock_isolate', lock: true);

      expect(ddiEvent.isRegistered(qualifier: 'concurrent_lock_isolate'), isTrue);

      for (int i = 1; i <= 5; i++) {
        ddiEvent.fire(i, qualifier: 'concurrent_lock_isolate');
      }

      await Future.delayed(const Duration(milliseconds: 5000));

      ddiEvent.unsubscribe(callback, qualifier: 'concurrent_lock_isolate');

      expect(ddiEvent.isRegistered(qualifier: 'concurrent_lock_isolate'), isFalse);
    });

    test('Subscribe and Fire event with onError', () async {
      int value = 1;
      Future<void> eventCallback(int v) async {
        value = v;
        throw Exception('Error in eventCallback');
      }

      // Subscribe to event with onError
      ddiEvent.subscribeAsync(
        eventCallback,
        qualifier: 'error_event',
        onError: (_, __, ___) => value = 4,
      );

      // Fire event
      ddiEvent.fire(2, qualifier: 'error_event');

      // Wait for event to complete
      await Future.delayed(Duration.zero);

      expect(value, 4);

      ddiEvent.unsubscribe(eventCallback, qualifier: 'error_event');

      expect(ddiEvent.isRegistered(qualifier: 'error_event'), isFalse);
    });

    test('Subscribe and Fire event with onComplete', () async {
      int value = 1;
      Future<void> eventCallback(int v) async {
        value = v;
        throw Exception('Error in eventCallback');
      }

      // Subscribe to event with onError
      ddiEvent.subscribeAsync(
        eventCallback,
        qualifier: 'complet_event',
        onError: (_, __, ___) => value = 4,
        onComplete: () => value = 5,
      );

      // Fire event
      ddiEvent.fire(2, qualifier: 'complet_event');

      // Wait for event to complete
      await Future.delayed(Duration.zero);

      expect(value, 5);

      ddiEvent.unsubscribe(eventCallback, qualifier: 'complet_event');

      expect(ddiEvent.isRegistered(qualifier: 'complet_event'), isFalse);
    });

    test('Running event with lock and onError', () async {
      final List<int> eventOrder = [];

      void callback(int value) async {
        await Future.delayed(Duration(milliseconds: (1000 / value).round()));
        print('callback $value');
        if (value % 2 == 1) {
          throw Exception();
        }
        eventOrder.add(value);
      }

      ddiEvent.subscribeAsync(
        callback,
        qualifier: 'concurrent_event_with_error',
        lock: true,
        onError: (_, __, ___) => eventOrder.add(-1),
      );

      expect(ddiEvent.isRegistered(qualifier: 'concurrent_event_with_error'), isTrue);

      for (int i = 1; i <= 5; i++) {
        ddiEvent.fire(i, qualifier: 'concurrent_event_with_error');
      }

      await Future.delayed(const Duration(milliseconds: 3000));

      expect(eventOrder[0], -1);
      expect(eventOrder[1], 2);
      expect(eventOrder[2], -1);
      expect(eventOrder[3], 4);
      expect(eventOrder[4], -1);

      ddiEvent.unsubscribe(callback, qualifier: 'concurrent_event_with_error');

      expect(ddiEvent.isRegistered(qualifier: 'concurrent_event_with_error'), isFalse);
    });

    test('Running event with lock and onComplete', () async {
      final List<int> eventOrder = [];

      void callback(int value) async {
        await Future.delayed(Duration(milliseconds: (1000 / value).round()));
        print('callback $value');
        eventOrder.add(value);
      }

      ddiEvent.subscribeAsync(
        callback,
        qualifier: 'concurrent_event_with_complete',
        lock: true,
        onComplete: () => eventOrder.add(0),
      );

      expect(ddiEvent.isRegistered(qualifier: 'concurrent_event_with_complete'), isTrue);

      for (int i = 1; i <= 5; i++) {
        ddiEvent.fire(i, qualifier: 'concurrent_event_with_complete');
      }

      await Future.delayed(const Duration(milliseconds: 3000));

      expect(eventOrder[0], 1);
      expect(eventOrder[1], 0);
      expect(eventOrder[2], 2);
      expect(eventOrder[3], 0);
      expect(eventOrder[4], 3);
      expect(eventOrder[5], 0);
      expect(eventOrder[6], 4);
      expect(eventOrder[7], 0);
      expect(eventOrder[8], 5);
      expect(eventOrder[9], 0);

      ddiEvent.unsubscribe(callback, qualifier: 'concurrent_event_with_complete');

      expect(ddiEvent.isRegistered(qualifier: 'concurrent_event_with_complete'), isFalse);
    });

    test('Running event with lock, onError and onComplete', () async {
      final List<int> eventOrder = [];

      void callback(int value) async {
        await Future.delayed(Duration(milliseconds: (1000 / value).round()));
        print('callback $value');
        if (value % 2 == 1) {
          throw Exception();
        }
        eventOrder.add(value);
      }

      ddiEvent.subscribeAsync(
        callback,
        qualifier: 'concurrent_event_with_error_complete',
        lock: true,
        onError: (_, __, ___) => eventOrder.add(-1),
        onComplete: () => eventOrder.add(0),
      );

      expect(ddiEvent.isRegistered(qualifier: 'concurrent_event_with_error_complete'), isTrue);

      for (int i = 1; i <= 5; i++) {
        ddiEvent.fire(i, qualifier: 'concurrent_event_with_error_complete');
      }

      await Future.delayed(const Duration(milliseconds: 3000));

      expect(eventOrder[0], -1);
      expect(eventOrder[1], 0);
      expect(eventOrder[2], 2);
      expect(eventOrder[3], 0);
      expect(eventOrder[4], -1);
      expect(eventOrder[5], 0);
      expect(eventOrder[6], 4);
      expect(eventOrder[7], 0);
      expect(eventOrder[8], -1);
      expect(eventOrder[9], 0);

      ddiEvent.unsubscribe(callback, qualifier: 'concurrent_event_with_error_complete');

      expect(ddiEvent.isRegistered(qualifier: 'concurrent_event_with_error_complete'), isFalse);
    });

    test('Running Isolated event with lock and onError', () async {
      int count = 0;

      void callback(int value) async {
        await Future.delayed(Duration(milliseconds: (2000 / value).round()));
        print('callback $value');
        throw Exception();
      }

      ddiEvent.subscribeIsolate(callback, qualifier: 'concurrent_lock_isolate_onError', lock: true, onError: (_, __, ___) {
        count++;
      });

      expect(ddiEvent.isRegistered(qualifier: 'concurrent_lock_isolate_onError'), isTrue);

      for (int i = 1; i <= 5; i++) {
        ddiEvent.fire(i, qualifier: 'concurrent_lock_isolate_onError');
      }

      await Future.delayed(const Duration(milliseconds: 5000));

      expect(count, 5);

      ddiEvent.unsubscribe(callback, qualifier: 'concurrent_lock_isolate_onError');

      expect(ddiEvent.isRegistered(qualifier: 'concurrent_lock_isolate_onError'), isFalse);
    });

    test('Running Isolated event with lock and onComplete', () async {
      int count = 0;

      void callback(int value) async {
        await Future.delayed(Duration(milliseconds: (2000 / value).round()));
        print('callback $value');
        throw Exception();
      }

      ddiEvent.subscribeIsolate(callback, qualifier: 'concurrent_lock_isolate_onComplete', lock: true, onComplete: () {
        count++;
      });

      expect(ddiEvent.isRegistered(qualifier: 'concurrent_lock_isolate_onComplete'), isTrue);

      for (int i = 1; i <= 5; i++) {
        ddiEvent.fire(i, qualifier: 'concurrent_lock_isolate_onComplete');
      }

      await Future.delayed(const Duration(milliseconds: 5000));

      expect(count, 5);

      ddiEvent.unsubscribe(callback, qualifier: 'concurrent_lock_isolate_onComplete');

      expect(ddiEvent.isRegistered(qualifier: 'concurrent_lock_isolate_onComplete'), isFalse);
    });

    test('Running multiples event with lock', () async {
      expect(ddiEvent.isRegistered(qualifier: 'multiple_events'), isFalse);

      final List<int> eventOrder = [];

      void callback(int value) async {
        await Future.delayed(Duration(milliseconds: (2000 / value).round()));
        print('normal callback $value');
        eventOrder.add(value);
      }

      Future<void> callbackAsync(int value) async {
        await Future.delayed(Duration(milliseconds: (2000 / value).round()));
        print('Async callback $value');
        eventOrder.add(value + 10);
      }

      Future<void> callbackIsolate(int value) async {
        await Future.delayed(Duration(milliseconds: (2000 / value).round()));
        print('Isolate callback $value');
      }

      ddiEvent.subscribe(callback, qualifier: 'multiple_events', lock: true);
      ddiEvent.subscribeAsync(callbackAsync, qualifier: 'multiple_events', lock: true);
      ddiEvent.subscribeIsolate(callbackIsolate, qualifier: 'multiple_events', lock: true);

      expect(ddiEvent.isRegistered(qualifier: 'multiple_events'), isTrue);

      for (int i = 1; i <= 5; i++) {
        ddiEvent.fire(i, qualifier: 'multiple_events');
      }

      await Future.delayed(const Duration(milliseconds: 5000));

      expect(eventOrder[0], 1);
      expect(eventOrder[1], 11);
      expect(eventOrder[2], 2);
      expect(eventOrder[3], 12);
      expect(eventOrder[4], 3);
      expect(eventOrder[5], 13);
      expect(eventOrder[6], 4);
      expect(eventOrder[7], 14);
      expect(eventOrder[8], 5);
      expect(eventOrder[9], 15);

      ddiEvent.unsubscribe(callback, qualifier: 'multiple_events');
      ddiEvent.unsubscribe(callbackAsync, qualifier: 'multiple_events');
      ddiEvent.unsubscribe(callbackIsolate, qualifier: 'multiple_events');

      expect(ddiEvent.isRegistered(qualifier: 'multiple_events'), isFalse);
    });
  });
}
