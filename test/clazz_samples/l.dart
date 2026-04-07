import 'package:dart_ddi/dart_ddi.dart';

class L with PostConstruct, PreDestroy {
  String value = 'abc';

  @override
  void onPostConstruct() {
    value = 'abcd';
  }

  @override
  void onPreDestroy() {
    print("No idea how to test bro");
  }
}
