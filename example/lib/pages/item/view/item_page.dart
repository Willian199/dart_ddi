import 'dart:async';

import 'package:dart_ddi/dart_ddi.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:perfumei/common/components/notification/notificacao_padrao.dart';
import 'package:perfumei/common/enum/notas_enum.dart';
import 'package:perfumei/common/model/grid_model.dart';
import 'package:perfumei/common/model/layout.dart';
import 'package:perfumei/config/services/injection.dart';
import 'package:perfumei/pages/item/cubit/tab_cubit.dart';
import 'package:perfumei/pages/item/cubit/perfume_cubit.dart';
import 'package:perfumei/pages/item/item_module.dart';
import 'package:perfumei/pages/item/state/perfume_state.dart';
import 'package:perfumei/pages/item/state/tab_state.dart';
import 'package:perfumei/pages/item/widget/item_nota.dart';
import 'package:perfumei/pages/item/widget/item_topo.dart';

abstract class LoadModule<BeanT extends Object> extends StatefulWidget {
  LoadModule({
    required FutureOr<BeanT> Function() clazzRegister,
    super.key,
  }) {
    DDI.instance.registerSingleton<BeanT>(clazzRegister);
  }

  void destroy() {
    DDI.instance.destroy<BeanT>();
  }
}

class ItemPage extends LoadModule<ItemModule> {
  ItemPage({required this.item, this.bytes, super.key})
      : super(clazzRegister: ItemModule.new);
  final GridModel item;
  final Uint8List? bytes;

  @override
  State<ItemPage> createState() => _ItemPageState();
}

class _ItemPageState extends State<ItemPage> {
  final PerfumeCubit _perfumeCubit = ddi();
  final TabCubit _tabCubit = ddi();
  final Layout layout = ddi.get<Layout>();

  @override
  void dispose() {
    widget.destroy();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () {
      NotificacaoPadrao.carregando();
      _perfumeCubit.carregarHtml(widget.item.link);
    });
  }

  ButtonSegment<NotasEnum> _makeSegmentedButton(
      NotasEnum nota, Set<NotasEnum> tabSelecionada) {
    return ButtonSegment<NotasEnum>(
      value: nota,
      label: Text(
        nota.nome,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: nota.posicao == tabSelecionada.first.posicao
              ? layout.segmentedButtonSelected
              : layout.segmentedButtonDeselected,
        ),
      ),
    );
  }

  final PageController pageController = PageController(
    initialPage: NotasEnum.TOPO.posicao,
  );

  @override
  Widget build(BuildContext context) {
    debugPrint('building ItemPage');

    final double width = MediaQuery.sizeOf(context).width;
    final ThemeData tema = Theme.of(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(
          color: tema.colorScheme.primary,
          size: 30,
          shadows: [
            BoxShadow(
              color: tema.colorScheme.onPrimaryContainer,
              blurRadius: 20,
              spreadRadius: 10,
            ),
          ],
        ),
      ),
      body: Padding(
        padding: EdgeInsets.only(
          top: 25,
          left: MediaQuery.orientationOf(context) == Orientation.portrait
              ? 0
              : 30,
        ),
        child: SingleChildScrollView(
          child: BlocProvider<PerfumeCubit>(
            create: (_) => _perfumeCubit,
            child: Column(
              children: [
                ItemTopo(
                  item: widget.item,
                  bytes: widget.bytes,
                ),
                BlocBuilder<PerfumeCubit, PerfumeState>(
                  buildWhen: (previous, current) =>
                      previous.dadosPerfume != current.dadosPerfume,
                  builder: (_, PerfumeState state) {
                    if (state.dadosPerfume?.notasBase.isEmpty ?? true) {
                      return const SizedBox();
                    }

                    return AnimatedOpacity(
                      opacity: 1,
                      duration: const Duration(milliseconds: 500),
                      child: Container(
                        padding: const EdgeInsets.only(
                          top: 10,
                          left: 10,
                          bottom: 10,
                          right: 18,
                        ),
                        width: width,
                        child: BlocProvider<TabCubit>(
                          create: (_) => _tabCubit,
                          child: BlocBuilder<TabCubit, TabState>(
                            builder: (_, TabState state) {
                              return SegmentedButton<NotasEnum>(
                                segments: <ButtonSegment<NotasEnum>>[
                                  _makeSegmentedButton(
                                      NotasEnum.TOPO, state.tabSelecionada),
                                  _makeSegmentedButton(
                                      NotasEnum.CORACAO, state.tabSelecionada),
                                  _makeSegmentedButton(
                                      NotasEnum.BASE, state.tabSelecionada),
                                ],
                                selected: state.tabSelecionada,
                                onSelectionChanged: (Set<NotasEnum> value) {
                                  _tabCubit.changeTabSelecionada(value);
                                  pageController.animateToPage(
                                      value.first.posicao,
                                      duration:
                                          const Duration(milliseconds: 300),
                                      curve: Curves.fastOutSlowIn);
                                },
                                showSelectedIcon: false,
                              );
                            },
                          ),
                        ),
                      ),
                    );
                  },
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: SizedBox(
                    width: width,
                    height: 210,
                    child: BlocBuilder<PerfumeCubit, PerfumeState>(
                      buildWhen: (previous, current) =>
                          previous.dadosPerfume != current.dadosPerfume,
                      builder: (_, PerfumeState state) {
                        return PageView(
                          controller: pageController,
                          onPageChanged: (int page) {
                            DDIStream.instance
                                .fire<int>(value: page, qualifier: 'page_view');
                          },
                          children: [
                            ItemNota(lista: state.dadosPerfume?.notasTopo),
                            ItemNota(lista: state.dadosPerfume?.notasCoracao),
                            ItemNota(lista: state.dadosPerfume?.notasBase),
                          ],
                        );
                      },
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
