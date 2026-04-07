import 'package:dart_ddi/dart_ddi.dart';

class WeakDisposeService with PreDispose {
  static bool preDisposeCalled = false;

  @override
  Future<void> onPreDispose() async {
    preDisposeCalled = true;
  }
}
