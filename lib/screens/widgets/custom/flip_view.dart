import 'dart:math';
import 'package:flutter/material.dart';

class FlipView extends StatefulWidget {
  final Widget frontCard;
  final Widget backCard;
  final bool showFrontCard;
  final ValueNotifier<bool> valueNotifier; //if true the frontCard will be shown

  const FlipView({
    super.key,
    this.showFrontCard = true,
    required this.valueNotifier,
    required this.backCard,
    required this.frontCard,
  });

  @override
  State<FlipView> createState() => _FlipViewState();
}

class _FlipViewState extends State<FlipView> {
  bool emptyState = true;

  @override
  void dispose() {
    widget.valueNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: widget.valueNotifier,
      builder: (context, value, child) {
        return GestureDetector(
          onTap: () {
            widget.valueNotifier.value = !value;
          },
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 800),
            transitionBuilder: _transitionBuilder,
            switchInCurve: Curves.ease,
            switchOutCurve: Curves.ease.flipped,
            child: value
                ? SizedBox(key: const ValueKey(true), child: widget.frontCard)
                : SizedBox(key: const ValueKey(false), child: widget.backCard),
          ),
        );
      },
    );
  }

  Widget _transitionBuilder(Widget widget, Animation<double> animation) {
    final rotateAnimation = Tween(begin: pi, end: 0.0).animate(animation);
    return AnimatedBuilder(
      animation: rotateAnimation,
      child: widget,
      builder: (context, widget) {
        final isFront =
            ValueKey(!this.widget.valueNotifier.value) == widget!.key;
        final rotationX = isFront
            ? rotateAnimation.value
            : min(rotateAnimation.value, pi * 0.5);
        return Transform(
          transform: Matrix4.rotationX(rotationX),
          alignment: Alignment.center,
          child: widget,
        );
      },
    );
  }
}
