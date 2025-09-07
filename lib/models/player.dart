import 'tile.dart';
import 'meld.dart';

class Player {
  final int seat; // 0..3
  List<Tile> hand = [];
  List<Tile> flowers = [];
  List<Meld> melds = [];
  List<Tile> river = [];

  Player(this.seat);

  void sortHand() => hand.sort();
}
