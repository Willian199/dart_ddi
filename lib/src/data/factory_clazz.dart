// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'dart:async';

import 'package:dart_ddi/src/data/custom_factory.dart';
import 'package:dart_ddi/src/enum/scopes.dart';
import 'package:dart_ddi/src/typedef/typedef.dart';

/// [FactoryClazz] is a class that represents a factory bean.
/// It is used to register a bean in the [DDI] system.
final class FactoryClazz<BeanT extends Object> {
  /// The [BeanT] instance of the bean.
  BeanT? clazzInstance;

  /// The list of decorators that are called in the bean creation.
  ListDecorator<BeanT>? decorators;

  /// The list of interceptors that are called at the stages of the bean usage.
  ListDDIInterceptor<BeanT>? interceptors;

  /// The [FutureOr] function that returns the bean instance.
  final CustomFactory<FutureOr<BeanT>>? clazzFactory;

  /// The function that is called after the bean is created.
  final VoidCallback? postConstruct;

  /// The scope type of the bean.
  final Scopes scopeType;

  /// The type of the bean.
  final Type type = BeanT;

  /// Whether the bean can be destroyed.
  final bool destroyable;

  /// The children of the bean. Works as a Module.
  Set<Object>? children;

  FactoryClazz._({
    required this.scopeType,
    required this.destroyable,
    this.clazzInstance,
    this.clazzFactory,
    this.decorators,
    this.postConstruct,
    this.interceptors,
    this.children,
  });

  factory FactoryClazz.singleton({
    BeanT? clazzInstance,
    CustomFactory<FutureOr<BeanT>>? clazzFactory,
    ListDDIInterceptor<BeanT>? interceptors,
    bool destroyable = true,
    Set<Object>? children,
    ListDecorator<BeanT>? decorators,
  }) {
    return FactoryClazz<BeanT>._(
      scopeType: Scopes.singleton,
      destroyable: destroyable,
      clazzInstance: clazzInstance,
      interceptors: interceptors,
      children: children,
      clazzFactory: clazzFactory,
      decorators: decorators,
    );
  }

  factory FactoryClazz.application({
    required CustomFactory<FutureOr<BeanT>> clazzFactory,
    VoidCallback? postConstruct,
    ListDecorator<BeanT>? decorators,
    ListDDIInterceptor<BeanT>? interceptors,
    bool destroyable = true,
    Set<Object>? children,
  }) {
    return FactoryClazz<BeanT>._(
      scopeType: Scopes.application,
      destroyable: destroyable,
      clazzFactory: clazzFactory,
      postConstruct: postConstruct,
      decorators: decorators,
      interceptors: interceptors,
      children: children,
    );
  }

  factory FactoryClazz.session({
    required CustomFactory<FutureOr<BeanT>> clazzFactory,
    VoidCallback? postConstruct,
    ListDecorator<BeanT>? decorators,
    ListDDIInterceptor<BeanT>? interceptors,
    bool destroyable = true,
    Set<Object>? children,
  }) {
    return FactoryClazz<BeanT>._(
      scopeType: Scopes.session,
      destroyable: destroyable,
      clazzFactory: clazzFactory,
      postConstruct: postConstruct,
      decorators: decorators,
      interceptors: interceptors,
      children: children,
    );
  }

  factory FactoryClazz.dependent({
    required CustomFactory<FutureOr<BeanT>> clazzFactory,
    VoidCallback? postConstruct,
    ListDecorator<BeanT>? decorators,
    ListDDIInterceptor<BeanT>? interceptors,
    bool destroyable = true,
    Set<Object>? children,
  }) {
    return FactoryClazz<BeanT>._(
      scopeType: Scopes.dependent,
      destroyable: destroyable,
      clazzFactory: clazzFactory,
      postConstruct: postConstruct,
      decorators: decorators,
      interceptors: interceptors,
      children: children,
    );
  }

  factory FactoryClazz.object({
    required BeanT clazzInstance,
    ListDDIInterceptor<BeanT>? interceptors,
    bool destroyable = true,
    Set<Object>? children,
  }) {
    return FactoryClazz<BeanT>._(
      scopeType: Scopes.object,
      destroyable: destroyable,
      clazzInstance: clazzInstance,
      interceptors: interceptors,
      children: children,
    );
  }
}
