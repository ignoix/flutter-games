import 'package:flutter_test/flutter_test.dart';
import 'package:tw16_mahjong/models/tile.dart';
import 'package:tw16_mahjong/game_logic/mahjong_rules.dart';

void main() {
  group('麻将规则测试', () {
    test('测试七对胡牌', () {
      final tiles = [
        Tile.wan(1), Tile.wan(1),
        Tile.wan(2), Tile.wan(2),
        Tile.wan(3), Tile.wan(3),
        Tile.wan(4), Tile.wan(4),
        Tile.wan(5), Tile.wan(5),
        Tile.wan(6), Tile.wan(6),
        Tile.wan(7), Tile.wan(7),
      ];
      
      expect(MahjongRules.isQiDui(tiles), true);
      expect(MahjongRules.canWin(tiles), true);
    });

    test('测试普通胡牌', () {
      final tiles = [
        // 顺子
        Tile.wan(1), Tile.wan(2), Tile.wan(3),
        Tile.tiao(4), Tile.tiao(5), Tile.tiao(6),
        Tile.tong(7), Tile.tong(8), Tile.tong(9),
        // 刻子
        Tile.zi('东'), Tile.zi('东'), Tile.zi('东'),
        // 对子
        Tile.zi('中'), Tile.zi('中'),
      ];
      
      expect(MahjongRules.canWin(tiles), true);
    });

    test('测试清一色', () {
      final tiles = [
        Tile.wan(1), Tile.wan(2), Tile.wan(3),
        Tile.wan(4), Tile.wan(5), Tile.wan(6),
        Tile.wan(7), Tile.wan(8), Tile.wan(9),
        Tile.wan(1), Tile.wan(2), Tile.wan(3),
        Tile.wan(4), Tile.wan(5),
      ];
      
      expect(MahjongRules.isQingYiSe(tiles), true);
    });

    test('测试字一色', () {
      final tiles = [
        Tile.zi('东'), Tile.zi('南'), Tile.zi('西'),
        Tile.zi('北'), Tile.zi('中'), Tile.zi('发'),
        Tile.zi('白'), Tile.zi('东'), Tile.zi('南'),
        Tile.zi('西'), Tile.zi('北'), Tile.zi('中'),
        Tile.zi('发'), Tile.zi('白'),
      ];
      
      expect(MahjongRules.isZiYiSe(tiles), true);
    });
  });
}
