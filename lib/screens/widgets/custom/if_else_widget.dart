import 'package:flutter/material.dart';

class IfElseWidget extends StatelessWidget {
  const IfElseWidget(
      {super.key,
      required this.condition,
      required this.ifWidget,
      required this.elseWidget});
  final bool condition;
  final Widget ifWidget;
  final Widget elseWidget;

  @override
  Widget build(BuildContext context) {
    return condition ? ifWidget : elseWidget;
  }
}
