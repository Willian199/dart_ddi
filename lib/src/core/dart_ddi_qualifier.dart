import 'dart:async';

import 'package:dart_ddi/dart_ddi.dart';

/// Gerencia o mapeamento de qualificadores para Zones
class DartDDIQualifier {
  // Chave usada para armazenar dados na Zone
  static const _beansKey = #ddi_beans_registry;

  String get zoneName => Zone.current[#zone_name] as String? ?? 'root';

  // Mapa global de beans (fallback)
  final Map<Object, DDIBaseFactory<Object>> _globalBeansMap = {};

  // Obtém o mapa de beans para a zona atual
  Map<Object, DDIBaseFactory<Object>> _getBeansMap() {
    final Map<Object, DDIBaseFactory<Object>>? zoneMap =
        Zone.current[_beansKey] as Map<Object, DDIBaseFactory<Object>>?;

    return zoneMap ?? _globalBeansMap;
  }

  DDIBaseFactory<Object>? getFactory<BeanT extends Object>(
      {required Object qualifier, bool fallback = true}) {
    final Map<Object, DDIBaseFactory<Object>>? zoneMap =
        Zone.current[_beansKey] as Map<Object, DDIBaseFactory<Object>>?;

    if (zoneMap?.containsKey(qualifier) ?? false) {
      return zoneMap?[qualifier] as DDIBaseFactory<BeanT>;
    } else if (fallback && Zone.current.parent != null) {
      Zone zone = Zone.current.parent!;

      while (zone.parent != null && zone[#zone_name] != null) {
        final Map<Object, DDIBaseFactory<Object>>? parentZoneMap =
            zone[_beansKey] as Map<Object, DDIBaseFactory<Object>>?;

        if (parentZoneMap?.containsKey(qualifier) ?? false) {
          return parentZoneMap?[qualifier] as DDIBaseFactory<BeanT>;
        }

        zone = zone.parent!;
      }
    }

    if (fallback || zoneName == 'root') {
      return _globalBeansMap[qualifier] as DDIBaseFactory<BeanT>?;
    }

    return null;
  }

  // Verifica se estamos em uma zona com registro dedicado
  bool hasZoneRegistry() {
    return Zone.current[_beansKey] != null;
  }

  // Executa código em uma nova zona com registros dedicados
  T runWithZoneRegistry<T>(String name, T Function() body) {
    return runZoned(
      body,
      zoneValues: {
        #zone_name: name,
        _beansKey: <Object, DDIBaseFactory<Object>>{},
      },
    );
  }

  // Implementação dos métodos obrigatórios de MapBase

  void setFactory(Object key, DDIBaseFactory<Object> value) {
    _getBeansMap()[key] = value;
  }

  Iterable<Object> get keys => _getBeansMap().keys;

  Iterable<MapEntry<Object, DDIBaseFactory<Object>>> get entries =>
      _getBeansMap().entries;

  DDIBaseFactory<Object>? remove(Object? key) {
    return _getBeansMap().remove(key);
  }
}
