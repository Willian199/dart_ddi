/// Enum representing the different states a bean can be in during its lifecycle.
///
/// This enum tracks the current state of a bean from registration through creation,
/// usage, and eventual disposal or destruction. Understanding these states is important
/// for debugging and understanding the lifecycle of beans in the DDI container.
enum BeanStateEnum {
  /// Initial state when a bean is first registered but not yet processed.
  /// This is the default state for newly registered beans.
  none,

  /// State when a bean is being registered in the container.
  /// This occurs during the registration process, before the bean is ready for use.
  beingRegistered,

  /// State when a bean is registered in the container.
  registered,

  /// State when a bean is being created for the first time.
  /// This occurs during the instance creation process, which may involve
  /// calling interceptors, applying decorators, and running lifecycle hooks.
  beingCreated,

  /// State when a bean has been successfully created and is ready for use.
  /// This is the normal operational state for beans that are available for injection.
  created,

  /// State when a bean is being disposed of.
  /// This occurs when the bean's dispose method is called, which may involve
  /// calling interceptors and running cleanup logic.
  beingDisposed,

  /// State when a bean has been successfully disposed of.
  /// The bean is no longer available for injection but may still exist in memory.
  disposed,

  /// State when a bean is being destroyed.
  /// This occurs when the bean's destroy method is called, which may involve
  /// calling interceptors and running destruction logic.
  beingDestroyed,

  /// State when a bean has been successfully destroyed.
  /// The bean is completely removed from the container and should no longer be used.
  destroyed,
}
