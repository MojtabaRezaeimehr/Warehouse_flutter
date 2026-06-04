import 'package:flutter/material.dart';

class IfWidget extends StatelessWidget {
  const IfWidget({
    super.key,
    required this.condition,
    required this.child,
  });
  final Widget? child;
  final bool condition;

  @override
  Widget build(BuildContext context) {
    return condition && child != null
        ? child!
        : const SizedBox(
            width: 0,
            height: 0,
          );
  }
}
