/// [Scopes] is a enum that represents the scope of a bean.
///
///
/// Singleton: Only one instance of the bean is created.
/// Application: An instance of the bean is created on the first request.
/// Dependent: An instance of the bean is created for each request.
/// Session: An instance of the bean is created on the first request. Works as a Application scope, but have more ways to destroy.
/// Object: Store a Object as a bean.
enum Scopes { singleton, application, dependent, session, object }
