import 'package:dart_ddi/dart_ddi.dart';

class LPostConstructOnly with PostConstruct {
  String value = 'abc';

  @override
  void onPostConstruct() {
    value = 'abcd';
  }
}
