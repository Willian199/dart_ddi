// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:dart_di/enum/scopes.dart';
import 'package:dart_di/features/ddi_interceptor.dart';

class FactoryClazz<T> {
  final T? clazzInstance;
  final T Function()? clazzRegister;
  final List<T Function(T i)>? decorators;
  final void Function()? postConstruct;
  final DDIInterceptor<T> Function()? interceptor;
  final Scopes scopeType;

  FactoryClazz({
    required this.scopeType,
    this.clazzInstance,
    this.clazzRegister,
    this.decorators,
    this.postConstruct,
    this.interceptor,
  });

  FactoryClazz<T> copyWith({
    T? clazzInstance,
    T Function()? clazzRegister,
    List<T Function(T)>? decorators,
    void Function()? postConstruct,
    DDIInterceptor<T> Function()? interceptor,
    Scopes? scopeType,
  }) {
    return FactoryClazz<T>(
      clazzInstance: clazzInstance ?? this.clazzInstance,
      clazzRegister: clazzRegister ?? this.clazzRegister,
      decorators: decorators ?? this.decorators,
      postConstruct: postConstruct ?? this.postConstruct,
      interceptor: interceptor ?? this.interceptor,
      scopeType: scopeType ?? this.scopeType,
    );
  }
}
