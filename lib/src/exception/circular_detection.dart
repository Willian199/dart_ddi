/// [CircularDetectionException] is an exception that is thrown when the circular detection is found.
class CircularDetectionException implements Exception {
  const CircularDetectionException(this.cause);
  final String cause;

  @override
  String toString() {
    return 'Circular Detection found for Instance Type $cause !!!';
  }
}
