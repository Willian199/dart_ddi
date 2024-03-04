import 'package:dart_ddi/dart_ddi.dart';

/// Helper to make to easy to Inject one instance
mixin DDIController<ControllerT extends Object> {
  final ControllerT? controller = DDI.instance.get<ControllerT>();
}

/// Helper to make to easy to Inject one instance
mixin DDIControllerAsync<ControllerT extends Object> {
  final Future<ControllerT>? controller = DDI.instance.getAsync<ControllerT>();
}
