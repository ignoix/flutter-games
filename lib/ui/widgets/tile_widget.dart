import 'package:flutter/material.dart';
import '../../models/tile.dart';

class TileWidget extends StatelessWidget {
  final Tile tile;
  final bool selected;
  final VoidCallback? onTap;
  const TileWidget({super.key, required this.tile, this.selected=false, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36, height: 48,
        margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: selected ? Colors.blue : Colors.black12),
          color: selected ? Colors.blue.withOpacity(0.08) : Colors.white,
          boxShadow: const [BoxShadow(blurRadius: 2, offset: Offset(0,1), color: Colors.black12)],
        ),
        child: FittedBox(
          fit: BoxFit.contain,
          child: Text(_label(tile), textAlign: TextAlign.center),
        ),
      ),
    );
  }

  String _label(Tile t) {
    switch (t.suit) {
      case TileSuit.man: return '${t.rank}万';
      case TileSuit.pin: return '${t.rank}筒';
      case TileSuit.sou: return '${t.rank}索';
      case TileSuit.wind: return ['','东','南','西','北'][t.rank];
      case TileSuit.dragon: return ['','中','发','白'][t.rank];
      case TileSuit.flower: return '花${t.rank}';
      case TileSuit.season: return '季${t.rank}';
    }
  }
}
