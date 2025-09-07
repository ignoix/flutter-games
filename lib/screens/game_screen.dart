import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../services/audio_service.dart';
import '../models/tile.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final AudioService _audioService = AudioService();

  @override
  void initState() {
    super.initState();
    // 播放背景音乐
    _audioService.playBackgroundMusic();
  }

  @override
  void dispose() {
    _audioService.stopBackgroundMusic();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B5E20), // 深绿色背景
      body: Consumer<GameProvider>(
        builder: (context, gameProvider, child) {
          final gameState = gameProvider.gameState;
          
          
          return _buildGameLayout(gameState, gameProvider);
        },
      ),
    );
  }

  Widget _buildGameLayout(gameState, gameProvider) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final screenHeight = constraints.maxHeight;
        
        // 计算各区域大小
        final sideWidth = screenWidth * 0.12; // 左右玩家区域
        final topHeight = screenHeight * 0.15; // 上方玩家区域
        final bottomHeight = screenHeight * 0.25; // 下方玩家区域（当前玩家需要更多空间）
        final centerWidth = screenWidth - sideWidth * 2;
        final centerHeight = screenHeight - topHeight - bottomHeight;
        
        return Stack(
          children: [
            // 背景麻将桌
            Positioned(
              left: sideWidth,
              top: topHeight,
              right: sideWidth,
              bottom: bottomHeight,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF2E7D32), // 深绿色麻将桌
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: _buildCenterArea(gameState, gameProvider),
              ),
            ),
            
            // 上方玩家 (东家)
            Positioned(
              top: 10,
              left: sideWidth + 20,
              right: sideWidth + 20,
              height: topHeight - 20,
              child: _buildTopPlayer(gameState.players.length > 1 ? gameState.players[1] : null),
            ),
            
            // 左侧玩家 (南家)
            Positioned(
              top: topHeight + 20,
              left: 10,
              width: sideWidth - 20,
              bottom: bottomHeight + 20,
              child: _buildLeftPlayer(gameState.players.length > 2 ? gameState.players[2] : null),
            ),
            
            // 右侧玩家 (北家)
            Positioned(
              top: topHeight + 20,
              right: 10,
              width: sideWidth - 20,
              bottom: bottomHeight + 20,
              child: _buildRightPlayer(gameState.players.length > 3 ? gameState.players[3] : null),
            ),
            
            // 下方玩家 (西家 - 当前玩家)
            Positioned(
              bottom: 10,
              left: sideWidth + 20,
              right: sideWidth + 20,
              height: bottomHeight - 20,
              child: _buildBottomPlayer(gameState.players.isNotEmpty ? gameState.players[0] : null, gameProvider),
            ),
          ],
        );
      },
    );
  }

  // 上方玩家 (东家)
  Widget _buildTopPlayer(player) {
    if (player == null) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 玩家头像和姓名
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 12,
                backgroundColor: Colors.blue,
                child: Text(
                  player.name[0],
                  style: const TextStyle(color: Colors.white, fontSize: 10),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                player.name,
                style: const TextStyle(
                  color: Colors.black, 
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          // 手牌显示
          _buildAIPlayerTiles(player.handTiles.length),
          const SizedBox(height: 2),
          // 分数
          Text(
            '${player.score}分',
            style: const TextStyle(color: Colors.grey, fontSize: 10),
          ),
        ],
      ),
    );
  }

  // 左侧玩家 (南家)
  Widget _buildLeftPlayer(player) {
    if (player == null) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: RotatedBox(
        quarterTurns: 1,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 玩家头像和姓名
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 12,
                  backgroundColor: Colors.green,
                  child: Text(
                    player.name[0],
                    style: const TextStyle(color: Colors.white, fontSize: 10),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  player.name,
                  style: const TextStyle(
                    color: Colors.black, 
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            // 手牌显示
            _buildAIPlayerTiles(player.handTiles.length),
            const SizedBox(height: 2),
            // 分数
            Text(
              '${player.score}分',
              style: const TextStyle(color: Colors.grey, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }

  // 右侧玩家 (北家)
  Widget _buildRightPlayer(player) {
    if (player == null) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: RotatedBox(
        quarterTurns: 3,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 玩家头像和姓名
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 12,
                  backgroundColor: Colors.orange,
                  child: Text(
                    player.name[0],
                    style: const TextStyle(color: Colors.white, fontSize: 10),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  player.name,
                  style: const TextStyle(
                    color: Colors.black, 
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            // 手牌显示
            _buildAIPlayerTiles(player.handTiles.length),
            const SizedBox(height: 2),
            // 分数
            Text(
              '${player.score}分',
              style: const TextStyle(color: Colors.grey, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }

  // 中央区域
  Widget _buildCenterArea(gameState, gameProvider) {
    return Column(
      children: [
        // 游戏信息
        Container(
          padding: const EdgeInsets.all(8),
          child: Text(
            '房间: ${gameState.gameId} | 牌墙: ${gameState.wallTiles.length}张',
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
        ),
        
        // 弃牌堆区域
        Expanded(
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: _buildDiscardPile(gameState),
          ),
        ),
      ],
    );
  }

  // 下方玩家（当前玩家 - 西家）
  Widget _buildBottomPlayer(player, gameProvider) {
    if (player == null) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        border: Border.all(color: Colors.red, width: 2),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 玩家信息 - 头像和姓名
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 12,
                backgroundColor: Colors.red,
                child: Text(
                  player.name[0],
                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '${player.name} (当前玩家)',
                style: const TextStyle(
                  color: Colors.black, 
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${player.score}分',
                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          
          // 手牌显示 - 计算合适的大小，确保能放下所有牌
          LayoutBuilder(
            builder: (context, constraints) {
              final availableWidth = constraints.maxWidth;
              final tileCount = player.handTiles.length;
              final tileWidth = (availableWidth - 20) / tileCount; // 减去边距
              final tileHeight = tileWidth * 1.4; // 保持比例
              
              return SizedBox(
                height: tileHeight,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: player.handTiles.asMap().entries.map<Widget>((entry) {
                    final index = entry.key;
                    final tile = entry.value;
                    return GestureDetector(
                      onTap: () => _onPlayerTileTap(gameProvider, tile, index),
                      child: Container(
                        width: tileWidth - 2,
                        height: tileHeight,
                        margin: const EdgeInsets.symmetric(horizontal: 1),
                        decoration: BoxDecoration(
                          color: _getTileColor(tile),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.black, width: 1),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 2,
                              offset: const Offset(1, 1),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              tile.name,
                              style: TextStyle(
                                fontSize: tileWidth * 0.25,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            if (tile.isNumberTile) ...[
                              const SizedBox(height: 1),
                              Text(
                                _getTileSymbol(tile),
                                style: TextStyle(
                                  fontSize: tileWidth * 0.18,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              );
            },
          ),
          
          const SizedBox(height: 4),
          
          // 操作按钮
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () => _onDrawTile(gameProvider),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  minimumSize: const Size(60, 28),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('摸牌', style: TextStyle(fontSize: 12)),
              ),
              ElevatedButton(
                onPressed: () => _checkWin(gameProvider),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  minimumSize: const Size(60, 28),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('胡牌', style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 弃牌堆 - 按方位摆放
  Widget _buildDiscardPile(gameState) {
    if (gameState.discardPile.isEmpty) {
      return const Center(
        child: Text(
          '弃牌区',
          style: TextStyle(color: Colors.white70, fontSize: 16),
        ),
      );
    }
    
    // 按玩家分组弃牌（简化版本）
    final Map<String, List<Tile>> playerDiscards = {};
    for (int i = 0; i < gameState.discardPile.length; i++) {
      final tile = gameState.discardPile[i];
      final playerId = 'player_${(i % 4) + 1}'; // 简单分组
      playerDiscards.putIfAbsent(playerId, () => <Tile>[]).add(tile);
    }
    
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        final availableHeight = constraints.maxHeight;
        final tileSize = (availableWidth / 10).clamp(15.0, 25.0); // 限制牌的大小
        
        return Column(
          children: [
            // 上方弃牌区
            SizedBox(
              height: availableHeight * 0.25,
              child: _buildPlayerDiscardArea(
                playerDiscards['player_2'] ?? [],
                tileSize,
                '上方',
              ),
            ),
            
            // 中间区域
            Expanded(
              child: Row(
                children: [
                  // 左侧弃牌区
                  Expanded(
                    child: _buildPlayerDiscardArea(
                      playerDiscards['player_3'] ?? [],
                      tileSize,
                      '左侧',
                    ),
                  ),
                  
                  // 中央信息
                  Expanded(
                    flex: 2,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '房间: ${gameState.gameId}',
                            style: const TextStyle(color: Colors.white, fontSize: 12),
                          ),
                          Text(
                            '牌墙: ${gameState.wallTiles.length}张',
                            style: const TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  // 右侧弃牌区
                  Expanded(
                    child: _buildPlayerDiscardArea(
                      playerDiscards['player_4'] ?? [],
                      tileSize,
                      '右侧',
                    ),
                  ),
                ],
              ),
            ),
            
            // 下方弃牌区
            SizedBox(
              height: availableHeight * 0.25,
              child: _buildPlayerDiscardArea(
                playerDiscards['player_1'] ?? [],
                tileSize,
                '下方',
              ),
            ),
          ],
        );
      },
    );
  }
  
  // 单个玩家的弃牌区域
  Widget _buildPlayerDiscardArea(List<Tile> tiles, double tileSize, String position) {
    if (tiles.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Container(
      padding: const EdgeInsets.all(2),
      child: Wrap(
        spacing: 1,
        runSpacing: 1,
        children: tiles.map<Widget>((tile) {
          return Container(
            width: tileSize,
            height: tileSize * 1.4,
            decoration: BoxDecoration(
              color: _getTileColor(tile),
              borderRadius: BorderRadius.circular(3),
              border: Border.all(color: Colors.black, width: 0.5),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  tile.name,
                  style: TextStyle(
                    fontSize: tileSize * 0.3,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                if (tile.isNumberTile) ...[
                  const SizedBox(height: 1),
                  Text(
                    _getTileSymbol(tile),
                    style: TextStyle(
                      fontSize: tileSize * 0.2,
                      color: Colors.black,
                    ),
                  ),
                ],
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  void _onPlayerTileTap(GameProvider gameProvider, tile, int index) {
    // 玩家点击手牌 - 先摸牌再打牌
    if (gameProvider.gameState.currentPlayer?.id == 'player_1') {
      // 先摸牌
      if (gameProvider.drawTile('player_1') != null) {
        _audioService.playDrawTileSound();
        
        // 延迟一点时间再打牌，让玩家看到摸到的牌
        Future.delayed(const Duration(milliseconds: 500), () {
          if (gameProvider.discardTile('player_1', index)) {
            _audioService.playDiscardTileSound();
            
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('打出: ${tile.name}'),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 1),
              ),
            );
          }
        });
      }
    }
  }

  void _onDrawTile(GameProvider gameProvider) {
    // 玩家摸牌
    final tile = gameProvider.drawTile('player_1');
    if (tile != null) {
      // 播放摸牌音效
      _audioService.playDrawTileSound();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('摸到: ${tile.name}'),
          backgroundColor: Colors.blue,
          duration: const Duration(seconds: 1),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('无法摸牌'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  void _checkWin(GameProvider gameProvider) {
    final player = gameProvider.getPlayer('player_1');
    if (player != null) {
      // 这里可以添加胡牌检查逻辑
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('胡牌检查功能开发中...'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  // 显示玩家的碰杠牌组
  Widget _buildPlayerMelds(melds, bool isHorizontal) {
    return SizedBox(
      height: 30,
      child: ListView.builder(
        scrollDirection: isHorizontal ? Axis.horizontal : Axis.vertical,
        itemCount: melds.length,
        itemBuilder: (context, index) {
          final meld = melds[index];
          return Container(
            margin: const EdgeInsets.all(2),
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            decoration: BoxDecoration(
              color: _getMeldColor(meld.type),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.white),
            ),
            child: Text(
              _getMeldTypeName(meld.type),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        },
      ),
    );
  }

  Color _getMeldColor(meldType) {
    switch (meldType.toString()) {
      case 'MeldType.peng':
        return Colors.blue;
      case 'MeldType.gang':
      case 'MeldType.anGang':
      case 'MeldType.mingGang':
        return Colors.red;
      case 'MeldType.chi':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _getMeldTypeName(meldType) {
    switch (meldType.toString()) {
      case 'MeldType.peng':
        return '碰';
      case 'MeldType.gang':
        return '杠';
      case 'MeldType.anGang':
        return '暗杠';
      case 'MeldType.mingGang':
        return '明杠';
      case 'MeldType.chi':
        return '吃';
      default:
        return '未知';
    }
  }

  // 获取牌的颜色
  Color _getTileColor(tile) {
    switch (tile.type.toString()) {
      case 'TileType.wan':
        return Colors.red[100]!;
      case 'TileType.tiao':
        return Colors.green[100]!;
      case 'TileType.tong':
        return Colors.blue[100]!;
      case 'TileType.zi':
        return Colors.orange[100]!;
      default:
        return Colors.grey[100]!;
    }
  }

  // 获取牌的符号
  String _getTileSymbol(tile) {
    switch (tile.type.toString()) {
      case 'TileType.wan':
        return '万';
      case 'TileType.tiao':
        return '条';
      case 'TileType.tong':
        return '筒';
      case 'TileType.zi':
        return '';
      default:
        return '';
    }
  }

  // 显示AI玩家的牌背面
  Widget _buildAIPlayerTiles(int tileCount) {
    return SizedBox(
      height: 30,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: tileCount,
        itemBuilder: (context, index) {
          return Container(
            width: 20,
            height: 25,
            margin: const EdgeInsets.all(1),
            decoration: BoxDecoration(
              color: Colors.brown[300],
              borderRadius: BorderRadius.circular(3),
              border: Border.all(color: Colors.brown[600]!, width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 2,
                  offset: const Offset(1, 1),
                ),
              ],
            ),
            child: Center(
              child: Text(
                '🀄',
                style: const TextStyle(fontSize: 12),
              ),
            ),
          );
        },
      ),
    );
  }
}
