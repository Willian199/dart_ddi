import 'dart:async';

/// Executes before the instance is destroyed.
mixin PreDestroy {
  FutureOr<void> onPreDestroy();
}
