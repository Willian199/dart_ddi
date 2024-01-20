import 'package:dart_ddi/src/features/post_construct.dart';
import 'package:dart_ddi/src/features/pre_destroy.dart';

class L with PostConstruct, PreDestroy {
  String value = 'abc';

  @override
  void onPostConstruct() {
    print("Do you know how to test");
  }

  @override
  void onPreDestroy() {
    print("No ideia how to test bro");
  }
}
