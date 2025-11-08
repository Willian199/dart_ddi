/// Simple test service for proxy testing
class TestService {
  TestService() : _callCount = 0;

  int _callCount;

  int get callCount => _callCount;

  String doSomething() {
    _callCount++;
    return 'done';
  }

  int add(int a, int b) {
    _callCount++;
    return a + b;
  }

  String greet({required String name}) {
    _callCount++;
    return 'Hello, $name!';
  }
}
