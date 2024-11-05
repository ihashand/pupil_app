import 'package:flutter/material.dart';

Widget buildIconForEvent({
  String? assetPath,
  IconData? icon,
  required String type,
  required String selectedType,
  required ValueChanged<String> onTap,
  required BuildContext context,
  required Color activeColor,
  double paddingLeft = 0.0,
  double paddingRight = 0.0,
  double paddingTop = 8.0,
  double paddingBottom = 4.0,
  double iconSize = 80.0, // Dodanie rozmiaru ikony
  double fontSize = 16.0, // Dodanie rozmiaru czcionki
  double textPaddingLeft = 0.0, // Dodanie paddingu tekstu z lewej
  double textPaddingRight = 0.0, // Dodanie paddingu tekstu z prawej
  double textPaddingTop = 0.0, // Dodanie paddingu tekstu z góry
  double textPaddingBottom = 0.0, // Dodanie paddingu tekstu z dołu
}) {
  return GestureDetector(
    onTap: () {
      onTap(type);
    },
    child: Column(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(
              paddingLeft, paddingTop, paddingRight, paddingBottom),
          child: assetPath != null
              ? Image.asset(
                  assetPath,
                  width: iconSize,
                  color: selectedType == type ? activeColor : Colors.grey,
                )
              : Icon(
                  icon,
                  size: iconSize,
                  color: selectedType == type ? activeColor : Colors.grey,
                ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(textPaddingLeft, textPaddingTop,
              textPaddingRight, textPaddingBottom),
          child: Text(
            type,
            style: TextStyle(
              color: Theme.of(context).primaryColorDark,
              fontSize: fontSize,
            ),
          ),
        ),
      ],
    ),
  );
}
