import 'package:flutter/material.dart';
import 'ui/game_page.dart';

void main() {
  runApp(const MahjongApp());
}

class MahjongApp extends StatelessWidget {
  const MahjongApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TW 16 Mahjong',
      theme: ThemeData(useMaterial3: true),
      home: const GamePage(),
    );
  }
}
