import 'dart:io';
import 'dart:ui';

import 'package:dart_ddi/dart_ddi.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:dio_cache_interceptor_objectbox_store/dio_cache_interceptor_objectbox_store.dart';
import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart' as pp;
import 'package:perfumei/common/constants/injection_constants.dart';
import 'package:perfumei/pages/home/cubit/home_cubit.dart';

final DDI ddi = DDI.instance;

class Injection {
  static Future<void> start() async {
    ddi.registerObject<String>('https://fgvi612dfz-dsn.algolia.net',
        qualifier: InjectionConstants.url);

    ddi.registerSingleton<GlobalKey<NavigatorState>>(
        () => GlobalKey<NavigatorState>());

    ddi.registerObject<bool>(
        WidgetsBinding.instance.platformDispatcher.platformBrightness ==
            Brightness.dark,
        qualifier: InjectionConstants.darkMode);

    ddi.registerDependent<HomeCubit>(() => HomeCubit());

    final Directory dir = await pp.getTemporaryDirectory();
    ddi.registerSingleton<CacheStore>(
        () => ObjectBoxCacheStore(storePath: dir.path));
  }
}
