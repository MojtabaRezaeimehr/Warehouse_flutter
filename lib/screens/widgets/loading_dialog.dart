import 'package:flutter/material.dart';
// import 'package:loading_animation_widget/loading_animation_widget.dart';

class LoadingDialog extends StatelessWidget {
  static BuildContext? _context;
  final Color backgroundColor;

  const LoadingDialog({super.key, required this.backgroundColor});

  static show(BuildContext context) {
    //dont show two dialog at the same time
    if (_context != null) {
      return;
    }

    _context = context;
    showDialog(
      barrierColor: Colors.transparent,
      context: _context!,
      builder: (context) => LoadingDialog(
        backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
      ),
    );
  }

  static showLightDialog(BuildContext context) {
    //dont show two dialog at the same time
    if (_context != null) {
      return;
    }

    _context = context;
    showDialog(
      barrierColor: Colors.transparent,
      context: _context!,
      builder: (context) => LoadingDialog(
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
    );
  }

  static dismiss() {
    if (_context != null) {
      try {
        //in some cases app crahses with nullpointer error(hamgam khodro)
        //it may be bc of context not being in a widget tree
        Navigator.pop(_context!);
        _context = null;
        // ignore: empty_catches
      } catch (e) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Center(
        // child: LoadingAnimationWidget.threeRotatingDots(
        //   color: Theme.of(context).colorScheme.primary,
        //   size: 100,
        // ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: backgroundColor,
          ),
          padding: const EdgeInsets.all(40),
          child: const CircularProgressIndicator(),
        ),
      ),
    );
  }
}
