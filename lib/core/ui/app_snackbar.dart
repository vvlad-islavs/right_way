import 'package:flutter/material.dart';

/// Плавающий SnackBar с отступом от нижнего края экрана с учётом safe area.
void showAppSnackBar(BuildContext context, String message) {
  final bottom = MediaQuery.viewPaddingOf(context).bottom;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      behavior: SnackBarBehavior.floating,
      margin: EdgeInsets.fromLTRB(16, 0, 16, bottom),
    ),
  );
}
