import 'package:flutter/material.dart';
import '../../models/meld.dart';
import '../../models/tile.dart';
import 'tile_widget.dart';

class MeldRow extends StatelessWidget {
  final List<Meld> melds;
  const MeldRow({super.key, required this.melds});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: melds.map((m){
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: m.tiles.map((t)=> TileWidget(tile: t)).toList(),
        );
      }).toList(),
    );
  }
}
