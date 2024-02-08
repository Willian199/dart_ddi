import 'dart:async';

import 'package:dart_ddi/dart_ddi.dart';
import 'package:flutter/foundation.dart';
import 'package:perfumei/pages/item/cubit/imagem_cubit.dart';
import 'package:perfumei/pages/item/cubit/perfume_cubit.dart';
import 'package:perfumei/pages/item/cubit/tab_cubit.dart';

final class ItemModule with DDIModule {
  @override
  FutureOr<void> onPostConstruct() {
    debugPrint('criando module');
    registerApplication(TabCubit.new);
    registerApplication(PerfumeCubit.new);
    registerApplication(ImagemCubit.new);
  }
}
