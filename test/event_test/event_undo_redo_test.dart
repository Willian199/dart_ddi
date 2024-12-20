import 'package:dart_ddi/dart_ddi.dart';
import 'package:test/test.dart';

void eventUndoRedoTest() {
  tearDown(() {
    ddiEvent.clearHistory<num>();
    ddiEvent.clearHistory<String>();
  });

  group('DDIEvent Undo/Redo Tests', () {
    test('Undo moves last value from undoStack to redoStack', () async {
      ddiEvent.fire<num>(1);
      ddiEvent.fire<num>(2);
      ddiEvent.fire<num>(3);

      await ddiEvent.undo<num>();

      expect(ddiEvent.getValue<num>(), 2);

      ddiEvent.clearHistory<num>();

      expect(ddiEvent.isRegistered<num>(), false);
    });

    test('Redo moves last value from redoStack to undoStack', () async {
      ddiEvent.fire<num>(1);
      ddiEvent.fire<num>(2);
      ddiEvent.fire<num>(3);

      await ddiEvent.undo<num>();
      await ddiEvent.redo<num>();

      expect(ddiEvent.getValue<num>(), 3);

      ddiEvent.clearHistory<num>();

      expect(ddiEvent.isRegistered<num>(), false);
    });

    test('getValue retrieves the last value from undoStack', () {
      ddiEvent.fire<num>(1);
      ddiEvent.fire<num>(2);
      ddiEvent.fire<num>(3);

      final value = ddiEvent.getValue<num>();
      expect(value, 3);

      ddiEvent.clearHistory<num>();

      expect(ddiEvent.isRegistered<num>(), false);
    });

    test('getValue returns null when undoStack is empty', () {
      final value = ddiEvent.getValue<num>();
      expect(value, isNull);
      expect(ddiEvent.isRegistered<num>(), false);
    });

    test('Undo on empty history does nothing', () async {
      await ddiEvent.undo<num>();

      final value = ddiEvent.getValue<num>();
      expect(value, isNull);
      ddiEvent.clearHistory<num>();
      expect(ddiEvent.isRegistered<num>(), false);
    });

    test('Redo on empty redo stack does nothing', () async {
      ddiEvent.fire<num>(1);
      await ddiEvent.redo<num>();

      final value = ddiEvent.getValue<num>();
      expect(value, 1);
      ddiEvent.clearHistory<num>();
      expect(ddiEvent.isRegistered<num>(), false);
    });

    test('Multiple undo calls work as expected', () async {
      ddiEvent.fire<num>(1);
      ddiEvent.fire<num>(2);
      ddiEvent.fire<num>(3);

      await ddiEvent.undo<num>();
      expect(ddiEvent.getValue<num>(), 2);

      await ddiEvent.undo<num>();
      expect(ddiEvent.getValue<num>(), 1);

      await ddiEvent.undo<num>();
      expect(ddiEvent.getValue<num>(), isNull);

      ddiEvent.clearHistory<num>();

      expect(ddiEvent.isRegistered<num>(), false);
    });

    test('Undo and redo sequence restores values correctly', () async {
      ddiEvent.fire<num>(1);
      ddiEvent.fire<num>(2);
      ddiEvent.fire<num>(3);

      await ddiEvent.undo<num>();
      expect(ddiEvent.getValue<num>(), 2);

      await ddiEvent.undo<num>();
      expect(ddiEvent.getValue<num>(), 1);

      await ddiEvent.redo<num>();
      expect(ddiEvent.getValue<num>(), 2);

      await ddiEvent.redo<num>();
      expect(ddiEvent.getValue<num>(), 3);

      ddiEvent.clearHistory<num>();
      expect(ddiEvent.isRegistered<num>(), false);
    });

    test('Redo stack is cleared after a new value is fired', () async {
      ddiEvent.fire<num>(1);
      ddiEvent.fire<num>(2);

      await ddiEvent.undo<num>();
      expect(ddiEvent.getValue<num>(), 1);

      ddiEvent.fire<num>(3);
      expect(ddiEvent.getValue<num>(), 3);

      await ddiEvent.redo<num>();
      expect(ddiEvent.getValue<num>(), 3); // Redo stack should be empty

      expect(ddiEvent.isRegistered<num>(), false);
      ddiEvent.clearHistory<num>();
    });

    test('Undo and redo work with varying types', () async {
      ddiEvent.fire<String>("Hello");
      ddiEvent.fire<String>("World");

      await ddiEvent.undo<String>();
      expect(ddiEvent.getValue<String>(), "Hello");

      await ddiEvent.redo<String>();
      expect(ddiEvent.getValue<String>(), "World");

      expect(ddiEvent.isRegistered<String>(), false);
      ddiEvent.clearHistory<String>();

      ddiEvent.fire<num>(42);
      await ddiEvent.undo<num>();
      expect(ddiEvent.getValue<num>(), isNull);

      expect(ddiEvent.isRegistered<num>(), false);
      ddiEvent.clearHistory<num>();
    });

    test('Filter allows firing only matching values', () async {
      num valueE = 0;

      void event(num value) => valueE = value;

      await ddiEvent.subscribe<num>(
        event,
        filter: (value) => value % 2 == 0,
      );

      ddiEvent.fire<num>(1);
      expect(ddiEvent.getValue<num>(), 1);
      expect(valueE, 0);

      ddiEvent.fire<num>(2);
      expect(ddiEvent.getValue<num>(), valueE);
      expect(valueE, 2);

      expect(ddiEvent.isRegistered<num>(), true);
      ddiEvent.unsubscribe<num>(event);
      expect(ddiEvent.isRegistered<num>(), false);

      ddiEvent.clearHistory<num>();
      expect(ddiEvent.getValue<num>(), isNull);
    });

    test('Multiple qualifiers maintain separate histories', () async {
      ddiEvent.fire<num>(1, qualifier: 'qualifier1');
      ddiEvent.fire<num>(2, qualifier: 'qualifier2');

      expect(ddiEvent.getValue<num>(qualifier: 'qualifier1'), 1);
      expect(ddiEvent.getValue<num>(qualifier: 'qualifier2'), 2);

      await ddiEvent.undo<num>(qualifier: 'qualifier1');
      expect(ddiEvent.getValue<num>(qualifier: 'qualifier1'), isNull);
      expect(ddiEvent.getValue<num>(qualifier: 'qualifier2'), 2);

      ddiEvent.clearHistory<num>(qualifier: 'qualifier1');
      ddiEvent.clearHistory<num>(qualifier: 'qualifier2');

      expect(ddiEvent.isRegistered<String>(qualifier: 'qualifier1'), false);
      expect(ddiEvent.isRegistered<String>(qualifier: 'qualifier2'), false);
    });

    test('Undo clears redo stack after firing a new event', () async {
      ddiEvent.fire<num>(1);
      ddiEvent.fire<num>(2);

      await ddiEvent.undo<num>();
      expect(ddiEvent.getValue<num>(), 1);

      ddiEvent.fire<num>(3);
      await ddiEvent.redo<num>();
      expect(ddiEvent.getValue<num>(), 3);

      expect(ddiEvent.isRegistered<num>(), false);
      ddiEvent.clearHistory<num>();
    });

    test('Expiration duration removes event after a delay', () async {
      double valueE = 0;
      void event(double value) => valueE = value;

      await ddiEvent.subscribe<double>(
        event,
        expirationDuration: const Duration(seconds: 1),
      );

      ddiEvent.fire<double>(42);
      expect(ddiEvent.getValue<double>(), valueE);

      await Future.delayed(const Duration(seconds: 1));
      expect(ddiEvent.getValue<double>(), isNull);

      expect(ddiEvent.isRegistered<num>(), false);
      ddiEvent.clearHistory<double>();
    });

    test('AutoRun fires default value automatically', () async {
      num valueE = 0;

      void event(num value) => valueE = value;

      await ddiEvent.subscribe<num>(
        event,
        autoRun: true,
        defaultValue: 99,
        unsubscribeAfterFire: true,
      );

      expect(valueE, 99);
      expect(ddiEvent.getValue<num>(), isNull);

      expect(ddiEvent.isRegistered<num>(), false);
      ddiEvent.clearHistory<num>();
    });

    test('Retry attempts fire repeatedly until maxRetry is reached', () async {
      int retryCount = 0;
      await ddiEvent.subscribe<num>(
        (value) => retryCount++,
        autoRun: true,
        defaultValue: 42,
        retryInterval: const Duration(milliseconds: 100),
        maxRetry: 3,
      );

      await Future.delayed(const Duration(milliseconds: 400));
      expect(retryCount, 3);

      ddiEvent.clearHistory<num>();

      expect(ddiEvent.isRegistered<num>(), false);
    });

    test('Firing events with different types does not cause conflicts', () {
      ddiEvent.fire<num>(10);
      ddiEvent.fire<String>("Hello");

      expect(ddiEvent.getValue<num>(), 10);
      expect(ddiEvent.getValue<String>(), "Hello");

      ddiEvent.clearHistory<num>();
      ddiEvent.clearHistory<String>();

      expect(ddiEvent.isRegistered<num>(), false);
      expect(ddiEvent.isRegistered<String>(), false);
    });

    test('Unsubscribe prevents future executions', () async {
      int executionCount = 0;

      void callback(num value) => executionCount++;
      await ddiEvent.subscribe<num>(callback);

      ddiEvent.fire<num>(1);
      expect(executionCount, 1);

      ddiEvent.unsubscribe<num>(callback);
      ddiEvent.fire<num>(2);
      expect(executionCount, 1);

      ddiEvent.clearHistory<num>();
      expect(ddiEvent.isRegistered<num>(), false);
    });
  });
}
