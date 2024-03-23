/// [EventNotAllowedException] is an exception that is thrown when tried to register an event that is not allowed.
class EventNotAllowedException implements Exception {
  const EventNotAllowedException(this.cause);
  final String cause;

  @override
  String toString() {
    return '$cause ';
  }
}
