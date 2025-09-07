import 'tile.dart';

/// 玩家类
class Player {
  final String id;
  final String name;
  List<Tile> handTiles; // 手牌
  List<Tile> discardedTiles; // 已打出的牌
  List<Meld> melds; // 已碰、杠、吃的牌组
  int score; // 分数
  bool isDealer; // 是否为庄家
  bool isCurrentPlayer; // 是否为当前玩家

  Player({
    required this.id,
    required this.name,
    List<Tile>? handTiles,
    List<Tile>? discardedTiles,
    List<Meld>? melds,
    this.score = 0,
    this.isDealer = false,
    this.isCurrentPlayer = false,
  }) : handTiles = handTiles ?? [],
       discardedTiles = discardedTiles ?? [],
       melds = melds ?? [];

  /// 添加手牌
  void addHandTile(Tile tile) {
    handTiles.add(tile);
    handTiles = TileSet.sort(handTiles);
  }

  /// 移除手牌
  bool removeHandTile(Tile tile) {
    return handTiles.remove(tile);
  }

  /// 打牌
  Tile? discardTile(int index) {
    if (index >= 0 && index < handTiles.length) {
      final tile = handTiles.removeAt(index);
      discardedTiles.add(tile);
      return tile;
    }
    return null;
  }

  /// 添加牌组（碰、杠、吃）
  void addMeld(Meld meld) {
    melds.add(meld);
  }

  /// 获取所有牌（手牌 + 牌组中的牌）
  List<Tile> getAllTiles() {
    final allTiles = List<Tile>.from(handTiles);
    for (final meld in melds) {
      allTiles.addAll(meld.tiles);
    }
    return allTiles;
  }

  /// 复制玩家对象
  Player copyWith({
    String? id,
    String? name,
    List<Tile>? handTiles,
    List<Tile>? discardedTiles,
    List<Meld>? melds,
    int? score,
    bool? isDealer,
    bool? isCurrentPlayer,
  }) {
    return Player(
      id: id ?? this.id,
      name: name ?? this.name,
      handTiles: handTiles ?? List.from(this.handTiles),
      discardedTiles: discardedTiles ?? List.from(this.discardedTiles),
      melds: melds ?? List.from(this.melds),
      score: score ?? this.score,
      isDealer: isDealer ?? this.isDealer,
      isCurrentPlayer: isCurrentPlayer ?? this.isCurrentPlayer,
    );
  }
}

/// 牌组类型枚举
enum MeldType {
  peng,    // 碰
  gang,    // 杠
  chi,     // 吃
  anGang,  // 暗杠
  mingGang, // 明杠
}

/// 牌组类（碰、杠、吃）
class Meld {
  final MeldType type;
  final List<Tile> tiles;
  final Tile? fromPlayer; // 来自哪个玩家的牌（用于碰、杠、吃）

  Meld({
    required this.type,
    required this.tiles,
    this.fromPlayer,
  });

  /// 创建碰牌
  factory Meld.peng(List<Tile> tiles, Tile fromPlayer) {
    return Meld(
      type: MeldType.peng,
      tiles: tiles,
      fromPlayer: fromPlayer,
    );
  }

  /// 创建杠牌
  factory Meld.gang(List<Tile> tiles, Tile fromPlayer, {bool isAnGang = false}) {
    return Meld(
      type: isAnGang ? MeldType.anGang : MeldType.mingGang,
      tiles: tiles,
      fromPlayer: fromPlayer,
    );
  }

  /// 创建吃牌
  factory Meld.chi(List<Tile> tiles, Tile fromPlayer) {
    return Meld(
      type: MeldType.chi,
      tiles: tiles,
      fromPlayer: fromPlayer,
    );
  }

  /// 判断是否为杠牌
  bool get isGang => type == MeldType.gang || type == MeldType.anGang || type == MeldType.mingGang;

  /// 判断是否为暗杠
  bool get isAnGang => type == MeldType.anGang;

  /// 判断是否为明杠
  bool get isMingGang => type == MeldType.mingGang;

  /// 判断是否为碰牌
  bool get isPeng => type == MeldType.peng;

  /// 判断是否为吃牌
  bool get isChi => type == MeldType.chi;
}
