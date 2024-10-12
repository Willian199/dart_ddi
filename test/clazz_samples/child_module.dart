import 'package:dart_ddi/dart_ddi.dart';

import 'component.dart';

class ChildModule with DDIModule {
  @override
  void onPostConstruct() {
    registerModule(() => const Component('child'));
  }
}
