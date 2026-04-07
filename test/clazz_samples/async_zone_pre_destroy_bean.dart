import 'package:dart_ddi/dart_ddi.dart';

class AsyncZonePreDestroyBean with PreDestroy {
  AsyncZonePreDestroyBean(this.origin);

  final String origin;

  @override
  Future<void> onPreDestroy() async {
    await Future<void>.delayed(const Duration(milliseconds: 1));
  }
}
