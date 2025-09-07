import 'package:flutter/material.dart';
import '../models/tile.dart';
import 'tile_widget.dart';

class DiscardPileWidget extends StatelessWidget {
  final List<Tile> discardPile;
  final Function(Tile)? onTileTap;

  const DiscardPileWidget({
    super.key,
    required this.discardPile,
    this.onTileTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          const Text(
            '弃牌堆',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '共 ${discardPile.length} 张牌',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          
          // 弃牌显示区域
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: discardPile.isEmpty
                ? const Center(
                    child: Text(
                      '暂无弃牌',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                  )
                : SingleChildScrollView(
                    child: Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: discardPile.asMap().entries.map((entry) {
                        final index = entry.key;
                        final tile = entry.value;
                        
                        return GestureDetector(
                          onTap: onTileTap != null ? () => onTileTap!(tile) : null,
                          child: TileWidget(
                            tile: tile,
                            width: 30,
                            height: 45,
                            isHighlighted: index == discardPile.length - 1, // 最后一张牌高亮
                          ),
                        );
                      }).toList(),
                    ),
                  ),
          ),
          
          const SizedBox(height: 16),
          
          // 最后打出的牌
          if (discardPile.isNotEmpty) ...[
            const Text(
              '最后打出:',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            TileWidget(
              tile: discardPile.last,
              width: 50,
              height: 75,
              isHighlighted: true,
            ),
          ],
        ],
      ),
    );
  }
}
