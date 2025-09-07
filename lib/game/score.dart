import '../models/tile.dart';
import '../models/meld.dart';
import 'mahjong_rules.dart';

class ScoreResult {
  final List<String> patterns;
  final int fan; // 番数
  final int tai; // 台数（台湾通常 fan=台）
  final int score; // 换算成分数
  ScoreResult(this.patterns, this.fan, this.tai, this.score);
}

class ScoreCalculator {
  static ScoreResult evaluate({
    required List<Tile> concealed,
    required List<Meld> melds,
    required List<Tile> flowers,
    required bool selfDraw,
    required bool dealer,
  }) {
    final patterns = <String>[];
    int fan = 0;

    // 基础平胡
    if (MahjongRules.canWin(concealed)) {
      patterns.add("平胡");
      fan += 1;
    }

    // 碰碰胡：所有面子都是刻子
    if (_allPungs(concealed, melds)) {
      patterns.add("碰碰胡");
      fan += 2;
    }

    // 清一色
    if (_pureOneSuit(concealed, melds)) {
      patterns.add("清一色");
      fan += 6;
    }

    // 七对
    if (_sevenPairs(concealed)) {
      patterns.add("七对");
      fan += 4;
    }

    // 花牌
    if (flowers.isNotEmpty) {
      patterns.add("花牌 ${flowers.length} 张");
      fan += flowers.length;
    }

    // 自摸
    if (selfDraw) {
      patterns.add("自摸");
      fan += 1;
    }

    // 庄家
    if (dealer) {
      patterns.add("庄家");
      fan += 1;
    }

    int tai = fan; // 简化：番=台
    int score = tai * 1000; // 每台 1000 分（可调整）

    return ScoreResult(patterns, fan, tai, score);
  }

  static bool _allPungs(List<Tile> concealed, List<Meld> melds) {
    // 简化：有4刻子+1对就算碰碰胡
    return melds.every((m) =>
        m.type.toString().contains("pung") ||
        m.type.toString().contains("kong"));
  }

  static bool _pureOneSuit(List<Tile> concealed, List<Meld> melds) {
    final all = [...concealed, ...melds.expand((m) => m.tiles)];
    final suits = all.map((t) => t.suit).toSet();
    // 只允许一种花色（排除风/箭/花/季）
    if (suits.length == 1) return true;
    if (suits.length == 2 && suits.contains(TileSuit.wind)) return true;
    if (suits.length == 2 && suits.contains(TileSuit.dragon)) return true;
    return false;
  }

  static bool _sevenPairs(List<Tile> concealed) {
    if (concealed.length != 14) return false;
    final sorted = concealed.toList()..sort();
    for (int i = 0; i < 14; i += 2) {
      if (sorted[i].suit != sorted[i + 1].suit ||
          sorted[i].rank != sorted[i + 1].rank) return false;
    }
    return true;
  }
}
