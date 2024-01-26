class CircularDetection implements Exception {
  const CircularDetection(this.cause);
  final String cause;

  @override
  String toString() {
    return 'Circular Detection found for Instance Type $cause !!!';
  }
}
