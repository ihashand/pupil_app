import 'package:flutter/material.dart';

class ModuleItem {
  final Widget content; // Widget może być ikoną lub przyciskiem
  final IconData? buttonIcon;
  final String? buttonText;
  final double? buttonWidth;
  final double? buttonHeight;
  final bool? iconOnRight;

  ModuleItem({
    required this.content,
    this.buttonIcon,
    this.buttonText,
    this.buttonWidth,
    this.buttonHeight,
    this.iconOnRight,
  });
}
