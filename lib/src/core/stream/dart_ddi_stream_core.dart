import 'dart:async';

class DDIStreamCore<StreamTypeT extends Object> {
  final StreamController<StreamTypeT> _streamController =
      StreamController<StreamTypeT>.broadcast();

  void subscribe(
    void Function(StreamTypeT) callback, {
    bool Function()? registerIf,
    bool unsubscribeAfterFire = false,
  }) {
    if (registerIf?.call() ?? true) {
      void run(StreamTypeT value) {
        callback(value);

        if (unsubscribeAfterFire) {
          close();
        }
      }

      _streamController.stream.listen(run);
    }
  }

  void fire(StreamTypeT value) {
    _streamController.add(value);
  }

  void close() {
    _streamController.close();
  }
}
