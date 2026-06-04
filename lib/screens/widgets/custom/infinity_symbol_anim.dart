import 'dart:math';

import 'package:flutter/material.dart';
import 'package:warehouse_amf/utils/consts/durations.dart';

class InfinitySymbolAnim extends StatefulWidget {
  const InfinitySymbolAnim({
    super.key,
    required this.child,
    this.width = 200,
    this.height = 200,
  });

  final Widget child;
  final double width;
  final double height;

  @override
  State<InfinitySymbolAnim> createState() => _InfinitySymbolAnimState();
}

class _InfinitySymbolAnimState extends State<InfinitySymbolAnim>
    with SingleTickerProviderStateMixin {
  late AnimationController animController;

  @override
  void initState() {
    animController =
        AnimationController(vsync: this, duration: kSearchIconAnimDuration);
    animController.repeat();
    animController.addListener(
      () => setState(() {}),
    );
    super.initState();
  }

  @override
  void dispose() {
    animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var offset =
        getInfinitySymbolPoint(getConvertedValue(animController.value));

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Stack(
        children: [
          Align(
            alignment: Alignment(offset.dx, offset.dy),
            child: widget.child,
          ),
        ],
      ),
    );
  }

  Offset getInfinitySymbolPoint(double t) {
    // Scale t from [-1, 1] to [-pi, pi] for the parameterized equation
    double theta = t * pi;

    // Parametric equation of a lemniscate (infinity symbol)
    double x = cos(theta);
    double y = sin(theta) * cos(theta);

    return Offset(x, y);
  }

  // 0  - 0.5 -  1 //this values are given by animController
  // -1 - 0   - 1 //we need this values for getInfinitySymbolPoint
  //how does it work?
  //how far is 0.7 from 0.5 (in the given values by controller) ? 0.2 or 40%
  //we shall go 40% from 0 to 1
  double getConvertedValue(double x) => -1 * ((0.5 - x) / 0.5);
}
