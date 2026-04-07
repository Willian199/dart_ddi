import 'package:dart_ddi/dart_ddi.dart';

class CoverageValue {
  const CoverageValue(this.id);

  final int id;
}

class CoverageIdentityInterceptor extends DDIInterceptor<CoverageValue> {
  @override
  CoverageValue onGet(CoverageValue instance) => instance;
}

class CoverageIntAddInterceptor extends DDIInterceptor<int> {
  @override
  int onGet(int instance) => instance + 1;
}

class CoverageObjectModule with DDIModule {
  CoverageObjectModule(this._ddi);

  final DDI _ddi;

  static const Object moduleContext = #coverage_object_module_context;

  @override
  DDI get ddiContainer => _ddi;

  @override
  Object? get contextQualifier => moduleContext;

  @override
  void onPostConstruct() {}
}

class CoverageApplicationModule with DDIModule {
  CoverageApplicationModule(this._ddi, this._context);

  final DDI _ddi;
  final Object _context;

  @override
  DDI get ddiContainer => _ddi;

  @override
  Object? get contextQualifier => _context;

  @override
  void onPostConstruct() {}
}
