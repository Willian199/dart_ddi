// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:dart_di/enum/scopes.dart';
import 'package:dart_di/features/ddi_interceptor.dart';

class FactoryClazz<T> {
  T? clazzInstance;
  final T Function()? clazzRegister;
  List<T Function(T i)>? decorators;
  final void Function()? postConstruct;
  final DDIInterceptor<T> Function()? interceptor;
  final Scopes scopeType;
  final Type type;

  FactoryClazz({
    required this.scopeType,
    required this.type,
    this.clazzInstance,
    this.clazzRegister,
    this.decorators,
    this.postConstruct,
    this.interceptor,
  });

  FactoryClazz<T> copyWith({
    T? clazzInstance,
    T Function()? clazzRegister,
    List<T Function(T i)>? decorators,
    void Function()? postConstruct,
    DDIInterceptor<T> Function()? interceptor,
    Scopes? scopeType,
    Type? type,
  }) {
    return FactoryClazz<T>(
      clazzInstance: clazzInstance ?? this.clazzInstance,
      clazzRegister: clazzRegister ?? this.clazzRegister,
      decorators: decorators ?? this.decorators,
      postConstruct: postConstruct ?? this.postConstruct,
      interceptor: interceptor ?? this.interceptor,
      scopeType: scopeType ?? this.scopeType,
      type: type ?? this.type,
    );
  }
}
