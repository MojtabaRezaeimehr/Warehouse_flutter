import 'package:flutter/material.dart';
import 'package:warehouse_amf/screens/widgets/custom/if_widget.dart';

class NumberPicker extends StatefulWidget {
  const NumberPicker(
      {super.key,
      required this.onIncrement,
      required this.onDecrement,
      this.initialValue = 1,
      this.label,
      this.axis = Axis.horizontal});
  final Function(int val) onIncrement;
  final Function(int val) onDecrement;
  final int initialValue;
  final Text? label;
  final Axis axis;

  @override
  State<NumberPicker> createState() => _NumberPickerState();
}

class _NumberPickerState extends State<NumberPicker> {
  late int val;

  @override
  void initState() {
    val = widget.initialValue;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return widget.axis == Axis.horizontal
        ? Row(
            mainAxisSize: MainAxisSize.min,
            children: children(context),
          )
        : Column(
            mainAxisSize: MainAxisSize.min,
            children: children(context),
          );
  }

  List<Widget> children(BuildContext context) {
    return [
      IfWidget(condition: widget.label != null, child: widget.label),
      IfWidget(condition: widget.label != null, child: const Spacer()),
      GestureDetector(
        onLongPressMoveUpdate: (details) {
          setState(() {
            val = val + 2;
          });
        },
        onLongPressUp: () {
          widget.onIncrement.call(val);
        },
        child: IconButton.filledTonal(
          style: IconButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              iconSize: 30),
          onPressed: () {
            setState(() {
              val++;
            });
            widget.onIncrement.call(val);
          },
          icon: const Icon(Icons.add),
        ),
      ),
      Container(
        width: 50,
        height: 50,
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Theme.of(context).colorScheme.outline),
        ),
        alignment: Alignment.center,
        child: Text(val.toString()),
      ),
      GestureDetector(
        onLongPressMoveUpdate: (details) {
          if (val >= 2) {
            setState(() {
              val = val - 2;
            });
          }
        },
        onLongPressUp: () {
          widget.onDecrement.call(val);
        },
        child: IconButton.filledTonal(
          style: IconButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              iconSize: 30),
          onPressed: () {
            if (val > 0) {
              setState(() {
                val--;
              });
              widget.onDecrement.call(val);
            }
          },
          icon: const Icon(Icons.remove),
        ),
      ),
    ];
  }
}
