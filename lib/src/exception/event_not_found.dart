/// [EventNotFoundException] is an exception that is thrown when tried to access an event that doesn't exist.
class EventNotFoundException implements Exception {
  const EventNotFoundException(this.cause);
  final String cause;

  @override
  String toString() {
    return 'No Event found with Type $cause.';
  }
}
