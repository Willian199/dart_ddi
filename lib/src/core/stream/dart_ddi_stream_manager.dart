part of 'dart_ddi_stream.dart';

final class _DDIStreamManager implements DDIStream {
  final Map<Object, DDIStreamCore<Object>> _streamMap = {};

  @override
  void close<StreamTypeT extends Object>({Object? qualifier}) {
    final Object effectiveQualifierName = qualifier ?? StreamTypeT;

    if (_streamMap[effectiveQualifierName] case final str?) {
      str.close();

      _streamMap.remove(effectiveQualifierName);
    } else {
      throw StreamNotFound(effectiveQualifierName.toString());
    }
  }

  @override
  void fire<StreamTypeT extends Object>({
    required StreamTypeT value,
    Object? qualifier,
  }) {
    _getStream<StreamTypeT>(qualifier: qualifier).fire(value);
  }

  @override
  void subscribe<StreamTypeT extends Object>({
    required void Function(StreamTypeT) callback,
    Object? qualifier,
    bool Function()? registerIf,
    bool unsubscribeAfterFire = false,
  }) {
    final Object effectiveQualifierName = qualifier ?? StreamTypeT;

    if (!_streamMap.containsKey(effectiveQualifierName)) {
      _streamMap[effectiveQualifierName] = DDIStreamCore<StreamTypeT>();
    }

    (_streamMap[effectiveQualifierName] as DDIStreamCore<StreamTypeT>)
        .subscribe(
      callback,
      registerIf: registerIf,
      unsubscribeAfterFire: unsubscribeAfterFire,
      qualifier: qualifier,
    );
  }

  @override
  Stream<StreamTypeT> getStream<StreamTypeT extends Object>({
    Object? qualifier,
  }) {
    return _getStream<StreamTypeT>(qualifier: qualifier).getStream();
  }

  DDIStreamCore<StreamTypeT> _getStream<StreamTypeT extends Object>({
    Object? qualifier,
  }) {
    final Object effectiveQualifierName = qualifier ?? StreamTypeT;

    final DDIStreamCore? stream = _streamMap[effectiveQualifierName];
    if (stream == null) {
      throw StreamNotFound(effectiveQualifierName.toString());
    }

    return stream as DDIStreamCore<StreamTypeT>;
  }
}
