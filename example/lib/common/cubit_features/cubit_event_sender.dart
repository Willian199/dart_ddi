import 'package:dart_ddi/dart_ddi.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CubitSender<State extends Object> extends Cubit<State> {
  CubitSender(super.initialState);

  @override
  void emit(State state, {bool suppresListener = false}) {
    print('emitindo evento ' + this.toString());
    if (!suppresListener) {
      DDIEvent.instance.fire<State>(state);
    }
    super.emit(state);
  }
}
