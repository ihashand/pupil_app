import 'package:flutter/material.dart';

class EventsIconsModule {
  final String name;
  final List<Widget> icons;
  final Color moduleColor;
  final EdgeInsets padding;
  final double borderRadius;
  final double fontSize;
  final String fontFamily;
  final EdgeInsets margin;

  EventsIconsModule({
    required this.name,
    required this.icons,
    required this.moduleColor,
    required this.padding,
    required this.borderRadius,
    required this.fontSize,
    required this.fontFamily,
    required this.margin,
  });
}
