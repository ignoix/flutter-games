import '../models/tile.dart';
import '../models/player.dart';
import 'mahjong_engine.dart';
import 'mahjong_rules.dart';

class SimpleAI {
  // 机器人在 react 阶段的决策：胡 > 杠 > 碰 >（若是上家）吃 > 过
  static bool react(MahjongEngine eng, int seat) {
    final p = eng.players[seat];
    final d = eng.lastDiscard;
    if (d == null) return false;

    // 尝试胡（这里简化为把 d 视为加入手牌再测 canWin）
    final canWin = MahjongRules.canWin([...p.hand, d]);
    if (canWin) {
      // 胡牌处理（这里只改变状态，具体结算留给你扩展）
      eng.lastDiscard = null; eng.lastDiscardSeat = -1;
      // 直接把 d 加入手中作为终局展示
      p.hand.add(d); p.sortHand();
      return true;
    }
    if (MahjongRules.canKongFromDiscard(d, p.hand)) return eng.claimKong(seat);
    if (MahjongRules.canPung(d, p.hand)) return eng.claimPung(seat);
    if (seat == (eng.lastDiscardSeat + 1) % 4) {
      final chows = MahjongRules.chowsFrom(d, p.hand);
      if (chows.isNotEmpty) {
        // 选第一组可吃
        final using = chows.first.where((t)=> t.id != d.id).toList();
        return eng.claimChow(seat, using);
      }
    }
    return false; // 过
  }

  // 机器人出牌：简单启发式——优先打花，其次孤张、幺九、字、断顺子的牌
  static void takeTurn(MahjongEngine eng) {
    final p = eng.players[eng.current];
    if (!eng.draw()) { return; } // 荒牌未处理
    // 优先暗杠/加杠
    if (eng.concealedKong()) { /* 补摸后继续 */ }
    if (eng.addKong()) { /* 补摸后继续 */ }

    // 选一张要打的牌
    Tile pick = _chooseDiscard(p);
    eng.discard(pick);

    // 其他人按顺序反应
    for (int i=1; i<=3; i++) {
      final seat = (eng.current + i) % 4;
      final claimed = react(eng, seat);
      if (claimed) return; // 该家吃/碰/杠/胡结束，轮到他出牌或结束
    }
    // 无人叫牌，进入下家
    eng.nextTurn();
  }

  static Tile _chooseDiscard(Player p) {
    // 评分：越低越先丢
    double score(Tile t) {
      if (t.isFlowerLike) return -100.0; // 立即打掉（实际上应补花，这里交给引擎处理）
      if (t.isHonor) return 2.0; // 字牌偏劣
      // 幺九
      if (t.rank == 1 || t.rank == 9) return 1.5;
      // 看顺子潜力：左右是否有邻近
      bool hasL(int r) => p.hand.any((x)=> x.suit==t.suit && x.rank==r);
      double pot = 0;
      for (final r in [t.rank-2, t.rank-1, t.rank+1, t.rank+2]) {
        if (r>=1 && r<=9 && hasL(r)) pot += 0.4;
      }
      return 3.0 - pot; // 潜力越大分越小
    }
    p.sortHand();
    p.hand.sort((a,b)=> score(a).compareTo(score(b)));
    return p.hand.first;
  }
}
