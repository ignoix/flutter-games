import 'tile.dart';
import 'player.dart';

/// 游戏状态枚举
enum GameStatus {
  waiting,    // 等待玩家
  playing,    // 游戏中
  paused,     // 暂停
  finished,   // 游戏结束
}

/// 游戏方向枚举
enum GameDirection {
  east,   // 东
  south,  // 南
  west,   // 西
  north,  // 北
}

/// 游戏状态类
class GameState {
  final String gameId;
  final List<Player> players;
  final List<Tile> wallTiles; // 牌墙
  final List<Tile> discardPile; // 弃牌堆
  final GameStatus status;
  final int currentPlayerIndex;
  final int dealerIndex;
  final GameDirection currentWind; // 当前风圈
  final int round; // 局数
  final int hand; // 手数
  final Tile? lastDiscardedTile; // 最后打出的牌
  final Player? lastDiscardingPlayer; // 最后打牌的玩家

  GameState({
    required this.gameId,
    required this.players,
    required this.wallTiles,
    required this.discardPile,
    this.status = GameStatus.waiting,
    this.currentPlayerIndex = 0,
    this.dealerIndex = 0,
    this.currentWind = GameDirection.east,
    this.round = 1,
    this.hand = 1,
    this.lastDiscardedTile,
    this.lastDiscardingPlayer,
  });

  /// 获取当前玩家
  Player? get currentPlayer {
    if (players.isEmpty || currentPlayerIndex >= players.length) return null;
    return players[currentPlayerIndex];
  }

  /// 获取庄家
  Player? get dealer {
    if (players.isEmpty || dealerIndex >= players.length) return null;
    return players[dealerIndex];
  }

  /// 获取玩家数量
  int get playerCount => players.length;

  /// 判断游戏是否可以开始
  bool get canStart => players.length == 4 && status == GameStatus.waiting;

  /// 判断是否为当前玩家的回合
  bool isCurrentPlayerTurn(String playerId) {
    final player = players.firstWhere(
      (p) => p.id == playerId,
      orElse: () => Player(id: '', name: ''),
    );
    return player.id.isNotEmpty && player.isCurrentPlayer;
  }

  /// 复制游戏状态
  GameState copyWith({
    String? gameId,
    List<Player>? players,
    List<Tile>? wallTiles,
    List<Tile>? discardPile,
    GameStatus? status,
    int? currentPlayerIndex,
    int? dealerIndex,
    GameDirection? currentWind,
    int? round,
    int? hand,
    Tile? lastDiscardedTile,
    Player? lastDiscardingPlayer,
  }) {
    return GameState(
      gameId: gameId ?? this.gameId,
      players: players ?? List.from(this.players),
      wallTiles: wallTiles ?? List.from(this.wallTiles),
      discardPile: discardPile ?? List.from(this.discardPile),
      status: status ?? this.status,
      currentPlayerIndex: currentPlayerIndex ?? this.currentPlayerIndex,
      dealerIndex: dealerIndex ?? this.dealerIndex,
      currentWind: currentWind ?? this.currentWind,
      round: round ?? this.round,
      hand: hand ?? this.hand,
      lastDiscardedTile: lastDiscardedTile ?? this.lastDiscardedTile,
      lastDiscardingPlayer: lastDiscardingPlayer ?? this.lastDiscardingPlayer,
    );
  }

  /// 创建新游戏
  static GameState createNewGame(String gameId) {
    final wallTiles = TileSet.shuffle(TileSet.createFullSet());
    return GameState(
      gameId: gameId,
      players: [],
      wallTiles: wallTiles,
      discardPile: [],
    );
  }

  /// 添加玩家
  GameState addPlayer(Player player) {
    if (players.length >= 4) return this;
    
    final newPlayers = List<Player>.from(players);
    newPlayers.add(player);
    
    return copyWith(players: newPlayers);
  }

  /// 移除玩家
  GameState removePlayer(String playerId) {
    final newPlayers = players.where((p) => p.id != playerId).toList();
    return copyWith(players: newPlayers);
  }

  /// 开始游戏
  GameState startGame() {
    if (!canStart) return this;

    // 发牌给每个玩家
    final newPlayers = <Player>[];
    final newWallTiles = List<Tile>.from(wallTiles);
    
    for (int i = 0; i < players.length; i++) {
      final player = players[i];
      final playerTiles = newWallTiles.sublist(0, 16);
      newWallTiles.removeRange(0, 16);
      
      newPlayers.add(player.copyWith(
        handTiles: TileSet.sort(playerTiles),
        isCurrentPlayer: i == 0, // 第一个玩家开始
      ));
    }

    return copyWith(
      players: newPlayers,
      wallTiles: newWallTiles,
      status: GameStatus.playing,
    );
  }

  /// 下一个玩家
  GameState nextPlayer() {
    final nextIndex = (currentPlayerIndex + 1) % players.length;
    final newPlayers = players.map((player) {
      return player.copyWith(isCurrentPlayer: player.id == players[nextIndex].id);
    }).toList();

    return copyWith(
      players: newPlayers,
      currentPlayerIndex: nextIndex,
    );
  }

  /// 玩家摸牌
  GameState drawTile(String playerId) {
    if (wallTiles.isEmpty) return this;

    final tile = wallTiles.removeLast();
    final newPlayers = players.map((player) {
      if (player.id == playerId) {
        return player.copyWith(handTiles: [...player.handTiles, tile]);
      }
      return player;
    }).toList();

    return copyWith(
      players: newPlayers,
      wallTiles: wallTiles,
    );
  }

  /// 玩家打牌
  GameState discardTile(String playerId, int tileIndex) {
    final playerIndex = players.indexWhere((p) => p.id == playerId);
    if (playerIndex == -1) return this;

    final player = players[playerIndex];
    final tile = player.discardTile(tileIndex);
    if (tile == null) return this;

    final newPlayers = List<Player>.from(players);
    newPlayers[playerIndex] = player;

    return copyWith(
      players: newPlayers,
      discardPile: [...discardPile, tile],
      lastDiscardedTile: tile,
      lastDiscardingPlayer: player,
    );
  }
}
