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

    group('Context Exceptions', () {
      test('ContextNotFoundException should keep context and message', () {
        const exception = ContextNotFoundException('ctx-missing');
        expect(exception.context, equals('ctx-missing'));
        expect(exception.toString(),
            equals('Context "ctx-missing" was not found.'));
      });

      test('DuplicatedContextException should keep context and message', () {
        const exception = DuplicatedContextException('ctx-dup');
        expect(exception.context, equals('ctx-dup'));
        expect(
          exception.toString(),
          equals('Context "ctx-dup" is already registered.'),
        );
      });

      test('ContextFrozenException should keep data and message', () {
        const exception = ContextFrozenException(
          context: 'ctx-frozen',
          operation: 'register',
        );
        expect(exception.context, equals('ctx-frozen'));
        expect(exception.operation, equals('register'));
        expect(
          exception.toString(),
          equals(
            'Context "ctx-frozen" is frozen. Operation "register" is not allowed.',
          ),
        );
      });

      test('ContextBeingDestroyedException should keep data and message', () {
        const exception = ContextBeingDestroyedException(
          context: 'ctx-destroying',
          operation: 'createContext',
        );
        expect(exception.context, equals('ctx-destroying'));
        expect(exception.operation, equals('createContext'));
        expect(
          exception.toString(),
          equals(
            'Context "ctx-destroying" is being destroyed. Operation "createContext" is not allowed.',
          ),
        );
      });

      test('ContextDestroyBlockedException should keep data and message', () {
        const exception = ContextDestroyBlockedException('ctx-locked');
        expect(exception.context, equals('ctx-locked'));
        expect(
          exception.toString(),
          equals('Context "ctx-locked" contains non-destroyable factories.'),
        );
      });

      test('ContextDestroyIncompleteException should keep data and message',
          () {
        const exception = ContextDestroyIncompleteException('ctx-incomplete');
        expect(exception.context, equals('ctx-incomplete'));
        expect(
          exception.toString(),
          equals(
            'Context "ctx-incomplete" still contains factories after destroy operation.',
          ),
        );
      });
    });
  });
}
