import 'package:flutter/material.dart';
import '../models/game_state.dart';

class GameInfoWidget extends StatelessWidget {
  final GameState gameState;

  const GameInfoWidget({
    super.key,
    required this.gameState,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 游戏状态
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _getGameStatusText(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '房间ID: ${gameState.gameId}',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          
          // 游戏信息
          Row(
            children: [
              _buildInfoCard(
                icon: Icons.people,
                label: '玩家',
                value: '${gameState.playerCount}/4',
              ),
              const SizedBox(width: 16),
              _buildInfoCard(
                icon: Icons.casino,
                label: '牌墙',
                value: '${gameState.wallTiles.length}',
              ),
              const SizedBox(width: 16),
              _buildInfoCard(
                icon: Icons.flag,
                label: '风圈',
                value: _getWindText(gameState.currentWind),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 16,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  String _getGameStatusText() {
    switch (gameState.status) {
      case GameStatus.waiting:
        return '等待玩家加入...';
      case GameStatus.playing:
        return '游戏进行中';
      case GameStatus.paused:
        return '游戏暂停';
      case GameStatus.finished:
        return '游戏结束';
    }
  }

  String _getWindText(GameDirection wind) {
    switch (wind) {
      case GameDirection.east:
        return '东';
      case GameDirection.south:
        return '南';
      case GameDirection.west:
        return '西';
      case GameDirection.north:
        return '北';
    }
  }
}
