// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:dart_ddi/src/enum/scopes.dart';
import 'package:dart_ddi/src/features/ddi_interceptor.dart';

class FactoryClazz<T> {
  T? clazzInstance;
  List<T Function(T i)>? decorators;
  List<DDIInterceptor<T> Function()>? interceptors;
  final T Function()? clazzRegister;
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

  FactoryClazz<T> copyWith({
    T? clazzInstance,
    List<T Function(T i)>? decorators,
    List<DDIInterceptor<T> Function()>? interceptors,
    T Function()? clazzRegister,
    void Function()? postConstruct,
    Scopes? scopeType,
    Type? type,
    bool? destroyable,
  }) {
    return FactoryClazz<T>(
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
