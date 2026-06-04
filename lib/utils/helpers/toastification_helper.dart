import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';
import 'package:warehouse_amf/utils/color/color.dart';

class ToastHelper {
  static showErrorToast(Widget? title, Widget? desc) {
    Toastification().show(
      style: ToastificationStyle.flat,
      title: title,
      description: desc,
      icon: const Icon(Icons.error, color: redColor),
      borderSide: const BorderSide(color: redColor),
      animationBuilder: (context, animation, alignment, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
      type: ToastificationType.error,
      closeOnClick: true,
      autoCloseDuration: const Duration(seconds: 4),
      alignment: Alignment.topCenter,
    );
  }

  static showSuccessToast( Widget? title, Widget? desc) {
    Toastification().show(
      style: ToastificationStyle.flat,
      title: title,
      description: desc,
      borderSide: const BorderSide(color: Colors.green),
      animationBuilder: (context, animation, alignment, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
      type: ToastificationType.success,
      closeOnClick: true,
      autoCloseDuration: const Duration(seconds: 4),
      alignment: Alignment.topCenter,
    );
  }

  static showToast(Widget? title) {
    Toastification().show(
      style: ToastificationStyle.simple,
      title: title,
      animationBuilder: (context, animation, alignment, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
      type: ToastificationType.info,
      closeOnClick: true,
      autoCloseDuration: const Duration(seconds: 3),
      alignment: Alignment.topCenter,
    );
  }
}
