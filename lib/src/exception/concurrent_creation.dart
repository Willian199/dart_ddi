/// [ConcurrentCreationException] is an exception that is thrown when the circular detection is found.
class ConcurrentCreationException implements Exception {
  const ConcurrentCreationException(this.cause);
  final String cause;

  @override
  String toString() {
    return "It seems that a Circular Dependency Injection has occurred for Instance Type $cause !!!, or you're attempting to call [getAsync] for the same object in multiple places simultaneously.";
  }
}
