import 'package:flutter/material.dart';
import 'package:pet_diary/src/models/module_item.dart';

ModuleItem noteButtonModuleItem({
  required String buttonText,
  required VoidCallback onPressed,
  Color buttonColor = Colors.blue,
  double buttonWidth = 200.0,
  double buttonHeight = 50.0,
  TextStyle textStyle = const TextStyle(fontSize: 16, color: Colors.white),
}) {
  return ModuleItem(
    content: SizedBox(
      width: buttonWidth,
      height: buttonHeight,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          foregroundColor: textStyle.color,
          backgroundColor: buttonColor,
          textStyle: textStyle,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
        ),
        child: Text(buttonText),
      ),
    ),
  );
}
