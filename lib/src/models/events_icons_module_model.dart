import 'package:flutter/material.dart';
import 'package:pet_diary/src/components/my_button_widget.dart';

class EventsIconsModule {
  final String name;
  final List<MyButtonWidget> icons;
  final Color moduleColor;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final double fontSize;
  final String fontFamily;
  final EdgeInsetsGeometry margin;

  EventsIconsModule({
    required this.name,
    required this.icons,
    required this.moduleColor,
    this.padding = EdgeInsets.zero,
    this.borderRadius = 0.0,
    this.fontSize = 12.0,
    this.fontFamily = 'San Francisco',
    this.margin = EdgeInsets.zero,
  });
}
