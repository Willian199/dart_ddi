import 'package:dart_ddi/dart_ddi.dart';

class GetWithTrackedService {
  const GetWithTrackedService();
}

class GetWithLayeredService {
  const GetWithLayeredService(this.level);

  final int level;
}

class GetWithCountingInterceptor extends DDIInterceptor<GetWithTrackedService> {
  GetWithCountingInterceptor() {
    createdInstances++;
  }

  static int createdInstances = 0;
  static int onCreateCalls = 0;
  static int onGetCalls = 0;

  static void reset() {
    createdInstances = 0;
    onCreateCalls = 0;
    onGetCalls = 0;
  }

  @override
  GetWithTrackedService onCreate(GetWithTrackedService instance) {
    onCreateCalls++;
    return instance;
  }

  @override
  GetWithTrackedService onGet(GetWithTrackedService instance) {
    onGetCalls++;
    return instance;
  }
}

class GetWithLayeringInterceptor extends DDIInterceptor<GetWithLayeredService> {
  @override
  GetWithLayeredService onGet(GetWithLayeredService instance) {
    return GetWithLayeredService(instance.level + 1);
  }
}
