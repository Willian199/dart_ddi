// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'dart:async';

import 'package:dart_ddi/src/enum/scopes.dart';
import 'package:dart_ddi/src/features/ddi_interceptor.dart';

/// [FactoryClazz] is a class that represents a factory bean.
/// It is used to register a bean in the [DDI] system.
class FactoryClazz<BeanT> {
  /// The [BeanT] instance of the bean.
  BeanT? clazzInstance;

  /// The list of decorators that are called in the bean creation.
  List<BeanT Function(BeanT instance)>? decorators;

  /// The list of interceptors that are called at the stages of the bean usage.
  List<DDIInterceptor<BeanT> Function()>? interceptors;

  /// The [FutureOr] function that returns the bean instance.
  final FutureOr<BeanT> Function()? clazzRegister;

  /// The function that is called after the bean is created.
  final void Function()? postConstruct;

  /// The scope type of the bean.
  final Scopes scopeType;

  /// The type of the bean.
  final Type type;

  /// Whether the bean can be destroyed.
  final bool destroyable;

  /// The children of the bean. Works as a Module.
  List<Object>? children;

  FactoryClazz({
    required this.scopeType,
    required this.type,
    required this.destroyable,
    this.clazzInstance,
    this.clazzRegister,
    this.decorators,
    this.postConstruct,
    this.interceptors,
    this.children,
  });

  FactoryClazz<BeanT> copyWith({
    BeanT? clazzInstance,
    List<BeanT Function(BeanT i)>? decorators,
    List<DDIInterceptor<BeanT> Function()>? interceptors,
    FutureOr<BeanT> Function()? clazzRegister,
    void Function()? postConstruct,
    Scopes? scopeType,
    Type? type,
    bool? destroyable,
    List<Object>? children,
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
      children: children ?? this.children,
    );
  }
}
