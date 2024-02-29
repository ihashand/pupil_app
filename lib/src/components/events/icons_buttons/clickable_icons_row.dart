import 'package:flutter/material.dart';
import 'package:pet_diary/src/models/icon_layout.dart';

class ClickableIconsRow extends StatelessWidget {
  final IconData icon1, icon2, icon3, icon4;
  final double iconSize;
  final Color icon1Color, icon2Color, icon3Color, icon4Color;
  final double spacing;
  final VoidCallback onTap1, onTap2, onTap3, onTap4;
  final String text1, text2, text3, text4;
  final double textSize;
  final IconLayout layout;

  const ClickableIconsRow({
    super.key,
    required this.icon1,
    required this.icon2,
    required this.icon3,
    required this.icon4,
    this.iconSize = 24.0,
    this.icon1Color = Colors.black,
    this.icon2Color = Colors.black,
    this.icon3Color = Colors.black,
    this.icon4Color = Colors.black,
    this.spacing = 8.0,
    required this.onTap1,
    required this.onTap2,
    required this.onTap3,
    required this.onTap4,
    required this.text1,
    required this.text2,
    required this.text3,
    required this.text4,
    this.textSize = 12.0,
    this.layout = IconLayout.horizontal,
  });

  @override
  Widget build(BuildContext context) {
    List<Widget> iconWidgets = [
      iconButtonWithText(icon1, icon1Color, onTap1, text1),
      SizedBox(
          width: layout == IconLayout.horizontal ? spacing : 0,
          height: layout == IconLayout.vertical ? spacing : 0),
      iconButtonWithText(icon2, icon2Color, onTap2, text2),
      SizedBox(
          width: layout == IconLayout.horizontal ? spacing : 0,
          height: layout == IconLayout.vertical ? spacing : 0),
      iconButtonWithText(icon3, icon3Color, onTap3, text3),
      SizedBox(
          width: layout == IconLayout.horizontal ? spacing : 0,
          height: layout == IconLayout.vertical ? spacing : 0),
      iconButtonWithText(icon4, icon4Color, onTap4, text4),
    ];

    return layout == IconLayout.horizontal
        ? Row(
            mainAxisAlignment: MainAxisAlignment.center, children: iconWidgets)
        : Column(
            mainAxisAlignment: MainAxisAlignment.center, children: iconWidgets);
  }

  Widget iconButtonWithText(
      IconData icon, Color color, VoidCallback onTap, String text) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
            icon: Icon(icon, size: iconSize, color: color), onPressed: onTap),
        Text(text, style: TextStyle(fontSize: textSize)),
      ],
    );
  }
}
