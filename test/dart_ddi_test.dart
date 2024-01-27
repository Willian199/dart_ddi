import 'beans_test/add_decoratos_test.dart';
import 'beans_test/application_future_test.dart';
import 'beans_test/application_test.dart';
import 'beans_test/circular_injection_test.dart';
import 'beans_test/dependent_future_test.dart';
import 'beans_test/dependent_test.dart';
import 'beans_test/dispose_destroy_all_session_test.dart';
import 'beans_test/future_post_construct_pre_destroy_test.dart';
import 'beans_test/get_by_future_type_test.dart';
import 'beans_test/get_by_type_test.dart';
import 'beans_test/interceptor_test.dart';
import 'beans_test/object_future_test.dart';
import 'beans_test/object_test.dart';
import 'beans_test/post_construct_pre_destroy_test.dart';
import 'beans_test/register_if_test.dart';
import 'beans_test/session_future_test.dart';
import 'beans_test/session_test.dart';
import 'beans_test/singleton_future_test.dart';
import 'beans_test/singleton_test.dart';
import 'event_test/event_test.dart';
import 'stream_test/stream_test.dart';

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
  postConstructPreDestroyTest();

  //Futures
  applicationFuture();
  singletonFuture();
  sessionFuture();
  dependentFuture();
  objectFuture();

  runByFutureType();
  futurePostConstructPreDestroyTest();

  //Decorators
  addDecorator();

  //Interceptor
  interceptor();

  //CircularDetection
  circularDetection();

  //Events
  eventTest();

  //Streams
  streamTest();
}
