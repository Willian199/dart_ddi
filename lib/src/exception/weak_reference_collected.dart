/// Exception thrown when a weak reference instance was garbage collected.
///
/// This exception is thrown when using `useWeakReference: true` in Application scope
/// and the instance was collected by the garbage collector. The instance will be
/// automatically re-created on the next `get` or `getAsync` call.
///
/// This exception is used internally to signal that the instance needs to be re-created.
/// It should not be caught by user code, as the framework handles it automatically.
class WeakReferenceCollectedException implements Exception {
  const WeakReferenceCollectedException(this.type);
  final String type;

  @override
  String toString() {
    return 'Instance with Type $type was garbage collected. It will be re-created automatically.';
  }
}
