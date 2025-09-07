import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../services/animation_service.dart';
import 'game_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _playerNameController = TextEditingController();
  final TextEditingController _gameIdController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _gameIdController.text = 'game_${DateTime.now().millisecondsSinceEpoch}';
  }

  @override
  void dispose() {
    _playerNameController.dispose();
    _gameIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF2E7D32), // 深绿色
              Color(0xFF4CAF50), // 绿色
              Color(0xFF8BC34A), // 浅绿色
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 标题
                AnimationService.gameStartAnimation(
                  const Text(
                    '台湾16张麻将',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          offset: Offset(2, 2),
                          blurRadius: 4,
                          color: Colors.black26,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Mahjong Game',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white70,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 60),
                
                // 游戏信息卡片
                AnimationService.tileAppearAnimation(
                  Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.casino,
                          size: 64,
                          color: Colors.green,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          '开始新游戏',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(height: 24),
                        
                        // 玩家姓名输入
                        TextField(
                          controller: _playerNameController,
                          decoration: InputDecoration(
                            labelText: '玩家姓名',
                            hintText: '请输入您的姓名',
                            prefixIcon: const Icon(Icons.person),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Colors.grey[50],
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // 游戏ID输入
                        TextField(
                          controller: _gameIdController,
                          decoration: InputDecoration(
                            labelText: '游戏房间ID',
                            hintText: '请输入游戏房间ID',
                            prefixIcon: const Icon(Icons.room),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Colors.grey[50],
                          ),
                        ),
                        const SizedBox(height: 24),
                        
                        // 开始游戏按钮
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _startGame,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 4,
                            ),
                            child: const Text(
                              '开始游戏',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                ),
                
                const SizedBox(height: 40),
                
                // 游戏规则说明
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '游戏规则',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          '• 台湾16张麻将，每人16张手牌\n'
                          '• 支持碰、杠、吃、胡等基本操作\n'
                          '• 支持多种胡牌类型和番型计算\n'
                          '• 支持单机多人游戏',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _startGame() {
    final playerName = _playerNameController.text.trim();
    final gameId = _gameIdController.text.trim();
    
    if (playerName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('请输入玩家姓名'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    if (gameId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('请输入游戏房间ID'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    // 创建游戏并添加玩家
    final gameProvider = Provider.of<GameProvider>(context, listen: false);
    gameProvider.createNewGame(gameId);
    gameProvider.addPlayer('player_1', playerName);
    
    // 添加AI玩家
    gameProvider.addPlayer('ai_1', 'AI玩家1');
    gameProvider.addPlayer('ai_2', 'AI玩家2');
    gameProvider.addPlayer('ai_3', 'AI玩家3');
    
    // 开始游戏
    if (gameProvider.startGame()) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const GameScreen(),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('游戏开始失败'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
