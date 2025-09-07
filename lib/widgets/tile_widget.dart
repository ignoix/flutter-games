import 'package:flutter/material.dart';
import '../models/tile.dart';
import '../services/animation_service.dart';

class TileWidget extends StatelessWidget {
  final Tile tile;
  final double width;
  final double height;
  final VoidCallback? onTap;
  final bool isSelected;
  final bool isHighlighted;
  final bool enableAnimation;

  const TileWidget({
    super.key,
    required this.tile,
    this.width = 40,
    this.height = 60,
    this.onTap,
    this.isSelected = false,
    this.isHighlighted = false,
    this.enableAnimation = true,
  });

  @override
  Widget build(BuildContext context) {
    Widget tileWidget = GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: _getTileColor(),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected 
                ? Colors.yellow 
                : isHighlighted 
                    ? Colors.orange 
                    : Colors.black,
            width: isSelected || isHighlighted ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 4,
              offset: const Offset(2, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 牌面内容
            Text(
              tile.displayName,
              style: TextStyle(
                fontSize: width * 0.3,
                fontWeight: FontWeight.bold,
                color: _getTextColor(),
              ),
            ),
            if (tile.isNumberTile) ...[
              const SizedBox(height: 2),
              Text(
                _getTileSymbol(),
                style: TextStyle(
                  fontSize: width * 0.2,
                  color: _getTextColor(),
                ),
              ),
            ],
          ],
        ),
      ),
    );

    // 添加动画效果
    if (enableAnimation) {
      if (isSelected) {
        tileWidget = AnimationService.pulseAnimation(tileWidget);
      } else if (isHighlighted) {
        tileWidget = AnimationService.blinkAnimation(tileWidget);
      } else {
        tileWidget = AnimationService.tileAppearAnimation(tileWidget);
      }
    }

    return tileWidget;
  }

  Color _getTileColor() {
    switch (tile.type) {
      case TileType.wan:
        return Colors.red[100]!;
      case TileType.tiao:
        return Colors.green[100]!;
      case TileType.tong:
        return Colors.blue[100]!;
      case TileType.zi:
        return Colors.orange[100]!;
    }
  }

  Color _getTextColor() {
    switch (tile.type) {
      case TileType.wan:
        return Colors.red[800]!;
      case TileType.tiao:
        return Colors.green[800]!;
      case TileType.tong:
        return Colors.blue[800]!;
      case TileType.zi:
        return Colors.orange[800]!;
    }
  }

  String _getTileSymbol() {
    switch (tile.type) {
      case TileType.wan:
        return '万';
      case TileType.tiao:
        return '条';
      case TileType.tong:
        return '筒';
      case TileType.zi:
        return '';
    }
  }
}

class TileRowWidget extends StatelessWidget {
  final List<Tile> tiles;
  final double tileWidth;
  final double tileHeight;
  final Function(Tile, int)? onTileTap;
  final int? selectedIndex;

  const TileRowWidget({
    super.key,
    required this.tiles,
    this.tileWidth = 40,
    this.tileHeight = 60,
    this.onTileTap,
    this.selectedIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: tiles.asMap().entries.map((entry) {
        final index = entry.key;
        final tile = entry.value;
        
        return TileWidget(
          tile: tile,
          width: tileWidth,
          height: tileHeight,
          isSelected: selectedIndex == index,
          onTap: onTileTap != null ? () => onTileTap!(tile, index) : null,
        );
      }).toList(),
    );
  }
}
