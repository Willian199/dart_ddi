// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'dart:async';

import 'package:dart_ddi/dart_ddi.dart';
import 'package:dart_ddi/src/enum/scopes.dart';
import 'package:dart_ddi/src/typedef/typedef.dart';

/// [ScopeFactory] is a class that represents a factory bean.
/// It is used to register a bean in the [DDI] system.
final class ScopeFactory<BeanT extends Object> {
  /// The instance created by the factory.
  BeanT? instanceHolder;

  /// The list of decorators that are called in the bean creation.
  ListDecorator<BeanT>? decorators;

  /// The list of interceptors that are called at the stages of the bean usage.
  ListDDIInterceptor<BeanT>? interceptors;

  /// The [FutureOr] function that returns the bean instance.
  final CustomBuilder<FutureOr<BeanT>>? builder;

  /// The function that is called after the bean is created.
  final VoidCallback? postConstruct;

  /// The scope type of the bean.
  final Scopes scopeType;

  /// The type of the bean.
  Type _type = BeanT;
  Type get type => _type;

  /// Whether the bean can be destroyed.
  final bool destroyable;

  /// The children of the bean. Works as a Module.
  Set<Object>? children;

  ScopeFactory._({
    required this.scopeType,
    required this.destroyable,
    this.instanceHolder,
    this.builder,
    this.decorators,
    this.postConstruct,
    this.interceptors,
    this.children,
  });

  factory ScopeFactory.singleton({
    BeanT? instanceHolder,
    CustomBuilder<FutureOr<BeanT>>? builder,
    ListDDIInterceptor<BeanT>? interceptors,
    bool destroyable = true,
    Set<Object>? children,
    ListDecorator<BeanT>? decorators,
    VoidCallback? postConstruct,
  }) {
    return ScopeFactory<BeanT>._(
      scopeType: Scopes.singleton,
      destroyable: destroyable,
      instanceHolder: instanceHolder,
      interceptors: interceptors,
      children: children,
      builder: builder,
      decorators: decorators,
      postConstruct: postConstruct,
    );
  }

  factory ScopeFactory.application({
    required CustomBuilder<FutureOr<BeanT>> builder,
    VoidCallback? postConstruct,
    ListDecorator<BeanT>? decorators,
    ListDDIInterceptor<BeanT>? interceptors,
    bool destroyable = true,
    Set<Object>? children,
  }) {
    return ScopeFactory<BeanT>._(
      scopeType: Scopes.application,
      destroyable: destroyable,
      builder: builder,
      postConstruct: postConstruct,
      decorators: decorators,
      interceptors: interceptors,
      children: children,
    );
  }

  factory ScopeFactory.session({
    required CustomBuilder<FutureOr<BeanT>> builder,
    VoidCallback? postConstruct,
    ListDecorator<BeanT>? decorators,
    ListDDIInterceptor<BeanT>? interceptors,
    bool destroyable = true,
    Set<Object>? children,
  }) {
    return ScopeFactory<BeanT>._(
      scopeType: Scopes.session,
      destroyable: destroyable,
      builder: builder,
      postConstruct: postConstruct,
      decorators: decorators,
      interceptors: interceptors,
      children: children,
    );
  }

  factory ScopeFactory.dependent({
    required CustomBuilder<FutureOr<BeanT>> builder,
    VoidCallback? postConstruct,
    ListDecorator<BeanT>? decorators,
    ListDDIInterceptor<BeanT>? interceptors,
    bool destroyable = true,
    Set<Object>? children,
  }) {
    return ScopeFactory<BeanT>._(
      scopeType: Scopes.dependent,
      destroyable: destroyable,
      builder: builder,
      postConstruct: postConstruct,
      decorators: decorators,
      interceptors: interceptors,
      children: children,
    );
  }

  factory ScopeFactory.object({
    required BeanT instanceHolder,
    ListDDIInterceptor<BeanT>? interceptors,
    bool destroyable = true,
    Set<Object>? children,
  }) {
    return ScopeFactory<BeanT>._(
      scopeType: Scopes.object,
      destroyable: destroyable,
      instanceHolder: instanceHolder,
      interceptors: interceptors,
      children: children,
    );
  }

  ScopeFactory<NewType> cast<NewType extends Object>() {
    _type = NewType;
    return this as ScopeFactory<NewType>;
  }

  Future<void> register({
    Object? qualifier,
    FutureOr<bool> Function()? registerIf,
  }) {
    return DDI.instance.register(factory: this);
  }
}
