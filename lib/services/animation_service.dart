import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// 动画服务类
class AnimationService {
  static final AnimationService _instance = AnimationService._internal();
  factory AnimationService() => _instance;
  AnimationService._internal();

  /// 麻将牌出现动画
  static Widget tileAppearAnimation(Widget child) {
    return child
        .animate()
        .fadeIn(duration: 300.ms, curve: Curves.easeOut)
        .scale(begin: const Offset(0.5, 0.5), end: const Offset(1.0, 1.0))
        .slide(begin: const Offset(0, 0.3), end: Offset.zero);
  }

  /// 麻将牌消失动画
  static Widget tileDisappearAnimation(Widget child) {
    return child
        .animate()
        .fadeOut(duration: 200.ms, curve: Curves.easeIn)
        .scale(begin: const Offset(1.0, 1.0), end: const Offset(0.5, 0.5));
  }

  /// 麻将牌移动动画
  static Widget tileMoveAnimation(Widget child, Offset begin, Offset end) {
    return child
        .animate()
        .slide(begin: begin, end: end, duration: 500.ms, curve: Curves.easeInOut);
  }

  /// 麻将牌旋转动画
  static Widget tileRotateAnimation(Widget child) {
    return child
        .animate()
        .rotate(duration: 300.ms, curve: Curves.easeInOut)
        .then()
        .rotate(duration: 300.ms, curve: Curves.easeInOut);
  }

  /// 按钮点击动画
  static Widget buttonClickAnimation(Widget child) {
    return child
        .animate()
        .scale(begin: const Offset(1.0, 1.0), end: const Offset(0.95, 0.95), duration: 100.ms)
        .then()
        .scale(begin: const Offset(0.95, 0.95), end: const Offset(1.0, 1.0), duration: 100.ms);
  }

  /// 胡牌庆祝动画
  static Widget winCelebrationAnimation(Widget child) {
    return child
        .animate()
        .fadeIn(duration: 500.ms)
        .scale(begin: const Offset(0.8, 0.8), end: const Offset(1.2, 1.2), duration: 300.ms)
        .then()
        .scale(begin: const Offset(1.2, 1.2), end: const Offset(1.0, 1.0), duration: 200.ms)
        .shimmer(duration: 1000.ms, color: Colors.yellow.withOpacity(0.5));
  }

  /// 分数增加动画
  static Widget scoreIncreaseAnimation(Widget child) {
    return child
        .animate()
        .fadeIn(duration: 300.ms)
        .slide(begin: const Offset(0, -0.5), end: Offset.zero)
        .scale(begin: const Offset(0.5, 0.5), end: const Offset(1.0, 1.0))
        .then(delay: 1000.ms)
        .fadeOut(duration: 300.ms);
  }

  /// 牌组形成动画
  static Widget meldFormationAnimation(Widget child) {
    return child
        .animate()
        .fadeIn(duration: 400.ms)
        .scale(begin: const Offset(0.8, 0.8), end: const Offset(1.0, 1.0))
        .slide(begin: const Offset(0, 0.3), end: Offset.zero);
  }

  /// 游戏开始动画
  static Widget gameStartAnimation(Widget child) {
    return child
        .animate()
        .fadeIn(duration: 800.ms, curve: Curves.easeOut)
        .slide(begin: const Offset(0, -0.5), end: Offset.zero)
        .scale(begin: const Offset(0.9, 0.9), end: const Offset(1.0, 1.0));
  }

  /// 玩家切换动画
  static Widget playerSwitchAnimation(Widget child) {
    return child
        .animate()
        .fadeIn(duration: 300.ms)
        .slide(begin: const Offset(0.3, 0), end: Offset.zero);
  }

  /// 错误提示动画
  static Widget errorAnimation(Widget child) {
    return child
        .animate()
        .shake(duration: 500.ms, curve: Curves.elasticIn)
        .fadeIn(duration: 200.ms);
  }

  /// 成功提示动画
  static Widget successAnimation(Widget child) {
    return child
        .animate()
        .fadeIn(duration: 300.ms)
        .scale(begin: const Offset(0.8, 0.8), end: const Offset(1.0, 1.0))
        .then(delay: 2000.ms)
        .fadeOut(duration: 300.ms);
  }

  /// 创建脉冲动画
  static Widget pulseAnimation(Widget child) {
    return child
        .animate(onPlay: (controller) => controller.repeat())
        .scale(begin: const Offset(1.0, 1.0), end: const Offset(1.1, 1.1), duration: 1000.ms)
        .then()
        .scale(begin: const Offset(1.1, 1.1), end: const Offset(1.0, 1.0), duration: 1000.ms);
  }

  /// 创建闪烁动画
  static Widget blinkAnimation(Widget child) {
    return child
        .animate(onPlay: (controller) => controller.repeat())
        .fadeIn(duration: 500.ms)
        .then()
        .fadeOut(duration: 500.ms);
  }
}

