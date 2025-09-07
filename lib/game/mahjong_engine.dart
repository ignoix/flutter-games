import '../models/tile.dart';
import '../models/player.dart';
import '../models/meld.dart';
import 'mahjong_rules.dart';

enum TurnPhase { draw, discard, react } // 摸牌、出牌、他家反应
enum Reaction { none, chow, pung, kong, win }

class MahjongEngine {
  final List<Player> players = List.generate(4, (i) => Player(i));
  late List<Tile> wall;
  int dealer = 0;      // 庄家 seat
  int current = 0;     // 当前行动 seat
  Tile? lastDiscard;   // 刚打出的牌
  int lastDiscardSeat = -1;
  TurnPhase phase = TurnPhase.draw;
  int round = 0;       // 东1 etc.（简单处理）
  final bool withFlowers = true;

  void newGame({int dealerSeat = 0}) {
    dealer = dealerSeat;
    round = 0;
    _newHand();
  }

  void _newHand() {
    wall = Tile.fullSet(includeFlowers: withFlowers);
    for (final p in players) {
      p.hand.clear(); p.melds.clear(); p.flowers.clear(); p.river.clear();
    }
    // 发牌：庄16，闲家16（台湾十六张皆 16）
    for (int r=0; r<16; r++) {
      for (int i=0; i<4; i++) {
        players[(dealer + i) % 4].hand.add(wall.removeLast());
      }
    }
    for (final p in players) _handleFlowers(p, drawUntilNoFlower: true);
    for (final p in players) p.sortHand();
    current = dealer;
    phase = TurnPhase.draw;
    lastDiscard = null; lastDiscardSeat = -1;
  }

  bool draw() {
    if (wall.isEmpty) return false; // 荒牌
    final p = players[current];
    p.hand.add(wall.removeLast());
    _handleFlowers(p, drawUntilNoFlower: true);
    p.sortHand();
    phase = TurnPhase.discard;
    return true;
  }

  void discard(Tile t) {
    final p = players[current];
    p.hand.removeWhere((e) => e.id == t.id);
    p.river.add(t);
    lastDiscard = t;
    lastDiscardSeat = current;
    phase = TurnPhase.react;
  }

  // 处理花牌：摸到花/季就补花
  void _handleFlowers(Player p, {bool drawUntilNoFlower=false}) {
    bool hasFlower() => p.hand.any((t) => t.isFlowerLike);
    while (hasFlower()) {
      final f = p.hand.firstWhere((t)=> t.isFlowerLike);
      p.hand.remove(f); p.flowers.add(f);
      if (wall.isNotEmpty) p.hand.add(wall.removeLast());
      else break;
      if (!drawUntilNoFlower) break;
    }
  }

  // 吃/碰/杠 反应（仅在 react 阶段）
  bool claimPung(int claimerSeat) {
    if (phase != TurnPhase.react || lastDiscard == null) return false;
    final p = players[claimerSeat];
    if (!MahjongRules.canPung(lastDiscard!, p.hand)) return false;
    final same = p.hand.where((t)=> t.suit==lastDiscard!.suit && t.rank==lastDiscard!.rank).take(2).toList();
    for (final s in same) { p.hand.removeWhere((e)=> e.id == s.id); }
    p.melds.add(Meld(MeldType.pung, [...same, lastDiscard!], fromPlayer: lastDiscardSeat));
    players[lastDiscardSeat].river.removeLast();
    lastDiscard = null; lastDiscardSeat = -1;
    current = claimerSeat;
    phase = TurnPhase.discard;
    return true;
  }

  bool claimKong(int claimerSeat) {
    if (phase != TurnPhase.react || lastDiscard == null) return false;
    final p = players[claimerSeat];
    if (!MahjongRules.canKongFromDiscard(lastDiscard!, p.hand)) return false;
    final same = p.hand.where((t)=> t.suit==lastDiscard!.suit && t.rank==lastDiscard!.rank).take(3).toList();
    for (final s in same) { p.hand.removeWhere((e)=> e.id == s.id); }
    p.melds.add(Meld(MeldType.kong, [...same, lastDiscard!], fromPlayer: lastDiscardSeat));
    players[lastDiscardSeat].river.removeLast();
    lastDiscard = null; lastDiscardSeat = -1;
    current = claimerSeat;
    // 明杠后补摸一张
    draw();
    return true;
  }

  // 仅允许上家吃：传入 claimerSeat == (lastDiscardSeat+1)%4
  bool claimChow(int claimerSeat, List<Tile> usingHandTiles) {
    if (phase != TurnPhase.react || lastDiscard == null) return false;
    if (claimerSeat != (lastDiscardSeat + 1) % 4) return false;
    final p = players[claimerSeat];
    final options = MahjongRules.chowsFrom(lastDiscard!, p.hand);
    final ok = options.any((opt){
      // opt 包含 lastDiscard + 2张手牌；对比 usingHandTiles
      final ids = usingHandTiles.map((e)=>e.id).toSet();
      final need = opt.where((e)=> e.id != lastDiscard!.id);
      return need.every((e)=> ids.contains(e.id));
    });
    if (!ok) return false;
    for (final t in usingHandTiles) {
      p.hand.removeWhere((e)=> e.id == t.id);
    }
    p.melds.add(Meld(MeldType.chow, [...usingHandTiles, lastDiscard!]..sort(), fromPlayer: lastDiscardSeat));
    players[lastDiscardSeat].river.removeLast();
    lastDiscard = null; lastDiscardSeat = -1;
    current = claimerSeat;
    phase = TurnPhase.discard;
    return true;
  }

  // 暗杠 / 加杠（在自己出牌阶段）
  bool concealedKong() {
    final p = players[current];
    final cands = MahjongRules.concealedKongCandidates(p.hand);
    if (cands.isEmpty) return false;
    final base = cands.first;
    final group = p.hand.where((t)=> t.suit==base.suit && t.rank==base.rank).take(4).toList();
    group.forEach((t)=> p.hand.removeWhere((e)=> e.id==t.id));
    p.melds.add(Meld(MeldType.concealedKong, group));
    draw(); // 补摸
    return true;
  }

  bool addKong() {
    final p = players[current];
    final cands = MahjongRules.addKongCandidates(p.hand, p.melds);
    if (cands.isEmpty) return false;
    final base = cands.first;
    final idx = p.melds.indexWhere((m)=> m.type==MeldType.pung && m.tiles.first.suit==base.suit && m.tiles.first.rank==base.rank);
    if (idx<0) return false;
    final tile = p.hand.firstWhere((t)=> t.suit==base.suit && t.rank==base.rank);
    p.hand.removeWhere((e)=> e.id==tile.id);
    p.melds[idx] = Meld(MeldType.kong, [...p.melds[idx].tiles, tile], fromPlayer: p.melds[idx].fromPlayer);
    draw(); // 补摸
    return true;
  }

  bool canSelfWin() {
    final p = players[current];
    return MahjongRules.canWin(p.hand);
  }

  void nextTurn() {
    current = (current + 1) % 4;
    phase = TurnPhase.draw;
  }
}
