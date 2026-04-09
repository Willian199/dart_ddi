import 'dart:async';

import 'package:dart_ddi/dart_ddi.dart';

class AsyncDisposableTarget with PreDispose {
  static int preDisposeCalls = 0;

  @override
  Future<void> onPreDispose() async {
    await Future<void>.delayed(const Duration(milliseconds: 1));
    preDisposeCalls++;
  }
}

class AsyncDisposableOther with PreDispose {
  static int preDisposeCalls = 0;

  @override
  Future<void> onPreDispose() async {
    await Future<void>.delayed(const Duration(milliseconds: 1));
    preDisposeCalls++;
  }
}

class AsyncDestroyTarget with PreDestroy {
  static int preDestroyCalls = 0;

  @override
  Future<void> onPreDestroy() async {
    await Future<void>.delayed(const Duration(milliseconds: 1));
    preDestroyCalls++;
  }
}

class AsyncDestroyOther with PreDestroy {
  static int preDestroyCalls = 0;

  @override
  Future<void> onPreDestroy() async {
    await Future<void>.delayed(const Duration(milliseconds: 1));
    preDestroyCalls++;
  }
}

class ParentWithoutLifecycle {}

class SlowAsyncDestroyChild with PreDestroy {
  static int preDestroyCalls = 0;
  static Completer<void>? gate;

  @override
  Future<void> onPreDestroy() async {
    final currentGate = gate;
    if (currentGate != null) {
      await currentGate.future;
    }
    preDestroyCalls++;
  }
}
