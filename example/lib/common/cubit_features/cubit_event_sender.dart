import 'package:dart_ddi/dart_ddi.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CubitSender<State extends Object> extends Cubit<State> {
  CubitSender(super.initialState);

  void fire(State state) {
    debugPrint('emitindo evento $this');

    DDIEvent.instance.fire<State>(state);

    super.emit(state);
  }
}
