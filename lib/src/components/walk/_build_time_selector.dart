import 'package:flutter/material.dart';

Widget buildTimeSelector(
  BuildContext context,
  String label,
  int selectedValue,
  void Function(int value) onChanged,
  int numberLimit,
) {
  return Column(
    children: [
      Text(
        label,
        style: TextStyle(
          fontSize: 14,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
      SizedBox(
        height: 100,
        width: 50, // Set a fixed width here
        child: ListWheelScrollView(
          itemExtent: 40,
          physics: const FixedExtentScrollPhysics(),
          onSelectedItemChanged: (index) {
            onChanged(index);
          },
          controller: FixedExtentScrollController(initialItem: selectedValue),
          children: List.generate(
            numberLimit,
            (index) => Center(
              child: Text(
                '$index',
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ),
        ),
      ),
    ],
  );
}
