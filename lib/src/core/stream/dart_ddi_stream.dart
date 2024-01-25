import 'package:dart_ddi/src/core/stream/dart_ddi_stream_core.dart';
import 'package:dart_ddi/src/exception/stream_not_found.dart';

part 'dart_ddi_stream_manager.dart';

abstract final class DDIStream {
  /// Creates the shared instance of the [DDIStream] class.
  static final DDIStream _instance = _DDIStreamManager();

  /// Gets the shared instance of the [DDIStream] class.
  static DDIStream get instance => _instance;

  void subscribe<StreamTypeT extends Object>({
    required void Function(StreamTypeT) callback,
    Object? qualifier,
    bool Function()? registerIf,
    bool unsubscribeAfterFire = false,
  });

  void close<StreamTypeT extends Object>({Object? qualifier});

  void fire<StreamTypeT extends Object>({
    required StreamTypeT value,
    Object? qualifier,
  });

  Stream<StreamTypeT> getStream<StreamTypeT extends Object>(
      {Object? qualifier});
}
