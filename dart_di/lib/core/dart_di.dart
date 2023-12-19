import 'package:dart_di/data/factory_clazz.dart';
import 'package:dart_di/enum/scopes.dart';
import 'package:dart_di/features/ddi_interceptor.dart';
import 'package:flutter/material.dart';

part 'dart_di_impl.dart';

abstract class DDI {
  static final DDI _instance = _DDIImpl();

  static DDI get instance => _instance;

  ///Cria a instância no momento que for registrado e reutiliza a mesma em todos os casos
  void registerSingleton<T extends Object>(
    T Function() fun, {
    Object? qualifierName,
    void Function()? postConstruct,
    List<T Function(T)>? decorators,
    DDIInterceptor Function()? interceptor,
    bool Function()? createIf,
  });

  ///Cria a instância no momento que for usado pela primeira vez, após reaproveita a instância
  void registerApplication<T extends Object>(
    T Function() fun, {
    Object? qualifierName,
    void Function()? postConstruct,
    List<T Function(T)>? decorators,
    DDIInterceptor Function()? interceptor,
    bool Function()? createIf,
  });

  ///Para toda vez que for utilizar cria uma nova instância
  void registerDependent<T extends Object>(
    T Function() fun, {
    Object? qualifierName,
    void Function()? postConstruct,
    List<T Function(T)>? decorators,
    DDIInterceptor Function()? interceptor,
    bool Function()? createIf,
  });

  void registerSession<T extends Object>(
    T Function() fun, {
    Object? qualifierName,
    void Function()? postConstruct,
    List<T Function(T)>? decorators,
    DDIInterceptor Function()? interceptor,
    bool Function()? createIf,
  });

  void registerWidget<T extends Object>(
    T Function() fun, {
    Object? qualifierName,
    void Function()? postConstruct,
    List<T Function(T)>? decorators,
    DDIInterceptor Function()? interceptor,
    bool Function()? createIf,
  });

  T get<T extends Object>({Object? qualifierName});

  T call<T extends Object>();

  void remove<T>({Object? qualifierName});

  void dispose<T>({Object? qualifierName});
}
