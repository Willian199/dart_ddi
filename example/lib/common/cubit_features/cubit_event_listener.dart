import 'package:dart_ddi/dart_ddi.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class CubitListener<State, Listen extends Object>
    extends Cubit<State> {
  CubitListener({required State initialState}) : super(initialState) {
    DDIEvent.instance.subscribeAsync<Listen>(onEvent);
  }

  void onEvent(Listen listen);

  @override
  Future<void> close() async {
    print('cubit fechado');
    DDIEvent.instance.unsubscribe<Listen>(onEvent);

    super.close();
  }
}
