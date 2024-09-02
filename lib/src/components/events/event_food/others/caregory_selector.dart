import 'package:flutter/material.dart';

Widget categorySelector(
    String title, bool isSelected, VoidCallback onTap, BuildContext context) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
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
