import 'package:dart_ddi/dart_ddi.dart';
import 'package:test/test.dart';

void main() {
  group('Exception Tests', () {
    group('BeanDestroyedException', () {
      test('should create exception with cause', () {
        const exception = BeanDestroyedException('TestService');
        expect(exception.cause, 'TestService');
      });

      test('should return correct string representation', () {
        const exception = BeanDestroyedException('TestService');
        expect(
          exception.toString(),
          'The Instance with Type TestService is in destroyed state and can\'t be used.',
        );
      });
    });

    group('BeanNotFoundException', () {
      test('should create exception with cause', () {
        const exception = BeanNotFoundException('TestService');
        expect(exception.cause, 'TestService');
      });

      test('should return correct string representation', () {
        const exception = BeanNotFoundException('TestService');
        expect(
            exception.toString(), 'No Instance found with Type TestService.');
      });
    });

    group('BeanNotReadyException', () {
      test('should create exception with cause', () {
        const exception = BeanNotReadyException('TestService');
        expect(exception.cause, 'TestService');
      });

      test('should return correct string representation', () {
        const exception = BeanNotReadyException('TestService');
        expect(
          exception.toString(),
          'Instance with Type TestService was found, but is not ready yet.',
        );
      });
    });

    group('ConcurrentCreationException', () {
      test('should create exception with cause', () {
        const exception = ConcurrentCreationException('TestService');
        expect(exception.cause, 'TestService');
      });

      test('should return correct string representation', () {
        const exception = ConcurrentCreationException('TestService');
        expect(
          exception.toString(),
          "It seems that a Circular Dependency Injection has occurred for Instance Type TestService , or you're attempting to call [getAsync] for the same object in multiple places simultaneously.",
        );
      });
    });

    group('FactoryAlreadyCreatedException', () {
      test('should create exception with cause', () {
        const exception = FactoryAlreadyCreatedException('TestService');
        expect(exception.cause, 'TestService');
      });

      test('should return correct string representation', () {
        const exception = FactoryAlreadyCreatedException('TestService');
        expect(
          exception.toString(),
          'The Factory is already created for Type TestService.',
        );
      });
    });

    group('FactoryNotAllowedException', () {
      test('should create exception with cause', () {
        const exception = FactoryNotAllowedException('TestService');
        expect(exception.cause, 'TestService');
      });

      test('should return correct string representation', () {
        const exception = FactoryNotAllowedException('TestService');
        expect(
          exception.toString(),
          'The Factory is not valid for Type TestService.',
        );
      });
    });

    group('FutureNotAcceptException', () {
      test('should create exception', () {
        const exception = FutureNotAcceptException();
        expect(exception, isA<FutureNotAcceptException>());
      });

      test('should return correct string representation', () {
        const exception = FutureNotAcceptException();
        expect(
          exception.toString(),
          'The Future type is not supported. Use getAsync instead.',
        );
      });
    });

    group('MissingDependenciesException', () {
      test('should create exception with message', () {
        const exception = MissingDependenciesException('TestService not found');
        expect(exception.message, 'TestService not found');
      });

      test('should return correct string representation', () {
        const exception = MissingDependenciesException('TestService not found');
        expect(exception.toString(),
            'MissingDependenciesException: TestService not found.');
      });
    });

    group('WeakReferenceCollectedException', () {
      test('should create exception with type', () {
        const exception = WeakReferenceCollectedException('TestService');
        expect(exception.type, 'TestService');
      });

      test('should return correct string representation', () {
        const exception = WeakReferenceCollectedException('TestService');
        expect(
          exception.toString(),
          'Instance with Type TestService was garbage collected. It will be re-created automatically.',
        );
      });
    });
  });
}
