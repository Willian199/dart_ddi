import 'package:dart_ddi/dart_ddi.dart';

import 'beans_test/add_decoratos_test.dart';
import 'beans_test/application_future_test.dart';
import 'beans_test/application_test.dart';
import 'beans_test/circular_injection_test.dart';
import 'beans_test/dependent_future_test.dart';
import 'beans_test/dependent_test.dart';
import 'beans_test/dispose_destroy_all_session_test.dart';
import 'beans_test/future_add_decoratos_test.dart';
import 'beans_test/future_circular_injection_test.dart';
import 'beans_test/future_post_construct_pre_destroy_test.dart';
import 'beans_test/get_by_future_type_test.dart';
import 'beans_test/get_by_type_test.dart';
import 'beans_test/interceptor_test.dart';
import 'beans_test/module_application_test.dart';
import 'beans_test/module_dependent_test.dart';
import 'beans_test/module_object_test.dart';
import 'beans_test/module_session_test.dart';
import 'beans_test/module_singleton_test.dart';
import 'beans_test/object_future_test.dart';
import 'beans_test/object_test.dart';
import 'beans_test/post_construct_pre_destroy_test.dart';
import 'beans_test/register_if_test.dart';
import 'beans_test/session_future_test.dart';
import 'beans_test/session_test.dart';
import 'beans_test/singleton_future_test.dart';
import 'beans_test/singleton_test.dart';
import 'event_test/event_filter_test.dart';
import 'event_test/event_lock_test.dart';
import 'event_test/event_test.dart';
import 'event_test/timer_events_test.dart';
import 'stream_test/stream_test.dart';

void main() {
  ddi.setDebugMode(false);
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
  registerIf();
  futurePostConstructPreDestroyTest();

  //Decorators
  addDecorator();
  futureAddDecorator();

  //Interceptor
  interceptor();

  //CircularDetection
  circularDetection();
  futureCircularDetection();

  //Modules
  moduleSingletonTest();
  moduleApplicationTest();
  moduleDependentTest();
  moduleObjectTest();
  moduleSessionTest();

  //Events
  eventTest();
  eventFilterTest();
  eventLockTest();
  eventDurationTests();

  //Streams
  streamTest();
}
