import 'package:flutter/material.dart';
import '../models/player.dart';
import '../models/tile.dart';
import 'tile_widget.dart';

class PlayerHandWidget extends StatefulWidget {
  final Player player;
  final Function(Tile, int)? onTileTap;
  final VoidCallback? onDrawTile;

  const PlayerHandWidget({
    super.key,
    required this.player,
    this.onTileTap,
    this.onDrawTile,
  });

  @override
  State<PlayerHandWidget> createState() => _PlayerHandWidgetState();
}

class _PlayerHandWidgetState extends State<PlayerHandWidget> {
  int? selectedTileIndex;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // 玩家信息
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.player.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  Text(
                    '分数: ${widget.player.score}',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 16),
                  if (widget.player.isDealer)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.yellow,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        '庄家',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // 手牌区域
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: widget.player.isCurrentPlayer 
                    ? Colors.yellow 
                    : Colors.white.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Column(
              children: [
                // 手牌
                if (widget.player.handTiles.isNotEmpty)
                  TileRowWidget(
                    tiles: widget.player.handTiles,
                    tileWidth: 35,
                    tileHeight: 50,
                    selectedIndex: selectedTileIndex,
                    onTileTap: _onTileTap,
                  )
                else
                  const Text(
                    '暂无手牌',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                
                const SizedBox(height: 12),
                
                // 已碰杠的牌组
                if (widget.player.melds.isNotEmpty) ...[
                  const Text(
                    '已碰杠牌组:',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: widget.player.melds.map((meld) {
                      return Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              _getMeldTypeName(meld.type),
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 4),
                            TileRowWidget(
                              tiles: meld.tiles,
                              tileWidth: 20,
                              tileHeight: 30,
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 操作按钮
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // 摸牌按钮
              ElevatedButton.icon(
                onPressed: widget.onDrawTile,
                icon: const Icon(Icons.add),
                label: const Text('摸牌'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
              
              // 打牌按钮
              ElevatedButton.icon(
                onPressed: selectedTileIndex != null ? _discardTile : null,
                icon: const Icon(Icons.remove),
                label: const Text('打牌'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: selectedTileIndex != null 
                      ? Colors.red 
                      : Colors.grey,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
              
              // 胡牌按钮
              ElevatedButton.icon(
                onPressed: _checkWin,
                icon: const Icon(Icons.emoji_events),
                label: const Text('胡牌'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _onTileTap(Tile tile, int index) {
    setState(() {
      selectedTileIndex = selectedTileIndex == index ? null : index;
    });
  }

  void _discardTile() {
    if (selectedTileIndex != null && widget.onTileTap != null) {
      final tile = widget.player.handTiles[selectedTileIndex!];
      widget.onTileTap!(tile, selectedTileIndex!);
      setState(() {
        selectedTileIndex = null;
      });
    }
  }

  void _checkWin() {
    // 检查是否可以胡牌
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('胡牌检查'),
        content: const Text('检查胡牌功能正在开发中...'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  String _getMeldTypeName(meldType) {
    switch (meldType.toString()) {
      case 'MeldType.peng':
        return '碰';
      case 'MeldType.gang':
        return '杠';
      case 'MeldType.chi':
        return '吃';
      case 'MeldType.anGang':
        return '暗杠';
      case 'MeldType.mingGang':
        return '明杠';
      default:
        return '未知';
    }
  }
}
