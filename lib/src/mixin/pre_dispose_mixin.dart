import 'dart:async';

/// Executes before the instance is disposed.
mixin PreDispose {
  FutureOr<void> onPreDispose();
}
