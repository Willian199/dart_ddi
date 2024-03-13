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
        onError: () => value = 4,
      );

      // Fire event
      ddiEvent.fire(2, qualifier: 'error_event');

      // Wait for event to complete
      await Future.delayed(Duration.zero);

      expect(value, 4);

      ddiEvent.unsubscribe(eventCallback, qualifier: 'error_event');
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
        onError: () => value = 4,
        onComplete: () => value = 5,
      );

      // Fire event
      ddiEvent.fire(2, qualifier: 'complet_event');

      // Wait for event to complete
      await Future.delayed(Duration.zero);

      expect(value, 5);

      ddiEvent.unsubscribe(eventCallback, qualifier: 'complet_event');
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
        onError: () => eventOrder.add(-1),
      );

      expect(ddiEvent.isRegistered(qualifier: 'concurrent_event_with_error'),
          isTrue);

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

      expect(ddiEvent.isRegistered(qualifier: 'concurrent_event_with_complete'),
          isTrue);

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

      ddiEvent.unsubscribe(callback,
          qualifier: 'concurrent_event_with_complete');
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
        onError: () => eventOrder.add(-1),
        onComplete: () => eventOrder.add(0),
      );

      expect(
          ddiEvent.isRegistered(
              qualifier: 'concurrent_event_with_error_complete'),
          isTrue);

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

      ddiEvent.unsubscribe(callback,
          qualifier: 'concurrent_event_with_error_complete');
    });
  });
}
