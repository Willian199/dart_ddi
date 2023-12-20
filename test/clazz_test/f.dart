import 'd.dart';

class F extends D {
  F(instance) {
    super.value = '${instance.value.toString().replaceAll('e', '')}ghi';
  }
}
