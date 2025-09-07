import '../models/tile.dart';
import '../models/meld.dart';

class MahjongRules {
  // --- 判定可吃 ---
  // 只能吃上家，且仅针对数牌顺子
  static List<List<Tile>> chowsFrom(Tile discarded, List<Tile> hand) {
    if (!(discarded.suit == TileSuit.man || discarded.suit == TileSuit.pin || discarded.suit == TileSuit.sou)) {
      return [];
    }
    final r = discarded.rank;
    List<List<int>> patterns = [];
    if (r >= 3) patterns.add([r-2, r-1, r]); // x-2, x-1, x
    if (r >= 2 && r <= 8) patterns.add([r-1, r, r+1]);
    if (r <= 7) patterns.add([r, r+1, r+2]);
    List<List<Tile>> results = [];
    for (final pat in patterns) {
      final need = pat.where((v) => v != r).toList();
      final a = hand.where((t) => t.suit == discarded.suit && t.rank == need[0]).toList();
      final b = hand.where((t) => t.suit == discarded.suit && t.rank == need[1]).toList();
      if (a.isNotEmpty && b.isNotEmpty) {
        results.add([
          hand.firstWhere((t)=> t.suit==discarded.suit && t.rank==need[0]),
          discarded,
          hand.firstWhere((t)=> t.suit==discarded.suit && t.rank==need[1]),
        ]..sort());
      }
    }
    // 去重
    final seen = <String>{};
    return results.where((m){
      final key = m.map((e)=>'${e.suit.index}-${e.rank}').join(',');
      if (seen.contains(key)) return false; seen.add(key); return true;
    }).toList();
  }

  // --- 判定可碰 ---
  static bool canPung(Tile discarded, List<Tile> hand) {
    return hand.where((t) => t.suit == discarded.suit && t.rank == discarded.rank).length >= 2;
  }

  // --- 判定可明杠/暗杠/加杠 ---
  static bool canKongFromDiscard(Tile discarded, List<Tile> hand) {
    return hand.where((t) => t.suit == discarded.suit && t.rank == discarded.rank).length >= 3;
  }

  static List<Tile> concealedKongCandidates(List<Tile> hand) {
    final map = <String, List<Tile>>{};
    for (final t in hand) {
      final k = '${t.suit.index}-${t.rank}';
      (map[k] ??= []).add(t);
    }
    return map.values.where((g) => g.length == 4).map((g) => g.first).toList();
  }

  // 加杠：已有碰，再补第4张
  static List<Tile> addKongCandidates(List<Tile> hand, List<Meld> melds) {
    final pungs = melds.where((m) => m.type == MeldType.pung);
    final List<Tile> res = [];
    for (final p in pungs) {
      final base = p.tiles.first;
      final has = hand.any((t) => t.suit == base.suit && t.rank == base.rank);
      if (has) res.add(base);
    }
    return res;
  }

  // --- 基础胡牌（七对/特殊牌型未实现）：4面子1雀头 + 手牌张数校验 ---
  static bool canWin(List<Tile> concealedTiles) {
    // 16张制，摸牌后应为17张；自摸时去掉打出的 1 张 => 16 张；和型仍是 4 面子 + 1 将（14 张）+ 2 张附加？
    // 台湾 16 张常见做法：判和时以「去掉最后摸张」的 14 张尝试标准胡型；这里给出简化近似：
    if (concealedTiles.length % 3 != 2) return false;
    final tiles = concealedTiles.toList()..sort();
    return _standardWin(tiles);
  }

  static bool _standardWin(List<Tile> tiles) {
    // 尝试所有将眼
    for (int i=0; i<tiles.length-1; i++) {
      if (tiles[i].suit == tiles[i+1].suit && tiles[i].rank == tiles[i+1].rank) {
        final remain = tiles.toList()..removeAt(i+1)..removeAt(i);
        if (_canFormMelds(remain)) return true;
      }
    }
    return false;
  }

  static bool _canFormMelds(List<Tile> tiles) {
    if (tiles.isEmpty) return true;
    tiles.sort();
    final t0 = tiles.first;
    // 刻子
    final same = tiles.where((t)=> t.suit==t0.suit && t.rank==t0.rank).toList();
    if (same.length >= 3) {
      final next = tiles.toList();
      next.removeRange(0, 3);
      if (_canFormMelds(next)) return true;
    }
    // 顺子（仅数牌）
    if (t0.suit == TileSuit.man || t0.suit == TileSuit.pin || t0.suit == TileSuit.sou) {
      bool has(int r) => tiles.any((t)=> t.suit==t0.suit && t.rank==r);
      if (has(t0.rank+1) && has(t0.rank+2)) {
        final next = tiles.toList();
        // remove t0, r+1, r+2
        Tile take(int r){
          final idx = next.indexWhere((t)=> t.suit==t0.suit && t.rank==r);
          return next.removeAt(idx);
        }
        take(t0.rank);
        take(t0.rank+1);
        take(t0.rank+2);
        if (_canFormMelds(next)) return true;
      }
    }
    return false;
  }
}
