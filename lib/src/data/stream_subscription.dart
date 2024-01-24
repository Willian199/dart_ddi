import 'dart:async';

class SubscriptionData<T extends Object> {
  SubscriptionData({
    required this.callback,
    required this.unsubscribeAfterFirst,
  });

  final void Function(T) callback;
  final bool unsubscribeAfterFirst;
  StreamSubscription<T>? subscription;
}
