import 'group_test/add_decoratos_test.dart';
import 'group_test/application_test.dart';
import 'group_test/circular_injection_test.dart';
import 'group_test/dependent_test.dart';
import 'group_test/dispose_destroy_all_session_test.dart';
import 'group_test/get_by_type_test.dart';
import 'group_test/interceptor_test.dart';
import 'group_test/object_test.dart';
import 'group_test/register_if_test.dart';
import 'group_test/session_test.dart';
import 'group_test/singleton_test.dart';

void main() {
  //Basic Tests, with consists in register, get, dispose, remove
  singleton();
  application();
  session();
  dependent();
  object();

  runByType();
  disposeDestroyAllSession();
  registerIf();

  //Decorators
  addDecorator();

  //Interceptor
  interceptor();

  //CircularDetection
  circularDetection();
}
