import 'package:flutter/material.dart';

class TileInfoModel {
  final IconData icon;
  final String title;
  final Color color;
  final List<String> keywords;
  final VoidCallback? onTap;

  TileInfoModel(this.icon, this.title, this.color, this.keywords, {this.onTap});
}
