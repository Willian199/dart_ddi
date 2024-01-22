import 'package:dart_ddi/dart_ddi.dart';
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

      DDIEvent.instance.fire(1, qualifier: 'testQualifier');

      expect(localValue, 1);
    });

    test('subscribe adds event to the correct type', () {
      int localValue = 0;
      void eventFunction(int value) => localValue += value;

      DDIEvent.instance.subscribe<int>(eventFunction);

      expect(localValue, 0);

      DDIEvent.instance.fire(1);

      expect(localValue, 1);

      DDIEvent.instance.unsubscribe(eventFunction);

      DDIEvent.instance.fire(1);

      expect(localValue, 1);
    });

    test('subscribe adds event and remove after fire', () {
      int localValue = 0;
      void eventFunction(int value) => localValue += value;

      DDIEvent.instance.subscribe<int>(eventFunction, unsubscribeAfterFire: true);

      expect(localValue, 0);

      DDIEvent.instance.fire(1);

      expect(localValue, 1);

      DDIEvent.instance.fire(1);

      expect(localValue, 1);
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

      DDIEvent.instance.subscribe(eventFunction, qualifier: 'testQualifier', allowUnsubscribe: false);

      expect(localValue, 0);

      DDIEvent.instance.fire(1, qualifier: 'testQualifier');

      expect(localValue, 1);

      DDIEvent.instance.unsubscribe(eventFunction, qualifier: 'testQualifier');

      DDIEvent.instance.fire(1, qualifier: 'testQualifier');

      expect(localValue, 2);
    });

    test('subscribe with allowUnsubscribe event, with unsubscribeAfterFire', () {
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

    test('subscribe a isolate event', () {
      int localValue = 0;
      void eventFunction(int value) {
        print('Isolate event');
        localValue += value;
      }

      DDIEvent.instance.subscribeIsolate(eventFunction, qualifier: 'testQualifier');

      expect(localValue, 0);

      DDIEvent.instance.fire(1, qualifier: 'testQualifier');

      expect(localValue, 0);

      DDIEvent.instance.unsubscribe(eventFunction, qualifier: 'testQualifier');
    });
  });
}
