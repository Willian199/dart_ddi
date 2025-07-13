import 'dart:async';

/// Type alias for a function that returns a Future or bool.
/// Used for conditional registration and other boolean operations that may be async.
typedef FutureOrBool = FutureOr<bool>;

/// Type alias for a callback function that returns a Future or bool.
/// Used for conditional registration scenarios where the condition may be async.
typedef FutureOrBoolCallback = FutureOrBool Function();

/// Type alias for a callback function that returns a bool.
/// Used for synchronous conditional operations.
typedef BoolCallback = bool Function();

/// Type alias for a callback function that returns void.
/// Used for operations that don't return a value.
typedef VoidCallback = void Function();

/// Type alias for a decorator function that takes an instance and returns a modified instance.
/// Used for applying transformations or enhancements to instances.
typedef BeanDecorator<BeanT> = BeanT Function(BeanT);

/// Type alias for a list of decorator functions.
/// Used when multiple decorators need to be applied to an instance.
typedef ListDecorator<BeanT> = List<BeanDecorator<BeanT>>;

/// Type alias for a function that registers a bean and returns a Future or the bean itself.
/// Used for factory functions that create instances, supporting both sync and async creation.
typedef BeanRegister<BeanT> = FutureOr<BeanT> Function();
