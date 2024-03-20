import 'package:dart_ddi/dart_ddi.dart';
import 'package:test/test.dart';

void eventFilterTest() {
  group('DDI Event Filter tests', () {
    test('Subscribe event with filter', () {
      int count = 0;

      void callback(int value) => count++;

      ddiEvent.subscribe(
        callback,
        qualifier: 'async_event',
        filter: (int v) => v % 2 == 0,
      );

      expect(ddiEvent.isRegistered(qualifier: 'async_event'), isTrue);

      for (int i = 1; i <= 5; i++) {
        ddiEvent.fire(i, qualifier: 'async_event');
      }

      expect(count, 2);

      ddiEvent.unsubscribe(callback, qualifier: 'async_event');

      expect(ddiEvent.isRegistered(qualifier: 'async_event'), isFalse);
    });

    test('Subscribe future event with filter', () async {
      int count = 0;

      void callback(int value) async {
        await Future.delayed(Duration(milliseconds: (1000 / value).round()));
        count++;
      }

      ddiEvent.subscribe(
        callback,
        qualifier: 'async_event',
        filter: (int v) => v % 2 == 0,
      );

      expect(ddiEvent.isRegistered(qualifier: 'async_event'), isTrue);

      for (int i = 1; i <= 5; i++) {
        ddiEvent.fire(i, qualifier: 'async_event');
      }

      await Future.delayed(const Duration(milliseconds: 3000));

      expect(count, 2);

      ddiEvent.unsubscribe(callback, qualifier: 'async_event');

      expect(ddiEvent.isRegistered(qualifier: 'async_event'), isFalse);
    });

    test('Subscribe and fireWait event with filter', () async {
      int count = 0;

      void callback(int value) => count++;

      ddiEvent.subscribe(
        callback,
        qualifier: 'async_event',
        filter: (int v) => v % 2 == 0,
      );

      expect(ddiEvent.isRegistered(qualifier: 'async_event'), isTrue);

      for (int i = 1; i <= 5; i++) {
        await ddiEvent.fireWait(i, qualifier: 'async_event');
      }

      expect(count, 2);

      ddiEvent.unsubscribe(callback, qualifier: 'async_event');

      expect(ddiEvent.isRegistered(qualifier: 'async_event'), isFalse);
    });

    test('Subscribe future and fireWait event with filter', () async {
      int count = 0;

      void callback(int value) async {
        await Future.delayed(Duration(milliseconds: (1000 / value).round()));
        count++;
      }

      ddiEvent.subscribe(
        callback,
        qualifier: 'async_event',
        filter: (int v) => v % 2 == 0,
      );

      expect(ddiEvent.isRegistered(qualifier: 'async_event'), isTrue);

      for (int i = 1; i <= 5; i++) {
        await ddiEvent.fireWait(i, qualifier: 'async_event');
      }

      await Future.delayed(const Duration(milliseconds: 1500));

      expect(count, 2);

      ddiEvent.unsubscribe(callback, qualifier: 'async_event');

      expect(ddiEvent.isRegistered(qualifier: 'async_event'), isFalse);
    });

    test('Subscribe event with async filter', () async {
      int count = 0;

      void callback(int value) => count++;

      ddiEvent.subscribeAsync(
        callback,
        qualifier: 'async_event',
        filter: (int v) async {
          await Future.delayed(const Duration(milliseconds: 100));
          return v % 2 == 0;
        },
      );

      expect(ddiEvent.isRegistered(qualifier: 'async_event'), isTrue);

      for (int i = 1; i <= 5; i++) {
        ddiEvent.fire(i, qualifier: 'async_event');
      }

      await Future.delayed(const Duration(milliseconds: 1500));

      expect(count, 2);

      ddiEvent.unsubscribe(callback, qualifier: 'async_event');

      expect(ddiEvent.isRegistered(qualifier: 'async_event'), isFalse);
    });

    test('Subscribe future event with async filter', () async {
      int count = 0;

      void callback(int value) async {
        await Future.delayed(Duration(milliseconds: (1000 / value).round()));
        count++;
      }

      ddiEvent.subscribeAsync(
        callback,
        qualifier: 'async_event',
        filter: (int v) async {
          await Future.delayed(const Duration(milliseconds: 100));
          return v % 2 == 0;
        },
      );

      expect(ddiEvent.isRegistered(qualifier: 'async_event'), isTrue);

      for (int i = 1; i <= 5; i++) {
        ddiEvent.fire(i, qualifier: 'async_event');
      }

      await Future.delayed(const Duration(milliseconds: 3000));

      expect(count, 2);

      ddiEvent.unsubscribe(callback, qualifier: 'async_event');

      expect(ddiEvent.isRegistered(qualifier: 'async_event'), isFalse);
    });

    test('Subscribe and fireWait event with async filter', () async {
      int count = 0;

      void callback(int value) => count++;

      ddiEvent.subscribeAsync(
        callback,
        qualifier: 'async_event',
        filter: (int v) async {
          await Future.delayed(const Duration(milliseconds: 100));
          return v % 2 == 0;
        },
      );

      expect(ddiEvent.isRegistered(qualifier: 'async_event'), isTrue);

      for (int i = 1; i <= 5; i++) {
        await ddiEvent.fireWait(i, qualifier: 'async_event');
      }

      expect(count, 2);

      ddiEvent.unsubscribe(callback, qualifier: 'async_event');

      expect(ddiEvent.isRegistered(qualifier: 'async_event'), isFalse);
    });

    test('Subscribe future and fireWait event with async filter', () async {
      int count = 0;

      void callback(int value) async {
        await Future.delayed(Duration(milliseconds: (1000 / value).round()));
        count++;
      }

      ddiEvent.subscribeAsync(
        callback,
        qualifier: 'async_event',
        filter: (int v) async {
          await Future.delayed(const Duration(milliseconds: 100));
          return v % 2 == 0;
        },
      );

      expect(ddiEvent.isRegistered(qualifier: 'async_event'), isTrue);

      for (int i = 1; i <= 5; i++) {
        await ddiEvent.fireWait(i, qualifier: 'async_event');
      }

      expect(count, 2);

      ddiEvent.unsubscribe(callback, qualifier: 'async_event');

      expect(ddiEvent.isRegistered(qualifier: 'async_event'), isFalse);
    });

    test('Subscribe future and fireWait event with async filter and lock',
        () async {
      int count = 0;

      void callback(int value) async {
        await Future.delayed(Duration(milliseconds: (1000 / value).round()));
        count++;
      }

      ddiEvent.subscribeAsync(
        callback,
        qualifier: 'async_event',
        lock: true,
        filter: (int v) async {
          await Future.delayed(const Duration(milliseconds: 100));
          return v % 2 == 0;
        },
      );

      expect(ddiEvent.isRegistered(qualifier: 'async_event'), isTrue);

      for (int i = 1; i <= 5; i++) {
        await ddiEvent.fireWait(i, qualifier: 'async_event');
      }

      expect(count, 2);

      ddiEvent.unsubscribe(callback, qualifier: 'async_event');

      expect(ddiEvent.isRegistered(qualifier: 'async_event'), isFalse);
    });

    test('Subscribe future event with async filter and lock', () async {
      int count = 0;

      void callback(int value) async {
        await Future.delayed(Duration(milliseconds: (1000 / value).round()));
        count++;
      }

      ddiEvent.subscribeAsync(
        callback,
        qualifier: 'async_event',
        lock: true,
        filter: (int v) async {
          await Future.delayed(const Duration(milliseconds: 100));
          return v % 2 == 0;
        },
      );

      expect(ddiEvent.isRegistered(qualifier: 'async_event'), isTrue);

      for (int i = 1; i <= 5; i++) {
        ddiEvent.fire(i, qualifier: 'async_event');
      }

      await Future.delayed(const Duration(milliseconds: 3000));

      expect(count, 2);

      ddiEvent.unsubscribe(callback, qualifier: 'async_event');

      expect(ddiEvent.isRegistered(qualifier: 'async_event'), isFalse);
    });
  });
}
