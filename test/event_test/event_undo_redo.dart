import 'package:dart_ddi/dart_ddi.dart';
import 'package:test/test.dart';

void eventUndoRedoTest() {
  tearDown(() {
    ddiEvent.clearHistory<int>();
    ddiEvent.clearHistory<String>();
  });

  group('DDIEvent Undo/Redo Tests', () {
    test('Undo moves last value from undoStack to redoStack', () async {
      // Registrar e disparar eventos para criar um histórico
      ddiEvent.fire<int>(1);
      ddiEvent.fire<int>(2);
      ddiEvent.fire<int>(3);

      // Executar undo
      await ddiEvent.undo<int>();

      // Validar se o valor foi movido para a pilha de redo
      expect(ddiEvent.getValue<int>(), 2);

      ddiEvent.clearHistory<int>();

      expect(ddiEvent.isRegistered<int>(), false);
    });

    test('Redo moves last value from redoStack to undoStack', () async {
      // Registrar e disparar eventos para criar um histórico
      ddiEvent.fire<int>(1);
      ddiEvent.fire<int>(2);
      ddiEvent.fire<int>(3);

      // Executar undo seguido de redo
      await ddiEvent.undo<int>();
      await ddiEvent.redo<int>();

      // Validar se o valor foi movido de volta para a pilha de undo
      expect(ddiEvent.getValue<int>(), 3);

      ddiEvent.clearHistory<int>();

      expect(ddiEvent.isRegistered<int>(), false);
    });

    test('getValue retrieves the last value from undoStack', () {
      // Registrar e disparar eventos para criar um histórico
      ddiEvent.fire<int>(1);
      ddiEvent.fire<int>(2);
      ddiEvent.fire<int>(3);

      // Validar o último valor da pilha de undo
      final value = ddiEvent.getValue<int>();
      expect(value, 3);

      ddiEvent.clearHistory<int>();

      expect(ddiEvent.isRegistered<int>(), false);
    });

    test('getValue returns null when undoStack is empty', () {
      // Validar que getValue retorna null quando não há histórico
      final value = ddiEvent.getValue<int>();
      expect(value, isNull);
      expect(ddiEvent.isRegistered<int>(), false);
    });

    test('Undo on empty history does nothing', () async {
      await ddiEvent.undo<int>();

      final value = ddiEvent.getValue<int>();
      expect(value, isNull);
      ddiEvent.clearHistory<int>();
      expect(ddiEvent.isRegistered<int>(), false);
    });

    test('Redo on empty redo stack does nothing', () async {
      ddiEvent.fire<int>(1);
      await ddiEvent.redo<int>();

      final value = ddiEvent.getValue<int>();
      expect(value, 1);
      ddiEvent.clearHistory<int>();
      expect(ddiEvent.isRegistered<int>(), false);
    });

    test('Multiple undo calls work as expected', () async {
      ddiEvent.fire<int>(1);
      ddiEvent.fire<int>(2);
      ddiEvent.fire<int>(3);

      await ddiEvent.undo<int>();
      expect(ddiEvent.getValue<int>(), 2);

      await ddiEvent.undo<int>();
      expect(ddiEvent.getValue<int>(), 1);

      await ddiEvent.undo<int>();
      expect(ddiEvent.getValue<int>(), isNull);

      ddiEvent.clearHistory<int>();

      expect(ddiEvent.isRegistered<int>(), false);
    });

    test('Undo and redo sequence restores values correctly', () async {
      ddiEvent.fire<int>(1);
      ddiEvent.fire<int>(2);
      ddiEvent.fire<int>(3);

      await ddiEvent.undo<int>();
      expect(ddiEvent.getValue<int>(), 2);

      await ddiEvent.undo<int>();
      expect(ddiEvent.getValue<int>(), 1);

      await ddiEvent.redo<int>();
      expect(ddiEvent.getValue<int>(), 2);

      await ddiEvent.redo<int>();
      expect(ddiEvent.getValue<int>(), 3);

      ddiEvent.clearHistory<int>();
      expect(ddiEvent.isRegistered<int>(), false);
    });

    test('Redo stack is cleared after a new value is fired', () async {
      ddiEvent.fire<int>(1);
      ddiEvent.fire<int>(2);

      await ddiEvent.undo<int>();
      expect(ddiEvent.getValue<int>(), 1);

      ddiEvent.fire<int>(3);
      expect(ddiEvent.getValue<int>(), 3);

      await ddiEvent.redo<int>();
      expect(ddiEvent.getValue<int>(), 3); // Redo stack should be empty

      expect(ddiEvent.isRegistered<int>(), false);
      ddiEvent.clearHistory<int>();
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

      ddiEvent.fire<int>(42);
      await ddiEvent.undo<int>();
      expect(ddiEvent.getValue<int>(), isNull);

      expect(ddiEvent.isRegistered<int>(), false);
      ddiEvent.clearHistory<int>();
    });

    test('Filter allows firing only matching values', () async {
      int valueE = 0;

      void event(int value) => valueE = value;
      // Registrar um evento com filtro que aceita apenas números pares
      await ddiEvent.subscribe<int>(
        event,
        filter: (value) => value % 2 == 0,
      );

      ddiEvent.fire<int>(1);
      expect(ddiEvent.getValue<int>(), 1);
      expect(valueE, 0);

      ddiEvent.fire<int>(2);
      expect(ddiEvent.getValue<int>(), valueE);
      expect(valueE, 2);

      expect(ddiEvent.isRegistered<int>(), true);
      ddiEvent.unsubscribe<int>(event);
      expect(ddiEvent.isRegistered<int>(), false);

      ddiEvent.clearHistory<int>();
      expect(ddiEvent.getValue<int>(), isNull);
    });

    test('Multiple qualifiers maintain separate histories', () async {
      // Disparar eventos com qualificadores diferentes
      ddiEvent.fire<int>(1, qualifier: 'qualifier1');
      ddiEvent.fire<int>(2, qualifier: 'qualifier2');

      expect(ddiEvent.getValue<int>(qualifier: 'qualifier1'), 1);
      expect(ddiEvent.getValue<int>(qualifier: 'qualifier2'), 2);

      await ddiEvent.undo<int>(qualifier: 'qualifier1');
      expect(ddiEvent.getValue<int>(qualifier: 'qualifier1'), isNull);
      expect(ddiEvent.getValue<int>(qualifier: 'qualifier2'), 2);

      ddiEvent.clearHistory<int>(qualifier: 'qualifier1');
      ddiEvent.clearHistory<int>(qualifier: 'qualifier2');

      expect(ddiEvent.isRegistered<String>(qualifier: 'qualifier1'), false);
      expect(ddiEvent.isRegistered<String>(qualifier: 'qualifier2'), false);
    });

    test('Undo clears redo stack after firing a new event', () async {
      ddiEvent.fire<int>(1);
      ddiEvent.fire<int>(2);

      await ddiEvent.undo<int>();
      expect(ddiEvent.getValue<int>(), 1);

      ddiEvent.fire<int>(3);
      await ddiEvent.redo<int>();
      expect(ddiEvent.getValue<int>(),
          3); // Redo não deve funcionar após novo fire

      expect(ddiEvent.isRegistered<int>(), false);
      ddiEvent.clearHistory<int>();
    });

    test('Expiration duration removes event after a delay', () async {
      double valueE = 0;
      void event(double value) => valueE = value;
      // Registrar evento com duração de 1 segundo
      await ddiEvent.subscribe<double>(
        event,
        expirationDuration: const Duration(seconds: 1),
      );

      ddiEvent.fire<double>(42);
      expect(ddiEvent.getValue<double>(), valueE);

      // Esperar 1 segundos e verificar se o evento foi removido
      await Future.delayed(const Duration(seconds: 1));
      expect(ddiEvent.getValue<double>(), isNull);

      expect(ddiEvent.isRegistered<int>(), false);
      ddiEvent.clearHistory<double>();
    });

    test('AutoRun fires default value automatically', () async {
      int valueE = 0;

      void event(int value) => valueE = value;
      // Registrar um evento com autoRun e valor padrão
      await ddiEvent.subscribe<int>(
        event,
        autoRun: true,
        defaultValue: 99,
        unsubscribeAfterFire: true,
      );

      expect(valueE, 99);
      expect(ddiEvent.getValue<int>(), isNull);

      expect(ddiEvent.isRegistered<int>(), false);
      ddiEvent.clearHistory<int>();
    });

    test('Retry attempts fire repeatedly until maxRetry is reached', () async {
      // Registrar um evento com intervalo de retry
      int retryCount = 0;
      await ddiEvent.subscribe<int>(
        (value) => retryCount++,
        autoRun: true,
        defaultValue: 42,
        retryInterval: const Duration(milliseconds: 100),
        maxRetry: 3,
      );

      await Future.delayed(const Duration(milliseconds: 400));
      expect(retryCount, 3);

      ddiEvent.clearHistory<int>();

      expect(ddiEvent.isRegistered<int>(), false);
    });

    test('Firing events with different types does not cause conflicts', () {
      ddiEvent.fire<int>(10);
      ddiEvent.fire<String>("Hello");

      expect(ddiEvent.getValue<int>(), 10);
      expect(ddiEvent.getValue<String>(), "Hello");

      ddiEvent.clearHistory<int>();
      ddiEvent.clearHistory<String>();

      expect(ddiEvent.isRegistered<int>(), false);
      expect(ddiEvent.isRegistered<String>(), false);
    });

    test('Unsubscribe prevents future executions', () async {
      int executionCount = 0;

      void callback(int value) => executionCount++;
      await ddiEvent.subscribe<int>(callback);

      ddiEvent.fire<int>(1);
      expect(executionCount, 1);

      ddiEvent.unsubscribe<int>(callback);
      ddiEvent.fire<int>(2);
      expect(executionCount, 1);

      ddiEvent.clearHistory<int>();
      expect(ddiEvent.isRegistered<int>(), false);
    });
  });
}
