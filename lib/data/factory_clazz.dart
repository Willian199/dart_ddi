// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:dart_di/enum/scopes.dart';
import 'package:dart_di/features/ddi_interceptor.dart';

class FactoryClazz<T> {
  T? clazzInstance;
  List<T Function(T i)>? decorators;
  List<DDIInterceptor<T> Function()>? interceptors;
  final T Function()? clazzRegister;
  final void Function()? postConstruct;
  final Scopes scopeType;
  final Type type;

  FactoryClazz({
    required this.scopeType,
    required this.type,
    this.clazzInstance,
    this.clazzRegister,
    this.decorators,
    this.postConstruct,
    this.interceptors,
  });

  FactoryClazz<T> copyWith({
    T? clazzInstance,
    T Function()? clazzRegister,
    List<T Function(T i)>? decorators,
    void Function()? postConstruct,
    List<DDIInterceptor<T> Function()>? interceptors,
    Scopes? scopeType,
    Type? type,
  }) {
    return FactoryClazz<T>(
      clazzInstance: clazzInstance ?? this.clazzInstance,
      clazzRegister: clazzRegister ?? this.clazzRegister,
      decorators: decorators ?? this.decorators,
      postConstruct: postConstruct ?? this.postConstruct,
      interceptors: interceptors ?? this.interceptors,
      scopeType: scopeType ?? this.scopeType,
      type: type ?? this.type,
    );
  }
}
