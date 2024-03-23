import 'package:dart_ddi/dart_ddi.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class CubitListener<State, Listen extends Object>
    extends Cubit<State> {
  CubitListener(super.initialState) {
    //DDIEvent.instance.subscribeAsync<Listen>(onEvent);
    DDIStream.instance.subscribe<Listen>(callback: onEvent);
  }

  void onEvent(Listen listen);

  @override
  Future<void> close() async {
    debugPrint('cubit fechado');
    // DDIEvent.instance.unsubscribe<Listen>(onEvent);
    DDIStream.instance.close<Listen>();

    super.close();
  }
}
