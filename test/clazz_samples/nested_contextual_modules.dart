import 'package:dart_ddi/dart_ddi.dart';

class NestedContextValue {
  NestedContextValue(this.origin);

  final String origin;
}

class NestedChildModule with DDIModule {
  @override
  Object? get contextQualifier => moduleQualifier;

  @override
  Future<void> onPostConstruct() async {
    await object<NestedContextValue>(NestedContextValue('child'));
  }
}

class NestedParentModule with DDIModule {
  @override
  Object? get contextQualifier => moduleQualifier;

  @override
  Future<void> onPostConstruct() async {
    await object<NestedContextValue>(NestedContextValue('parent'));
    await singleton<NestedChildModule>(NestedChildModule.new);
  }
}
