import 'package:flutter/material.dart';
import '../../models/tile.dart';
import 'tile_widget.dart';

class RiverPanel extends StatelessWidget {
  final List<List<Tile>> rivers; // 4家
  const RiverPanel({super.key, required this.rivers});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(4, (i){
        return Wrap(
          children: rivers[i].map((t)=> TileWidget(tile: t)).toList(),
        );
      }),
    );
  }
}
