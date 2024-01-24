part of 'dart_ddi_stream.dart';

class _DDIStreamManager implements DDIStream {
  final Map<Object, DDIStreamCore<Object>> _streamMap = {};

  @override
  void disposeStream<StreamTypeT extends Object>({Object? qualifier}) {
    if (_streamMap.containsKey(qualifier)) {
      _streamMap[qualifier]?.close();

      _streamMap.remove(qualifier);
    }
  }

  @override
  void fire<StreamTypeT extends Object>(
      {required StreamTypeT value, Object? qualifier}) {
    final Object effectiveQualifierName = qualifier ?? StreamTypeT;

    final DDIStreamCore? stream = _streamMap[effectiveQualifierName];
    if (stream == null) {
      throw StreamNotFound(effectiveQualifierName.toString());
    }

    stream.fire(value);
  }

  @override
  void subscribe<StreamTypeT extends Object>({
    required void Function(StreamTypeT p1) callback,
    Object? qualifier,
    bool Function()? registerIf,
    bool canUnsubscribe = true,
    bool unsubscribeAfterFirst = false,
  }) {
    final Object effectiveQualifierName = qualifier ?? StreamTypeT;

    if (!_streamMap.containsKey(effectiveQualifierName)) {
      _streamMap[effectiveQualifierName] = DDIStreamCore<StreamTypeT>();
    }

    (_streamMap[effectiveQualifierName] as DDIStreamCore<StreamTypeT>)
        .subscribe(
      callback,
      registerIf: registerIf,
      canUnsubscribe: canUnsubscribe,
      unsubscribeAfterFirst: unsubscribeAfterFirst,
    );
  }
}
