import 'dart:io';

import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:dio_cache_interceptor_objectbox_store/dio_cache_interceptor_objectbox_store.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart' as pp;
import 'package:perfumei/common/constants/injection_constants.dart';
import 'package:perfumei/config/services/injection.dart';
import 'package:perfumei/config/theme/dark.dart';
import 'package:perfumei/config/theme/light.dart';
import 'package:perfumei/modules/home/cubit/home_cubit.dart';
import 'package:perfumei/modules/home/view/home_page.dart';
import 'package:perfumei/modules/item/cubit/imagem_cubit.dart';
import 'package:perfumei/modules/item/cubit/item_cubit.dart';
import 'package:perfumei/modules/item/cubit/perfume_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  //unawaited(WakelockPlus.enable());

  //Injection.start();

  ddi.registerObject<String>('https://fgvi612dfz-dsn.algolia.net',
      qualifier: InjectionConstants.url);

  ddi.registerSingleton<GlobalKey<NavigatorState>>(
      () => GlobalKey<NavigatorState>());

  ddi.registerObject<bool>(
      WidgetsBinding.instance.platformDispatcher.platformBrightness ==
          Brightness.dark,
      qualifier: InjectionConstants.darkMode);

  ddi.registerDependent<HomeCubit>(HomeCubit.new);
  ddi.registerDependent<TabCubit>(TabCubit.new);
  ddi.registerDependent<PerfumeCubit>(PerfumeCubit.new);
  ddi.registerDependent<ImagemCubit>(ImagemCubit.new);

  await ddi.registerSingleton<CacheStore>(() async {
    final Directory dir = await pp.getTemporaryDirectory();
    return ObjectBoxCacheStore(storePath: dir.path);
  });

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Perfumei',
      navigatorKey: ddi(),
      debugShowCheckedModeBanner: false,
      //Git Request to make it default
      theme: LigthTheme.getTheme(),
      darkTheme: DarkTheme.getTheme(),
      // If you do not have a themeMode switch, uncomment this line
      // to let the device system mode control the theme mode:
      //themeMode: ThemeMode.system,
      home: const HomePage(),
    );
  }
}
