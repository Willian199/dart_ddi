import 'package:dart_ddi/src/core/stream/dart_ddi_stream_core.dart';
import 'package:dart_ddi/src/exception/stream_not_found.dart';

part 'dart_ddi_stream_manager.dart';

abstract class DDIStream {
  /// Creates the shared instance of the [DDIEvent] class.
  static final DDIStream _instance = _DDIStreamManager();

  /// Gets the shared instance of the [DDIEvent] class.
  static DDIStream get instance => _instance;

  void subscribe<T extends Object>({
    required void Function(T) callback,
    Object? qualifier,
    bool Function()? registerIf,
    bool canUnsubscribe = true,
    bool unsubscribeAfterFirst = false,
  });

  void disposeStream<T extends Object>({Object? qualifier});

  void fire<T extends Object>({required T value, Object? qualifier});
}
