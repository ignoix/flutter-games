import 'dart:math';

enum TileSuit { man, pin, sou, wind, dragon, flower, season } // 花/季分开更直观
// honor: wind(E,S,W,N) dragon(zhong, fa, bai)

class Tile implements Comparable<Tile> {
  final TileSuit suit;
  final int rank; // 1-9 for man/pin/sou; wind:1:E 2:S 3:W 4:N; dragon:1:中 2:发 3:白; flower:1..4; season:1..4
  final String id; // 唯一标识（洗牌后保留）

  const Tile(this.suit, this.rank, this.id);

  bool get isHonor => suit == TileSuit.wind || suit == TileSuit.dragon;
  bool get isFlowerLike => suit == TileSuit.flower || suit == TileSuit.season;

  String get short {
    switch (suit) {
      case TileSuit.man: return '${rank}m';
      case TileSuit.pin: return '${rank}p';
      case TileSuit.sou: return '${rank}s';
      case TileSuit.wind: return ['X','E','S','W','N'][rank];
      case TileSuit.dragon: return ['X','Z','F','B'][rank];
      case TileSuit.flower: return 'F$rank';
      case TileSuit.season: return 'S$rank';
    }
  }

  @override
  int compareTo(Tile other) {
    int s = suit.index.compareTo(other.suit.index);
    if (s != 0) return s;
    return rank.compareTo(other.rank);
  }

  static List<Tile> fullSet({bool includeFlowers = true}) {
    final List<Tile> tiles = [];
    String uid(int i) => 't$i';
    int c = 0;
    void push(TileSuit s, int r, int copies) {
      for (int i=0;i<copies;i++) tiles.add(Tile(s, r, uid(c++)));
    }
    // 数牌 1–9 各4
    for (int r=1; r<=9; r++) { push(TileSuit.man, r, 4); push(TileSuit.pin, r, 4); push(TileSuit.sou, r, 4); }
    // 风 4种各4
    for (int r=1; r<=4; r++) push(TileSuit.wind, r, 4);
    // 箭 3种各4
    for (int r=1; r<=3; r++) push(TileSuit.dragon, r, 4);
    if (includeFlowers) {
      for (int r=1; r<=4; r++) push(TileSuit.flower, r, 1);
      for (int r=1; r<=4; r++) push(TileSuit.season, r, 1);
    }
    tiles.shuffle(Random());
    return tiles;
  }
}
