import 'package:dart_ddi/dart_ddi.dart';

class FuturePostConstruct with PostConstruct {
  int value = 0;
  @override
  Future<void> onPostConstruct() async {
    await Future.delayed(const Duration(milliseconds: 10), () => value = 10);
  }
}
