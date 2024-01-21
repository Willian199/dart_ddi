import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:perfumei/modules/item/cubit/perfume_cubit.dart';
import 'package:perfumei/modules/item/state/perfume_state.dart';

class Descricao extends StatelessWidget {
  const Descricao({super.key});

  @override
  Widget build(BuildContext context) {
    debugPrint('building Descricao');
    return BlocBuilder<PerfumeCubit, PerfumeState>(
      builder: (_, PerfumeState state) {
        if (state.dadosPerfume?.descricao.isEmpty ?? true) {
          return const SizedBox();
        }
        return AnimatedOpacity(
          opacity: (state.dadosPerfume?.descricao.isEmpty ?? true) ? 0 : 1,
          duration: const Duration(milliseconds: 500),
          child: Text(
            state.dadosPerfume?.descricao ?? '',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: Theme.of(context).colorScheme.primary,
              fontSize: 14,
              height: 1.8,
            ),
          ),
        );
      },
    );
  }
}
