/// Test service with properties for proxy testing
class TestServiceWithProperty {
  TestServiceWithProperty({this.value = 'default'});

  String value;
  int counter = 0;

  void increment() {
    counter++;
  }
}
