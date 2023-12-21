/// Abstract class representing an interceptor for the Dart Dependency Injection (DDI) Library.
///
/// Interceptors provide a way to customize the lifecycle and behavior of instances managed by the DDI Library. You can create a subclass of `DDIInterceptor` and override specific methods to add custom logic at different points in the instance's lifecycle.
///
/// **Interceptor Methods:**
/// - `aroundConstruct`: Invoked during the instance creation process. You can customize or replace the creation logic by returning a modified instance.
/// - `aroundGet`: Invoked when retrieving an instance. You can customize the behavior of the retrieved instance before it is returned. If you change the actual instance, the next `get` will apply again. Be aware that this can lead to unexpected functionality.
/// - `aroundDestroy`: Invoked when an instance is being destroyed, allowing you to perform cleanup or additional logic.
/// - `aroundDispose`: Invoked during the disposal of an instance, providing an opportunity for you to release resources or add custom cleanup logic.
///
/// **Default Behavior:**
/// By default, all interceptor methods return the original instance, allowing you to override only the methods needed.
///
/// **Example Usage:**
///
/// ```dart
/// class CustomInterceptor<T> extends DDIInterceptor<T> {
///   @override
///   T aroundConstruct(T instance) {
///     // Logic to customize or replace instance creation.
///     return CustomizedInstance();
///   }
///
///   @override
///   T aroundGet(T instance) {
///     // Logic to customize the behavior of the retrieved instance.
///     return ModifiedInstance(instance);
///   }
///
///   @override
///   void aroundDestroy(T instance) {
///     // Logic to perform cleanup during instance destruction.
///     // This method is optional and can be overridden as needed.
///   }
///
///   @override
///   void aroundDispose(T instance) {
///     // Logic to release resources or perform custom cleanup during instance disposal.
///     // This method is optional and can be overridden as needed.
///   }
/// }
/// ```
///
abstract class DDIInterceptor<T> {
  /// Invoked during the instance creation process. Customize or replace the creation logic by returning a modified instance.
  T aroundConstruct(T instance) {
    return instance;
  }

  /// Invoked when retrieving an instance. Customize the behavior of the retrieved instance before it is returned.
  /// If you change some value, the next time you get this instance, it will apply again.
  T aroundGet(T instance) {
    return instance;
  }

  /// Invoked when an instance is being destroyed, allowing you to perform cleanup or additional logic.
  void aroundDestroy(T instance) {}

  /// Invoked during the disposal of an instance, providing an opportunity for you to release resources or add custom cleanup logic.
  void aroundDispose(T instance) {}
}
