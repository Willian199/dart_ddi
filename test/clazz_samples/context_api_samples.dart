import 'package:dart_ddi/dart_ddi.dart';

class ContextApiService {
  ContextApiService(this.value);

  final String value;
}

class ContextApiInterceptor extends DDIInterceptor<ContextApiService> {
  ContextApiInterceptor(this.suffix);

  final String suffix;

  @override
  ContextApiService onGet(ContextApiService instance) {
    return ContextApiService('${instance.value}$suffix');
  }
}
