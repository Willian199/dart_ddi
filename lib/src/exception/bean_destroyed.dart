/// Exception thrown when trying to use a bean that has been destroyed.
///
/// This exception is thrown when attempting to access a bean that has been completely
/// removed from the DDI container through the `destroy()` method. Once a bean is destroyed,
/// it cannot be retrieved or used anymore.
///
/// **When this exception is thrown:**
/// - When calling `ddi.get<Type>(qualifier: 'qualifier')` for a bean that has been destroyed or in process of being destroyed.
///
class BeanDestroyedException implements Exception {
  const BeanDestroyedException(this.cause);
  final String cause;

  @override
  String toString() {
    return 'The Instance with Type $cause is in destroyed state and can\'t be used.';
  }
}
