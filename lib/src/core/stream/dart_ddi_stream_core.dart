import 'dart:async';

import 'package:dart_ddi/src/core/stream/dart_ddi_stream.dart';

class DDIStreamCore<StreamTypeT extends Object> {
  final StreamController<StreamTypeT> _streamController =
      StreamController<StreamTypeT>.broadcast();

  void subscribe(
    void Function(StreamTypeT) callback, {
    bool Function()? registerIf,
    bool unsubscribeAfterFire = false,
    Object? qualifier,
  }) {
    if (registerIf?.call() ?? true) {
      _streamController.stream.listen((StreamTypeT value) {
        callback(value);

        if (unsubscribeAfterFire) {
          DDIStream.instance.close<StreamTypeT>(qualifier: qualifier);
        }
      });
    }
  }

  void fire(StreamTypeT value) {
    _streamController.add(value);
  }

  void close() {
    _streamController.close();
  }

  Stream<StreamTypeT> getStream() {
    return _streamController.stream;
  }
}
