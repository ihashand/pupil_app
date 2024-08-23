import 'package:flutter/material.dart';

Widget buildCategorySelector(
    String title, bool isSelected, VoidCallback onTap, BuildContext context) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Text(
        title,
        style: TextStyle(
          color: isSelected
              ? Theme.of(context).primaryColorDark
              : Theme.of(context).colorScheme.inversePrimary,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        textAlign: TextAlign.center,
      ),
    ),
  );
}
