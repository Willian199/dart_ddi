class EventNotFound implements Exception {
  const EventNotFound(this.cause);
  final String cause;

  @override
  String toString() {
    return 'No Event found with Type $cause.';
  }
}
