import '../models/tile.dart';

/// 胡牌类型枚举
enum WinType {
  normal,     // 普通胡牌
  selfDraw,   // 自摸
  robGang,    // 抢杠
  kong,       // 杠上开花
  lastTile,   // 海底捞月
}

/// 番型枚举
enum FanType {
  // 基本番型
  pingHu,           // 平胡
  duiZiHu,          // 对子胡
  qingYiSe,         // 清一色
  hunYiSe,          // 混一色
  ziYiSe,           // 字一色
  daSanYuan,        // 大三元
  xiaoSanYuan,      // 小三元
  daSiXi,           // 大四喜
  xiaoSiXi,          // 小四喜
  jiuLianBaoDeng,   // 九莲宝灯
  shiSanYao,        // 十三幺
  qiDui,            // 七对
  qingLong,         // 清龙
  hunLong,          // 混龙
  sanAnKe,          // 三暗刻
  sanGang,          // 三杠
  siGang,           // 四杠
  tianHu,           // 天胡
  diHu,             // 地胡
  renHu,            // 人胡
}

/// 麻将规则类
class MahjongRules {
  /// 检查是否可以胡牌
  static bool canWin(List<Tile> tiles) {
    if (tiles.length != 14) return false;
    
    // 检查是否有七对
    if (isQiDui(tiles)) return true;
    
    // 检查是否有十三幺
    if (isShiSanYao(tiles)) return true;
    
    // 检查是否有九莲宝灯
    if (isJiuLianBaoDeng(tiles)) return true;
    
    // 检查普通胡牌（4个顺子/刻子 + 1个对子）
    return isNormalWin(tiles);
  }

  /// 检查是否为七对
  static bool isQiDui(List<Tile> tiles) {
    if (tiles.length != 14) return false;
    
    final tileCount = <String, int>{};
    for (final tile in tiles) {
      tileCount[tile.name] = (tileCount[tile.name] ?? 0) + 1;
    }
    
    // 检查是否所有牌都是成对的
    return tileCount.values.every((count) {
      return count == 2;
    });
  }

  /// 检查是否为十三幺
  static bool isShiSanYao(List<Tile> tiles) {
    if (tiles.length != 14) return false;
    
    final requiredTiles = [
      '1万', '9万', '1条', '9条', '1筒', '9筒',
      '东', '南', '西', '北', '中', '发', '白'
    ];
    
    final tileCount = <String, int>{};
    for (final tile in tiles) {
      tileCount[tile.name] = (tileCount[tile.name] ?? 0) + 1;
    }
    
    // 检查是否包含所有必需的牌
    for (final required in requiredTiles) {
      if (!tileCount.containsKey(required)) {
        return false;
      }
    }
    
    // 检查是否有一张牌是成对的
    int pairCount = 0;
    for (final count in tileCount.values) {
      if (count == 2) {
        pairCount++;
      } else if (count != 1) {
        return false;
      }
    }
    
    return pairCount == 1;
  }

  /// 检查是否为九莲宝灯
  static bool isJiuLianBaoDeng(List<Tile> tiles) {
    if (tiles.length != 14) return false;
    
    // 检查是否为同一花色
    final firstType = tiles.first.type;
    if (firstType == TileType.zi) return false;
    
    if (!tiles.every((tile) => tile.type == firstType)) return false;
    
    final tileCount = <int, int>{};
    for (final tile in tiles) {
      tileCount[tile.value] = (tileCount[tile.value] ?? 0) + 1;
    }
    
    // 检查1和9至少各有3张，2-8至少各有1张
    if ((tileCount[1] ?? 0) < 3 || (tileCount[9] ?? 0) < 3) return false;
    
    for (int i = 2; i <= 8; i++) {
      if ((tileCount[i] ?? 0) < 1) return false;
    }
    
    return true;
  }

  /// 检查普通胡牌
  static bool isNormalWin(List<Tile> tiles) {
    if (tiles.length != 14) return false;
    
    // 尝试找到4个顺子/刻子 + 1个对子
    return _canFormMelds(tiles, 4, true);
  }

  /// 递归检查是否可以组成指定数量的牌组
  static bool _canFormMelds(List<Tile> tiles, int meldCount, bool needPair) {
    if (tiles.isEmpty) return meldCount == 0 && !needPair;
    
    if (meldCount == 0) return !needPair;
    
    // 尝试找对子
    if (needPair) {
      final tileCount = <String, int>{};
      for (final tile in tiles) {
        tileCount[tile.name] = (tileCount[tile.name] ?? 0) + 1;
      }
      
      for (final entry in tileCount.entries) {
        if (entry.value >= 2) {
          final remainingTiles = List<Tile>.from(tiles);
          remainingTiles.removeWhere((tile) => tile.name == entry.key);
          remainingTiles.removeWhere((tile) => tile.name == entry.key);
          
          if (_canFormMelds(remainingTiles, meldCount, false)) {
            return true;
          }
        }
      }
    }
    
    // 尝试找刻子（三张相同的牌）
    final tileCount = <String, int>{};
    for (final tile in tiles) {
      tileCount[tile.name] = (tileCount[tile.name] ?? 0) + 1;
    }
    
    for (final entry in tileCount.entries) {
      if (entry.value >= 3) {
        final remainingTiles = List<Tile>.from(tiles);
        remainingTiles.removeWhere((tile) => tile.name == entry.key);
        remainingTiles.removeWhere((tile) => tile.name == entry.key);
        remainingTiles.removeWhere((tile) => tile.name == entry.key);
        
        if (_canFormMelds(remainingTiles, meldCount - 1, needPair)) {
          return true;
        }
      }
    }
    
    // 尝试找顺子（三张连续的数字牌）
    if (tiles.first.isNumberTile) {
      final sortedTiles = List<Tile>.from(tiles);
      sortedTiles.sort((a, b) => a.value.compareTo(b.value));
      
      for (int i = 0; i < sortedTiles.length - 2; i++) {
        final tile1 = sortedTiles[i];
        final tile2 = sortedTiles[i + 1];
        final tile3 = sortedTiles[i + 2];
        
        if (tile1.type == tile2.type && tile2.type == tile3.type &&
            tile1.value + 1 == tile2.value && tile2.value + 1 == tile3.value) {
          final remainingTiles = List<Tile>.from(tiles);
          remainingTiles.remove(tile1);
          remainingTiles.remove(tile2);
          remainingTiles.remove(tile3);
          
          if (_canFormMelds(remainingTiles, meldCount - 1, needPair)) {
            return true;
          }
        }
      }
    }
    
    return false;
  }

  /// 检查是否可以碰牌
  static bool canPeng(List<Tile> handTiles, Tile discardedTile) {
    final sameTiles = handTiles.where((tile) => tile.name == discardedTile.name).length;
    return sameTiles >= 2;
  }

  /// 检查是否可以杠牌
  static bool canGang(List<Tile> handTiles, Tile? discardedTile) {
    if (discardedTile != null) {
      // 明杠：手中有3张相同牌，别人打出第4张
      final sameTiles = handTiles.where((tile) => tile.name == discardedTile.name).length;
      return sameTiles >= 3;
    } else {
      // 暗杠：手中有4张相同牌
      final tileCount = <String, int>{};
      for (final tile in handTiles) {
        tileCount[tile.name] = (tileCount[tile.name] ?? 0) + 1;
      }
      return tileCount.values.any((count) => count == 4);
    }
  }

  /// 检查是否可以吃牌
  static bool canChi(List<Tile> handTiles, Tile discardedTile) {
    if (!discardedTile.isNumberTile) return false;
    
    final sameTypeTiles = handTiles.where((tile) => tile.type == discardedTile.type).toList();
    
    // 检查是否可以组成顺子
    for (final tile in sameTypeTiles) {
      if (tile.value == discardedTile.value - 1) {
        // 需要 tile, discardedTile, tile+2
        if (sameTypeTiles.any((t) => t.value == discardedTile.value + 1)) {
          return true;
        }
      } else if (tile.value == discardedTile.value + 1) {
        // 需要 tile-1, discardedTile, tile
        if (sameTypeTiles.any((t) => t.value == discardedTile.value - 1)) {
          return true;
        }
      } else if (tile.value == discardedTile.value + 2) {
        // 需要 tile-1, tile, discardedTile
        if (sameTypeTiles.any((t) => t.value == discardedTile.value + 1)) {
          return true;
        }
      }
    }
    
    return false;
  }

  /// 计算胡牌番数
  static List<FanType> calculateFan(List<Tile> tiles, WinType winType) {
    final fans = <FanType>[];
    
    // 基本胡牌
    fans.add(FanType.pingHu);
    
    // 检查特殊胡牌类型
    if (isQiDui(tiles)) {
      fans.add(FanType.qiDui);
    } else if (isShiSanYao(tiles)) {
      fans.add(FanType.shiSanYao);
    } else if (isJiuLianBaoDeng(tiles)) {
      fans.add(FanType.jiuLianBaoDeng);
    }
    
    // 检查清一色
    if (isQingYiSe(tiles)) {
      fans.add(FanType.qingYiSe);
    }
    
    // 检查混一色
    if (isHunYiSe(tiles)) {
      fans.add(FanType.hunYiSe);
    }
    
    // 检查字一色
    if (isZiYiSe(tiles)) {
      fans.add(FanType.ziYiSe);
    }
    
    return fans;
  }

  /// 检查是否为清一色
  static bool isQingYiSe(List<Tile> tiles) {
    if (tiles.isEmpty) return false;
    
    final firstType = tiles.first.type;
    if (firstType == TileType.zi) return false;
    
    return tiles.every((tile) => tile.type == firstType);
  }

  /// 检查是否为混一色
  static bool isHunYiSe(List<Tile> tiles) {
    if (tiles.isEmpty) return false;
    
    final numberTiles = tiles.where((tile) => tile.isNumberTile).toList();
    if (numberTiles.isEmpty) return false;
    
    final firstType = numberTiles.first.type;
    return numberTiles.every((tile) => tile.type == firstType);
  }

  /// 检查是否为字一色
  static bool isZiYiSe(List<Tile> tiles) {
    return tiles.isNotEmpty && tiles.every((tile) => tile.isZiTile);
  }
}
