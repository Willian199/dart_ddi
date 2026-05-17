import 'package:dart_ddi/dart_ddi.dart';

final class PublicApiBuilderSurfaceValue {
  const PublicApiBuilderSurfaceValue(this.value);

  final String value;
}

final class PublicApiManualSurfaceModule with DDIModule {
  PublicApiManualSurfaceModule(this._ddi);

  final DDI _ddi;

  @override
  DDI get ddiContainer => _ddi;

  @override
  void onPostConstruct() {}
}

final class PublicApiMissingModuleDependency {}

final class PublicApiModuleApplicationChild {}

final class PublicApiModuleDependentChild {}

final class PublicApiModuleSingletonChild {}

final class PublicApiModuleObjectChild {}

final class PublicApiOptionalSurfaceValue {
  const PublicApiOptionalSurfaceValue(this.value);

  final String value;
}

final class PublicApiOptionalParameterizedValue {
  const PublicApiOptionalParameterizedValue(this.value);

  final String value;
}
