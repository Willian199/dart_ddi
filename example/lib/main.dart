import 'dart:async';

import 'package:flutter/material.dart';
import 'package:perfumei/config/services/injection.dart';
import 'package:perfumei/config/theme/dark.dart';
import 'package:perfumei/config/theme/light.dart';
import 'package:perfumei/modules/home/view/home_page.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  unawaited(WakelockPlus.enable());

  Injection.start();

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
