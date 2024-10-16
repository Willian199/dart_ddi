// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'dart:async';

import 'package:dart_ddi/dart_ddi.dart';
import 'package:dart_ddi/src/enum/scopes.dart';
import 'package:dart_ddi/src/typedef/typedef.dart';

/// [ScopeFactory] is a class that represents a Bean and its state.
/// It is used for the registration of Beans in the [DDI] system.
final class ScopeFactory<BeanT extends Object> {
  /// The instance of the Bean created by the factory.
  BeanT? instanceHolder;

  /// A list of decorators that are applied during the Bean creation process.
  ListDecorator<BeanT>? decorators;

  /// A list of interceptors that are called at various stages of the Bean usage.
  ListDDIInterceptor<BeanT>? interceptors;

  /// The factory builder responsible for creating the Bean.
  final CustomBuilder<FutureOr<BeanT>>? builder;

  /// A callback function that is invoked after the Bean is created.
  final VoidCallback? postConstruct;

  /// The scope type that defines the lifecycle of the Bean (e.g., Singleton, Application, Session, etc.).
  final Scopes scopeType;

  /// The type of the Bean.
  Type _type = BeanT;

  /// Returns the current Bean type.
  Type get type => _type;

  /// A flag that indicates whether the Bean can be destroyed after its usage.
  final bool destroyable;

  /// The child objects associated with the Bean, acting as a module.
  Set<Object>? children;

  /// Private constructor for [ScopeFactory].
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

  /// Factory method that creates a Bean with the Singleton scope.
  ///
  /// A Singleton-scoped Bean is created eagerly and shared across the entire application.
  /// It ensures that the Bean is instantiated a single time and reused on subsequent injections.
  ///
  /// - `instanceHolder`: Don't provide this parameter. Used by the package internally.
  /// - `builder`: A [CustomBuilder] responsible for creating the Bean if no instance is provided.
  /// - `interceptors`: Optional list of interceptors that will be applied to the Bean at various stages.
  /// - `destroyable`: Optional parameter to make the instance indestructible.
  /// - `children`: Optional set of child objects that are part of the Bean's module.
  /// - `decorators`: Optional list of decorators to apply additional logic during Bean creation.
  /// - `postConstruct`: A callback function invoked after the Bean is constructed.
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

  /// Factory method that creates a Bean with the Application scope.
  ///
  /// An Application-scoped Bean is created only when needed and shared across the entire application.
  ///
  /// - `builder`: A [CustomBuilder] responsible for creating the Bean.
  /// - `postConstruct`: A callback function invoked after the Bean is constructed.
  /// - `decorators`: Optional list of decorators to apply additional logic during Bean creation.
  /// - `interceptors`: Optional list of interceptors that will be applied to the Bean.
  /// - `destroyable`: Optional parameter to make the instance indestructible.
  /// - `children`: Optional set of child objects that are part of the Bean's module.
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

  /// Factory method that creates a Bean with the Session scope.
  ///
  /// A Session-scoped Bean is tied to the lifecycle of a session and is unique.
  ///
  /// - `builder`: A [CustomBuilder] responsible for creating the Bean.
  /// - `postConstruct`: A callback function invoked after the Bean is constructed.
  /// - `decorators`: Optional list of decorators to apply additional logic during Bean creation.
  /// - `interceptors`: Optional list of interceptors that will be applied to the Bean.
  /// - `destroyable`: Optional parameter to make the instance indestructible.
  /// - `children`: Optional set of child objects that are part of the Bean's module.
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

  /// Factory method that creates a Bean with the Dependent scope.
  ///
  /// A Dependent-scoped Bean is created every time it is requested. It is not shared
  /// across different components and exists for as long as the dependent object exists.
  ///
  /// - `builder`: A [CustomBuilder] responsible for creating the Bean.
  /// - `postConstruct`: A callback function invoked after the Bean is constructed.
  /// - `decorators`: Optional list of decorators to apply additional logic during Bean creation.
  /// - `interceptors`: Optional list of interceptors that will be applied to the Bean.
  /// - `destroyable`: Optional parameter to make the instance indestructible.
  /// - `children`: Optional set of child objects that are part of the Bean's module.
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

  /// Factory method that creates a Bean with the Object scope.
  ///
  /// An Object-scoped Bean is an existing instance that is treated as a Bean
  /// without any further instantiation or modification.
  ///
  /// - [instanceHolder]: The existing instance that will be registered as a Bean.
  /// - [interceptors]: Optional list of interceptors that will be applied to the Bean.
  /// - [destroyable]: If true, the Bean can be destroyed when no longer needed (default is true).
  /// - [children]: Optional set of child objects that are part of the Bean's module.
  factory ScopeFactory.object({
    required BeanT instanceHolder,
    ListDDIInterceptor<BeanT>? interceptors,
    ListDecorator<BeanT>? decorators,
    bool destroyable = true,
    Set<Object>? children,
  }) {
    return ScopeFactory<BeanT>._(
      scopeType: Scopes.object,
      destroyable: destroyable,
      instanceHolder: instanceHolder,
      decorators: decorators,
      interceptors: interceptors,
      children: children,
    );
  }

  /// Casts the current [ScopeFactory] to a new type [NewType].
  ScopeFactory<NewType> cast<NewType extends Object>() {
    _type = NewType;
    return this as ScopeFactory<NewType>;
  }

  /// Registers the current [ScopeFactory] in the DDI system.
  ///
  /// - `qualifier`: An optional object to qualify the Bean.
  /// - `registerIf`: A condition function that determines if the registration should occur.
  Future<void> register({
    Object? qualifier,
    FutureOr<bool> Function()? registerIf,
  }) {
    return DDI.instance.register<BeanT>(
      factory: this,
      qualifier: qualifier,
      registerIf: registerIf,
    );
  }
}
