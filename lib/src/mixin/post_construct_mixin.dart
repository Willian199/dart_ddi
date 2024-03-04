import 'dart:async';

/// Executes after the instance is constructed.
mixin PostConstruct {
  FutureOr<void> onPostConstruct();
}
