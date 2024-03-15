import 'dart:async';

import 'package:dart_ddi/dart_ddi.dart';
import 'package:dart_ddi/src/exception/stream_not_found.dart';
import 'package:test/test.dart';

void streamTest() {
  group('DDIStream Tests', () {
    late DDIStream ddiStream;

    setUp(() {
      ddiStream = DDIStream.instance;
    });

    test('Subscribe and Fire', () async {
      final completer = Completer<String>();
      const testValue = 'TestValue';

      void callback(String value) {
        completer.complete(value);
      }

      ddiStream.subscribe<String>(
        callback: callback,
      );

      ddiStream.fire<String>(
        value: testValue,
      );

      await expectLater(completer.future, completion(testValue));

      ddiStream.close<String>();
    });

    test('Subscribe and Close', () async {
      final completer = Completer<String>();

      void callback(String value) {
        completer.complete(value);
      }

      ddiStream.subscribe<String>(
        callback: callback,
      );

      ddiStream.close<String>();

      await expectLater(completer.future, doesNotComplete);
    });

    test('Unsubscribe After Fire', () async {
      final completer = Completer<String>();

      void callback(String value) {
        completer.complete(value);
      }

      ddiStream.subscribe<String>(
        callback: callback,
        unsubscribeAfterFire: true,
      );

      ddiStream.fire<String>(
        value: 'TestValue',
      );

      await expectLater(completer.future, completion('TestValue'));

      await expectLater(
          () => ddiStream.fire<String>(
                value: 'AnotherValue',
              ),
          throwsA(isA<StreamNotFoundException>()));
    });
    test('Subscribe with Qualifier', () async {
      final completer = Completer<String>();
      const testValue = 'TestValue';
      const qualifier = 'TestQualifier';

      void callback(String value) {
        completer.complete(value);
      }

      ddiStream.subscribe(
        callback: callback,
        qualifier: qualifier,
      );

      ddiStream.fire<String>(
        value: testValue,
        qualifier: qualifier,
      );

      await expectLater(completer.future, completion(testValue));
      ddiStream.close(qualifier: qualifier);
    });

    test('Subscribe with RegisterIf', () async {
      final completer = Completer<String>();
      const testValue = 'TestValue';

      void callback(String value) {
        completer.complete(value);
      }

      // Use registerIf to conditionally subscribe.
      ddiStream.subscribe<String>(
        callback: callback,
        registerIf: () => true,
      );

      ddiStream.fire<String>(
        value: testValue,
      );

      await expectLater(completer.future, completion(testValue));
      ddiStream.close<String>();
    });

    test('Subscribe with RegisterIf (Do Not Register)', () async {
      final completer = Completer<String>();

      void callback(String value) {
        completer.complete(value);
      }

      // Use registerIf to conditionally subscribe, but return false.
      ddiStream.subscribe<String>(
        callback: callback,
        registerIf: () => false,
      );

      // Ensure the callback is not called as it was not registered.
      await expectLater(
          () => ddiStream.fire<String>(
                value: 'AnotherValue',
              ),
          throwsA(isA<StreamNotFoundException>()));
      await expectLater(completer.future, doesNotComplete);
    });

    test('Multiple Subscribers with Same Qualifier', () async {
      final completer1 = Completer<String>();
      final completer2 = Completer<String>();
      const testValue = 'TestValue';
      const qualifier = 'TestQualifier';

      void callback1(String value) {
        completer1.complete(value);
      }

      void callback2(String value) {
        completer2.complete(value);
      }

      ddiStream.subscribe<String>(
        callback: callback1,
        qualifier: qualifier,
      );

      ddiStream.subscribe<String>(
        callback: callback2,
        qualifier: qualifier,
      );

      ddiStream.fire<String>(
        value: testValue,
        qualifier: qualifier,
      );

      await expectLater(completer1.future, completion(testValue));
      await expectLater(completer2.future, completion(testValue));
      ddiStream.close(qualifier: qualifier);
    });

    test('Subscribe and Unsubscribe', () async {
      final completer = Completer<String>();
      const testValue = 'TestValue';

      void callback(String value) {
        completer.complete(value);
      }

      ddiStream.subscribe<String>(
        callback: callback,
      );

      ddiStream.fire<String>(
        value: testValue,
      );

      //The close methos doesn't cancel a event already fire
      ddiStream.close<String>();

      await expectLater(completer.future, completion(testValue));
    });

    test('Multiple Subscribers with Different Qualifiers', () async {
      final completer1 = Completer<String>();
      final completer2 = Completer<String>();
      const testValue = 'TestValue';
      const qualifier1 = 'Qualifier1';
      const qualifier2 = 'Qualifier2';

      void callback1(String value) {
        completer1.complete(value);
      }

      void callback2(String value) {
        completer2.complete(value);
      }

      ddiStream.subscribe<String>(
        callback: callback1,
        qualifier: qualifier1,
      );

      ddiStream.subscribe<String>(
        callback: callback2,
        qualifier: qualifier2,
      );

      ddiStream.fire<String>(
        value: testValue,
        qualifier: qualifier1,
      );

      // Apenas completer1 deve ser concluído.
      await expectLater(completer1.future, completion(testValue));
      await expectLater(completer2.future, doesNotComplete);
    });

    test('Subscribe and Fire with Multiple Values', () async {
      final completer = Completer<List<String>>();
      final testValues = ['TestValue1', 'TestValue2'];
      final resultList = <String>[];

      void callback(String value) {
        resultList.add(value);
        if (resultList.length == testValues.length) {
          completer.complete(resultList);
        }
      }

      ddiStream.subscribe<String>(
        callback: callback,
      );

      for (final value in testValues) {
        ddiStream.fire<String>(
          value: value,
        );
      }

      // Garanta que todos os valores sejam recebidos no callback.
      await expectLater(completer.future, completion(testValues));
    });

    test('Close Specific Stream', () async {
      final completer = Completer<String>();

      void callback(String value) {
        completer.complete(value);
      }

      ddiStream.subscribe<String>(
        callback: callback,
      );

      ddiStream.close<String>();

      await expectLater(completer.future, doesNotComplete);
    });

    test('Close Specific Stream with Qualifier', () async {
      final completer = Completer<String>();
      const qualifier = 'TestQualifier';

      void callback(String value) {
        completer.complete(value);
      }

      ddiStream.subscribe<String>(
        callback: callback,
        qualifier: qualifier,
      );

      ddiStream.close<String>(
        qualifier: qualifier,
      );

      await expectLater(completer.future, doesNotComplete);
    });

    test('Subscribe and Fire with Different Types', () async {
      final completer = Completer<int>();
      const testValue = 42;

      void callback(int value) {
        completer.complete(value);
      }

      ddiStream.subscribe<int>(
        callback: callback,
      );

      ddiStream.fire<int>(
        value: testValue,
      );

      await expectLater(completer.future, completion(testValue));
    });
  });
}
