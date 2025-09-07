import 'package:flutter/material.dart';
import '../../models/tile.dart';
import 'tile_widget.dart';

class HandRow extends StatelessWidget {
  final List<Tile> tiles;
  final Tile? selected;
  final void Function(Tile) onSelect;
  const HandRow({super.key, required this.tiles, this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      children: tiles.map((t)=> TileWidget(
        tile: t,
        selected: selected?.id == t.id,
        onTap: ()=> onSelect(t),
      )).toList(),
    );
  }
}
