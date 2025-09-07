import 'tile.dart';

enum MeldType { chow, pung, kong, concealedKong }

class Meld {
  final MeldType type;
  final List<Tile> tiles; // 3 or 4 tiles
  final int fromPlayer;   // 被吃/碰/杠的玩家座位，-1 表示自摸或暗杠
  Meld(this.type, this.tiles, {this.fromPlayer = -1});
}
