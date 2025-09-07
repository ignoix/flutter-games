import 'package:flutter/material.dart';
import '../game/mahjong_engine.dart';
import '../game/ai.dart';
import '../game/mahjong_rules.dart';
import '../models/tile.dart';
import './widgets/hand_row.dart';
import 'widgets/meld_row.dart';
import 'widgets/river_panel.dart';
import 'widgets/action_bar.dart';
import '../game/score.dart';

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  final MahjongEngine eng = MahjongEngine();
  Tile? selected;

  @override
  void initState() {
    super.initState();
    eng.newGame(dealerSeat: 0);
    // 起手到庄家摸牌
    if (eng.current == 0) {
      setState(() { eng.draw(); });
    } else {
      // 让机器人走到你的回合
      _runBotsUntilPlayer();
    }
  }

  void _runBotsUntilPlayer() {
    while (eng.current != 0) {
      SimpleAI.takeTurn(eng);
      if (eng.current == 0 && eng.phase == TurnPhase.draw) {
        eng.draw();
      }
    }
    setState(() {});
  }

  void _playerDiscard() {
    if (eng.current != 0 || eng.phase != TurnPhase.discard || selected == null) return;
    eng.discard(selected!);
    selected = null;
    // 机器人反应
    for (int i=1; i<=3; i++) {
      final seat = (eng.current + i) % 4;
      final claimed = SimpleAI.react(eng, seat);
      if (claimed) {
        setState(() {});
        return;
      }
    }
    eng.nextTurn();
    // 让机器人一直打到你
    _runBotsUntilPlayer();
  }

  @override
  Widget build(BuildContext context) {
    final me = eng.players[0];
    final last = eng.lastDiscard;
    final canChow = last != null && eng.phase == TurnPhase.react && ((eng.lastDiscardSeat + 1) % 4 == 0) && MahjongRules.chowsFrom(last, me.hand).isNotEmpty;
    final canPung = last != null && eng.phase == TurnPhase.react && MahjongRules.canPung(last, me.hand);
    final canKong = (last != null && eng.phase == TurnPhase.react && me.hand.where((t)=> t.suit==last.suit && t.rank==last.rank).length >= 3)
        || (eng.phase == TurnPhase.discard && (/*暗杠*/ true));
    final canWin = eng.phase == TurnPhase.discard && eng.canSelfWin();

    return Scaffold(
      appBar: AppBar(title: const Text('台湾十六张麻将（雏形）')),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 8),
            Text('墙剩余：${eng.wall.length}  ｜ 当前：${eng.current==0?'你': 'Bot${eng.current}'} ｜ 阶段：${eng.phase.name}'),
            const Divider(),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _section('你的面子/花', Column(
                      children: [
                        MeldRow(melds: me.melds),
                        const SizedBox(height: 4),
                        Wrap(children: me.flowers.map((t)=>Text(t.short)).toList()),
                      ],
                    )),
                    _section('牌河（上到下 0~3家）',
                      RiverPanel(rivers: eng.players.map((p)=>p.river).toList())
                    ),
                    _section('你的手牌',
                      HandRow(tiles: me.hand, selected: selected, onSelect: (t){ setState(()=> selected = t); })
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            ActionBar(
              canChow: canChow,
              canPung: canPung,
              canKong: canKong,
              canWin: canWin,
              onChow: (){
                if (!canChow) return;
                // 简化：自动选择第一组吃
                final opts = MahjongRules.chowsFrom(eng.lastDiscard!, me.hand);
                final using = opts.first.where((t)=> t.id != eng.lastDiscard!.id).toList();
                eng.claimChow(0, using);
                setState(() {});
              },
              onPung: (){
                if (eng.claimPung(0)) setState((){});
              },
              onKong: (){
                // 优先反应杠，否则尝试暗杠/加杠
                if (eng.phase == TurnPhase.react) {
                  if (eng.claimKong(0)) setState((){});
                } else {
                  if (eng.concealedKong() || eng.addKong()) setState((){});
                }
              },
              onWin: (){
                if (eng.canSelfWin()) {
                    final me = eng.players[0];
                    final result = ScoreCalculator.evaluate(
                    concealed: me.hand,
                    melds: me.melds,
                    flowers: me.flowers,
                    selfDraw: true, // 这里先只处理自摸
                    dealer: eng.current == eng.dealer,
                    );
                    showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                        title: const Text('胡了！'),
                        content: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                            Text("番型：${result.patterns.join(', ')}"),
                            Text("番数：${result.fan} 番"),
                            Text("台数：${result.tai} 台"),
                            Text("得分：${result.score}"),
                        ],
                        ),
                        actions: [
                        TextButton(
                            onPressed: ()=> Navigator.pop(context),
                            child: const Text('OK'),
                        )
                        ],
                    ),
                    );
                }
            },

              onPass: (){
                // 只有 react 时才有过
                if (eng.phase == TurnPhase.react) {
                  eng.nextTurn();
                  _runBotsUntilPlayer();
                }
              },
              onDiscard: _playerDiscard,
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        label: const Text('新一局'),
        onPressed: (){
          eng.newGame(dealerSeat: 0);
          eng.draw();
          setState((){ selected = null; });
        },
      ),
    );
  }

  Widget _section(String title, Widget child) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          child,
        ],
      ),
    );
  }
}
