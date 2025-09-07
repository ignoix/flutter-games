import 'package:flutter/foundation.dart';
import '../models/game_state.dart';
import '../models/player.dart';
import '../models/tile.dart';
import '../game_logic/mahjong_rules.dart';

/// 游戏控制器
class GameProvider extends ChangeNotifier {
  GameState _gameState = GameState.createNewGame('default');
  
  GameState get gameState => _gameState;
  
  GameProvider() {
    _initializeGame();
  }
  
  /// 初始化游戏，添加玩家并开始游戏
  void _initializeGame() {
    // 添加玩家
    addPlayer('player_1', '玩家');
    addPlayer('ai_2', 'AI玩家1');
    addPlayer('ai_3', 'AI玩家2');
    addPlayer('ai_4', 'AI玩家3');
    
    // 开始游戏
    startGame();
  }

  /// 创建新游戏
  void createNewGame(String gameId) {
    _gameState = GameState.createNewGame(gameId);
    notifyListeners();
  }

  /// 添加玩家
  bool addPlayer(String playerId, String playerName) {
    if (_gameState.playerCount >= 4) return false;
    
    final player = Player(
      id: playerId,
      name: playerName,
      isDealer: _gameState.playerCount == 0, // 第一个玩家是庄家
    );
    
    _gameState = _gameState.addPlayer(player);
    notifyListeners();
    return true;
  }

  /// 移除玩家
  void removePlayer(String playerId) {
    _gameState = _gameState.removePlayer(playerId);
    notifyListeners();
  }

  /// 开始游戏
  bool startGame() {
    if (!_gameState.canStart) return false;
    
    _gameState = _gameState.startGame();
    
    // 如果第一个玩家是AI，自动执行
    if (_gameState.currentPlayer != null && _gameState.currentPlayer!.id.startsWith('ai_')) {
      Future.delayed(const Duration(milliseconds: 1000), () {
        _executeAITurn();
      });
    }
    
    notifyListeners();
    return true;
  }

  /// 玩家摸牌
  Tile? drawTile(String playerId) {
    if (_gameState.wallTiles.isEmpty) return null;
    if (!_gameState.isCurrentPlayerTurn(playerId)) return null;
    
    final tile = _gameState.wallTiles.last;
    _gameState = _gameState.drawTile(playerId);
    notifyListeners();
    return tile;
  }

  /// 玩家打牌
  bool discardTile(String playerId, int tileIndex) {
    if (!_gameState.isCurrentPlayerTurn(playerId)) return false;
    
    _gameState = _gameState.discardTile(playerId, tileIndex);
    
    // 检查其他玩家是否可以碰、杠、吃、胡
    _checkOtherPlayersActions(playerId);
    
    // 转到下一个玩家
    _gameState = _gameState.nextPlayer();
    
    // 如果是AI玩家，自动执行动作
    if (_gameState.currentPlayer != null && _gameState.currentPlayer!.id.startsWith('ai_')) {
      _executeAITurn();
    }
    
    notifyListeners();
    return true;
  }

  /// 检查其他玩家的动作
  void _checkOtherPlayersActions(String discardingPlayerId) {
    final discardedTile = _gameState.lastDiscardedTile;
    if (discardedTile == null) return;
    
    for (final player in _gameState.players) {
      if (player.id == discardingPlayerId) continue;
      
      // 检查是否可以胡牌
      if (MahjongRules.canWin([...player.handTiles, discardedTile])) {
        // 触发胡牌
        _handleWin(player, discardedTile, WinType.normal);
        return;
      }
      
      // 检查是否可以杠牌
      if (MahjongRules.canGang(player.handTiles, discardedTile)) {
        // 触发杠牌
        _handleGang(player, discardedTile);
        return;
      }
      
      // 检查是否可以碰牌
      if (MahjongRules.canPeng(player.handTiles, discardedTile)) {
        // 触发碰牌
        _handlePeng(player, discardedTile);
        return;
      }
      
      // 检查是否可以吃牌
      if (MahjongRules.canChi(player.handTiles, discardedTile)) {
        // 触发吃牌
        _handleChi(player, discardedTile);
        return;
      }
    }
  }

  /// 处理胡牌
  void _handleWin(Player player, Tile winningTile, WinType winType) {
    // 添加胡牌到玩家手牌
    final newHandTiles = [...player.handTiles, winningTile];
    
    // 计算番数
    final fans = MahjongRules.calculateFan(newHandTiles, winType);
    
    // 更新玩家分数
    final newPlayer = player.copyWith(
      handTiles: newHandTiles,
      score: player.score + _calculateScore(fans),
    );
    
    // 更新游戏状态
    final newPlayers = _gameState.players.map((p) {
      return p.id == player.id ? newPlayer : p;
    }).toList();
    
    _gameState = _gameState.copyWith(
      players: newPlayers,
      status: GameStatus.finished,
    );
  }

  /// 处理杠牌
  void _handleGang(Player player, Tile gangTile) {
    // 创建杠牌组
    final gangTiles = player.handTiles
        .where((tile) => tile.name == gangTile.name)
        .take(3)
        .toList();
    gangTiles.add(gangTile);
    
    final meld = Meld.gang(gangTiles, gangTile);
    
    // 更新玩家手牌
    final newHandTiles = List<Tile>.from(player.handTiles);
    for (final tile in gangTiles) {
      newHandTiles.remove(tile);
    }
    
    final newPlayer = player.copyWith(
      handTiles: newHandTiles,
      melds: [...player.melds, meld],
    );
    
    // 更新游戏状态
    final newPlayers = _gameState.players.map((p) {
      return p.id == player.id ? newPlayer : p;
    }).toList();
    
    _gameState = _gameState.copyWith(players: newPlayers);
  }

  /// 处理碰牌
  void _handlePeng(Player player, Tile pengTile) {
    // 创建碰牌组
    final pengTiles = player.handTiles
        .where((tile) => tile.name == pengTile.name)
        .take(2)
        .toList();
    pengTiles.add(pengTile);
    
    final meld = Meld.peng(pengTiles, pengTile);
    
    // 更新玩家手牌
    final newHandTiles = List<Tile>.from(player.handTiles);
    for (final tile in pengTiles) {
      newHandTiles.remove(tile);
    }
    
    final newPlayer = player.copyWith(
      handTiles: newHandTiles,
      melds: [...player.melds, meld],
    );
    
    // 更新游戏状态
    final newPlayers = _gameState.players.map((p) {
      return p.id == player.id ? newPlayer : p;
    }).toList();
    
    _gameState = _gameState.copyWith(players: newPlayers);
  }

  /// 处理吃牌
  void _handleChi(Player player, Tile chiTile) {
    // 这里需要更复杂的逻辑来确定吃牌的组合
    // 简化处理，暂时跳过
  }

  /// 计算分数
  int _calculateScore(List<FanType> fans) {
    int score = 0;
    for (final fan in fans) {
      switch (fan) {
        case FanType.pingHu:
          score += 1;
          break;
        case FanType.qiDui:
          score += 2;
          break;
        case FanType.qingYiSe:
          score += 4;
          break;
        case FanType.hunYiSe:
          score += 2;
          break;
        case FanType.ziYiSe:
          score += 8;
          break;
        case FanType.shiSanYao:
          score += 13;
          break;
        case FanType.jiuLianBaoDeng:
          score += 13;
          break;
        default:
          score += 1;
      }
    }
    return score;
  }

  /// 重置游戏
  void resetGame() {
    _gameState = GameState.createNewGame(_gameState.gameId);
    notifyListeners();
  }

  /// 获取玩家
  Player? getPlayer(String playerId) {
    try {
      return _gameState.players.firstWhere((p) => p.id == playerId);
    } catch (e) {
      return null;
    }
  }

  /// 检查游戏是否结束
  bool get isGameFinished => _gameState.status == GameStatus.finished;

  /// 检查是否可以开始游戏
  bool get canStartGame => _gameState.canStart;

  /// 执行AI回合
  void _executeAITurn() {
    final currentPlayer = _gameState.currentPlayer;
    if (currentPlayer == null || !currentPlayer.id.startsWith('ai_')) return;

    // AI摸牌
    final drawnTile = _gameState.wallTiles.isNotEmpty ? _gameState.wallTiles.last : null;
    if (drawnTile != null) {
      _gameState = _gameState.drawTile(currentPlayer.id);
    }

    // AI简单策略：随机打出一张牌
    if (currentPlayer.handTiles.isNotEmpty) {
      final randomIndex = (currentPlayer.handTiles.length * 0.3).floor(); // 倾向于打出前面的牌
      _gameState = _gameState.discardTile(currentPlayer.id, randomIndex);
      
      // 检查其他玩家是否可以碰、杠、吃、胡
      _checkOtherPlayersActions(currentPlayer.id);
      
      // 转到下一个玩家
      _gameState = _gameState.nextPlayer();
      
      // 如果下一个还是AI，继续执行
      if (_gameState.currentPlayer != null && _gameState.currentPlayer!.id.startsWith('ai_')) {
        Future.delayed(const Duration(milliseconds: 1000), () {
          _executeAITurn();
        });
      }
    }
  }
}
