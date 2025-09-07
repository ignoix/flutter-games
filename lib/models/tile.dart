/// 麻将牌类型枚举
enum TileType {
  wan,    // 万子
  tiao,   // 条子
  tong,   // 筒子
  zi,     // 字牌
}

/// 麻将牌类
class Tile {
  final int id;
  final TileType type;
  final int value;
  final String name;
  final String displayName;
  final String imagePath;

  const Tile({
    required this.id,
    required this.type,
    required this.value,
    required this.name,
    required this.displayName,
    required this.imagePath,
  });

  /// 创建万子牌
  factory Tile.wan(int value) {
    return Tile(
      id: value,
      type: TileType.wan,
      value: value,
      name: '$value万',
      displayName: '$value万',
      imagePath: 'assets/images/tiles/wan_$value.png',
    );
  }

  /// 创建条子牌
  factory Tile.tiao(int value) {
    return Tile(
      id: value + 10,
      type: TileType.tiao,
      value: value,
      name: '$value条',
      displayName: '$value条',
      imagePath: 'assets/images/tiles/tiao_$value.png',
    );
  }

  /// 创建筒子牌
  factory Tile.tong(int value) {
    return Tile(
      id: value + 20,
      type: TileType.tong,
      value: value,
      name: '$value筒',
      displayName: '$value筒',
      imagePath: 'assets/images/tiles/tong_$value.png',
    );
  }

  /// 创建字牌
  factory Tile.zi(String value) {
    final ziValues = ['东', '南', '西', '北', '中', '发', '白'];
    final index = ziValues.indexOf(value);
    return Tile(
      id: index + 30,
      type: TileType.zi,
      value: index,
      name: value,
      displayName: value,
      imagePath: 'assets/images/tiles/zi_$value.png',
    );
  }

  /// 判断是否为数字牌（万、条、筒）
  bool get isNumberTile => type != TileType.zi;

  /// 判断是否为字牌
  bool get isZiTile => type == TileType.zi;

  /// 判断是否为风牌（东南西北）
  bool get isWindTile => type == TileType.zi && value < 4;

  /// 判断是否为箭牌（中发白）
  bool get isArrowTile => type == TileType.zi && value >= 4;

  /// 获取牌的排序值（用于排序）
  int get sortValue {
    switch (type) {
      case TileType.wan:
        return value;
      case TileType.tiao:
        return value + 10;
      case TileType.tong:
        return value + 20;
      case TileType.zi:
        return value + 30;
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Tile && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => name;

  /// 复制牌对象
  Tile copyWith({
    int? id,
    TileType? type,
    int? value,
    String? name,
    String? displayName,
    String? imagePath,
  }) {
    return Tile(
      id: id ?? this.id,
      type: type ?? this.type,
      value: value ?? this.value,
      name: name ?? this.name,
      displayName: displayName ?? this.displayName,
      imagePath: imagePath ?? this.imagePath,
    );
  }
}

/// 牌组类
class TileSet {
  static List<Tile> createFullSet() {
    final List<Tile> tiles = [];

    // 万子 1-9 (每种4张)
    for (int i = 1; i <= 9; i++) {
      for (int j = 0; j < 4; j++) {
        tiles.add(Tile.wan(i));
      }
    }

    // 条子 1-9 (每种4张)
    for (int i = 1; i <= 9; i++) {
      for (int j = 0; j < 4; j++) {
        tiles.add(Tile.tiao(i));
      }
    }

    // 筒子 1-9 (每种4张)
    for (int i = 1; i <= 9; i++) {
      for (int j = 0; j < 4; j++) {
        tiles.add(Tile.tong(i));
      }
    }

    // 字牌 (每种4张)
    const ziTiles = ['东', '南', '西', '北', '中', '发', '白'];
    for (String zi in ziTiles) {
      for (int j = 0; j < 4; j++) {
        tiles.add(Tile.zi(zi));
      }
    }

    return tiles;
  }

  /// 洗牌
  static List<Tile> shuffle(List<Tile> tiles) {
    final shuffled = List<Tile>.from(tiles);
    shuffled.shuffle();
    return shuffled;
  }

  /// 排序牌
  static List<Tile> sort(List<Tile> tiles) {
    final sorted = List<Tile>.from(tiles);
    sorted.sort((a, b) => a.sortValue.compareTo(b.sortValue));
    return sorted;
  }
}
