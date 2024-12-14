import 'dart:async';

import 'package:dart_ddi/dart_ddi.dart';

import 'database_log.dart';

class LoggerFutureInterceptor implements DDIInterceptor {
  LoggerFutureInterceptor(this._databaseLog);

  final DatabaseLog _databaseLog;
  @override
  FutureOr<Object> onCreate(Object instance) async {
    await _databaseLog.salvar("Creating ${instance.runtimeType}");
    return instance;
  }

  @override
  FutureOr<void> onDestroy(Object? instance) async {
    await _databaseLog.salvar("Destroying ${instance.runtimeType}");
  }

  @override
  FutureOr<void> onDispose(Object? instance) async {
    await _databaseLog.salvar("Disposing ${instance.runtimeType}");
  }

  @override
  FutureOr<Object> onGet(Object instance) async {
    await _databaseLog.salvar("Getting ${instance.runtimeType}");
    return instance;
  }
}
