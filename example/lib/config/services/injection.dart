import 'dart:io';
import 'dart:ui';

import 'package:dart_ddi/dart_di.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:dio_cache_interceptor_objectbox_store/dio_cache_interceptor_objectbox_store.dart';
import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart' as pp;
import 'package:perfumei/common/constants/injection_constants.dart';
import 'package:perfumei/modules/home/mobx/home_mobx.dart';
import 'package:perfumei/modules/item/mobx/item_mobx.dart';

final DDI ddi = DDI.instance;

class Injection {
  static Future<void> start() async {
    ddi.registerSingleton<String>(() => 'https://fgvi612dfz-dsn.algolia.net', qualifierName: InjectionConstants.url);

    ddi.registerSingleton<GlobalKey<NavigatorState>>(() => GlobalKey<NavigatorState>());

    ddi.registerApplication<bool>(() => WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.dark,
        qualifierName: InjectionConstants.darkMode);

    ddi.registerDependent<ObservableHome>(() => ObservableHome());
    ddi.registerApplication<ObservableItem>(() => ObservableItem());

    final Directory dir = await pp.getTemporaryDirectory();
    ddi.registerSingleton<CacheStore>(() => ObjectBoxCacheStore(storePath: dir.path));
  }
}
