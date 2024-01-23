// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:dart_ddi/src/enum/scopes.dart';
import 'package:dart_ddi/src/features/ddi_interceptor.dart';

class FactoryClazz<BeanT> {
  BeanT? clazzInstance;
  List<BeanT Function(BeanT i)>? decorators;
  List<DDIInterceptor<BeanT> Function()>? interceptors;
  final BeanT Function()? clazzRegister;
  final void Function()? postConstruct;
  final Scopes scopeType;
  final Type type;
  final bool destroyable;

  FactoryClazz({
    required this.scopeType,
    required this.type,
    required this.destroyable,
    this.clazzInstance,
    this.clazzRegister,
    this.decorators,
    this.postConstruct,
    this.interceptors,
  });

  FactoryClazz<BeanT> copyWith({
    BeanT? clazzInstance,
    List<BeanT Function(BeanT i)>? decorators,
    List<DDIInterceptor<BeanT> Function()>? interceptors,
    BeanT Function()? clazzRegister,
    void Function()? postConstruct,
    Scopes? scopeType,
    Type? type,
    bool? destroyable,
  }) {
    return FactoryClazz<BeanT>(
      clazzInstance: clazzInstance ?? this.clazzInstance,
      decorators: decorators ?? this.decorators,
      interceptors: interceptors ?? this.interceptors,
      clazzRegister: clazzRegister ?? this.clazzRegister,
      postConstruct: postConstruct ?? this.postConstruct,
      scopeType: scopeType ?? this.scopeType,
      type: type ?? this.type,
      destroyable: destroyable ?? this.destroyable,
    );
  }
}
