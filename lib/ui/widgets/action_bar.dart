import 'package:flutter/material.dart';

class ActionBar extends StatelessWidget {
  final bool canChow;
  final bool canPung;
  final bool canKong;
  final bool canWin;
  final VoidCallback onChow;
  final VoidCallback onPung;
  final VoidCallback onKong;
  final VoidCallback onWin;
  final VoidCallback onPass;
  final VoidCallback onDiscard;

  const ActionBar({
    super.key,
    required this.canChow,
    required this.canPung,
    required this.canKong,
    required this.canWin,
    required this.onChow,
    required this.onPung,
    required this.onKong,
    required this.onWin,
    required this.onPass,
    required this.onDiscard,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      alignment: WrapAlignment.center,
      children: [
        ElevatedButton(onPressed: canChow ? onChow : null, child: const Text('吃')),
        ElevatedButton(onPressed: canPung ? onPung : null, child: const Text('碰')),
        ElevatedButton(onPressed: canKong ? onKong : null, child: const Text('杠')),
        ElevatedButton(onPressed: canWin ? onWin : null, child: const Text('胡')),
        ElevatedButton(onPressed: onPass, child: const Text('过')),
        ElevatedButton(onPressed: onDiscard, child: const Text('打出选中')),
      ],
    );
  }
}
