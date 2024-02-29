import 'package:flutter/material.dart';
import 'package:pet_diary/src/models/module_item.dart';

class EventsIconsModule {
  String name;
  List<ModuleItem> items; // Zaktualizowane z icons do items
  Color moduleColor;
  EdgeInsets padding;
  double borderRadius;
  double fontSize;
  String fontFamily;
  EdgeInsets margin;

  EventsIconsModule({
    required this.name,
    required this.items, // Zaktualizowane
    required this.moduleColor,
    required this.padding,
    required this.borderRadius,
    required this.fontSize,
    required this.fontFamily,
    required this.margin,
  });
}
