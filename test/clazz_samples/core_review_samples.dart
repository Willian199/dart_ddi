import 'dart:async';

import 'package:dart_ddi/dart_ddi.dart';

final class CoreReviewServiceA {}

final class CoreReviewServiceB {}

final class CoreReviewContextService {
  const CoreReviewContextService(this.origin);

  final String origin;
}

final class CoreReviewFailsOncePreDestroy with PreDestroy {
  int calls = 0;

  @override
  void onPreDestroy() {
    calls++;
    if (calls == 1) {
      throw StateError('transient pre-destroy failure');
    }
  }
}

final class CoreReviewFailsOncePreDispose with PreDispose {
  int calls = 0;

  @override
  void onPreDispose() {
    calls++;
    if (calls == 1) {
      throw StateError('transient pre-dispose failure');
    }
  }
}

final class CoreReviewBlockingPreDispose with PreDispose {
  CoreReviewBlockingPreDispose({
    required this.disposeStarted,
    required this.releaseDispose,
  });

  final Completer<void> disposeStarted;
  final Completer<void> releaseDispose;

  @override
  Future<void> onPreDispose() async {
    if (!disposeStarted.isCompleted) {
      disposeStarted.complete();
    }
    await releaseDispose.future;
  }
}
