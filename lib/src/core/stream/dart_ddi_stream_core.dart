import 'dart:async';

import 'package:dart_ddi/src/data/stream_subscription.dart';

class DDIStreamCore<StreamTypeT extends Object> {
  final StreamController<StreamTypeT> _streamController =
      StreamController<StreamTypeT>.broadcast();

  void subscribe(
    void Function(StreamTypeT) callback, {
    bool Function()? registerIf,
    bool canUnsubscribe = true,
    bool unsubscribeAfterFirst = false,
  }) {
    if (registerIf?.call() ?? true) {
      final SubscriptionData<StreamTypeT> subscriptionData = SubscriptionData(
        callback: callback,
        unsubscribeAfterFirst: unsubscribeAfterFirst,
      );

      void run(StreamTypeT value) {
        subscriptionData.callback(value);

        if (unsubscribeAfterFirst && canUnsubscribe) {
          _unsubscribe(subscriptionData);
        }
      }

      subscriptionData.subscription = _streamController.stream.listen(run);
    }
  }

  void _unsubscribe(SubscriptionData<StreamTypeT> subscriptionData) {
    subscriptionData.subscription?.cancel();
  }

  void fire(StreamTypeT value) {
    _streamController.add(value);
  }

  void dispose() {
    _streamController.close();
  }
}
