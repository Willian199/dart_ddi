import 'package:dart_ddi/src/core/stream/dart_ddi_stream_core.dart';
import 'package:dart_ddi/src/exception/stream_not_found.dart';

part 'dart_ddi_stream_manager.dart';

/// Shortcut for getting the shared instance of the [DDIStream] class.
/// The [DDIStream] class provides methods for subscribing, closing
/// and dispatching streams with optional qualifiers.
DDIStream ddiStream = DDIStream.instance;

/// [DDIStream] is an abstract class representing a stream.
/// It provides methods for subscribing and unsubscribing to streams
/// and for dispatching streams with optional qualifiers.
abstract final class DDIStream {
  /// Creates the shared instance of the [DDIStream] class.
  static final DDIStream _instance = _DDIStreamManager();

  /// Gets the shared instance of the [DDIStream] class.
  static DDIStream get instance => _instance;

  /// Subscribes to a stream of type [StreamTypeT].
  ///
  /// - `callback`: A callback function to be invoked when the stream emits a value.
  /// - `qualifier`: An optional qualifier to distinguish between different streams of the same type.
  /// - `registerIf`: An optional function to conditionally register the subscription.
  /// - `unsubscribeAfterFire`: If set to true, unsubscribes the callback after it is invoked once.
  void subscribe<StreamTypeT extends Object>({
    required void Function(StreamTypeT) callback,
    Object? qualifier,
    bool Function()? registerIf,
    bool unsubscribeAfterFire = false,
  });

  /// Closes the subscription to a stream of type [StreamTypeT].
  ///
  /// - `qualifier`: An optional qualifier to specify the stream to be closed.
  void close<StreamTypeT extends Object>({Object? qualifier});

  /// Fires a value into the stream of type [StreamTypeT].
  ///
  /// - `value`: The value to be emitted into the stream.
  /// - `qualifier`: An optional qualifier to specify the target stream.
  void fire<StreamTypeT extends Object>({
    required StreamTypeT value,
    Object? qualifier,
  });

  /// Retrieves a stream of type [StreamTypeT].
  /// If the stream is not registered, an exception is thrown.
  ///
  /// - `qualifier`: An optional qualifier to specify the desired stream.
  Stream<StreamTypeT> getStream<StreamTypeT extends Object>(
      {Object? qualifier});

  /// Verify if a stream is already registered.
  ///
  /// - `qualifier`: Optional qualifier name to distinguish between different instances of the same type.
  bool isRegistered<StreamTypeT extends Object>({Object? qualifier});

  /// Create a default stream with type.
  ///
  /// - `qualifier`: Optional qualifier name to distinguish between different instances of the same type.
  Stream<StreamTypeT> getOrCreateStream<StreamTypeT extends Object>(
      {Object? qualifier});
}
