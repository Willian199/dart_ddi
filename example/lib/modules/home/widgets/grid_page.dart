import 'package:flutter/material.dart';
import 'package:perfumei/common/model/grid_model.dart';
import 'package:perfumei/modules/home/widgets/grid_row.dart';

class GridPage extends StatefulWidget {
  const GridPage({
    required this.dados,
    required this.onPressed,
    super.key,
    this.icon = Icons.error,
  });
  final List dados;
  final IconData icon;
  final Function onPressed;

  @override
  State<GridPage> createState() => _GridPageState();
}

class _GridPageState extends State<GridPage> {
  @override
  Widget build(BuildContext context) {
    late int crossAxisCount;
    late double childAspectRatio;
    final Size size = MediaQuery.sizeOf(context);

    if (MediaQuery.orientationOf(context) == Orientation.landscape) {
      crossAxisCount = 2;
      childAspectRatio = size.width / size.height;
    } else {
      crossAxisCount = 1;
      childAspectRatio = size.height / size.width;
    }

    return GridView.builder(
        shrinkWrap: true,
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 1.0,
          childAspectRatio: childAspectRatio + 0.2,
        ),
        itemCount: widget.dados.length,
        itemBuilder: (context, index) {
          return GridRow(
            grid: GridModel.fromJson(widget.dados[index]),
            icon: widget.icon,
            onPressed: widget.onPressed,
          );
        });
  }
}
