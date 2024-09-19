import 'package:flutter/material.dart';

class SwitchWidget extends StatelessWidget {
  final String selectedView;
  final ValueChanged<String> onSelectedViewChanged;

  const SwitchWidget({
    required this.selectedView,
    required this.onSelectedViewChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: ['D', 'W', 'M'].map((label) {
          String displayLabel = label;
          Color bgColor = Colors.transparent;
          if (selectedView == label) {
            if (label == 'D') displayLabel = 'Day';
            if (label == 'W') displayLabel = 'Week';
            if (label == 'M') displayLabel = 'Month';
            bgColor = const Color(0xff68a2b6)
                .withOpacity(0.2); // Niebieskie tło dla wybranego przycisku
          }
          return TextButton(
            onPressed: () {
              onSelectedViewChanged(label);
            },
            style: TextButton.styleFrom(
              backgroundColor: bgColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              displayLabel,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: selectedView == label
                    ? Theme.of(context)
                        .primaryColorDark // Biały tekst dla wybranego przycisku
                    : Theme.of(context).primaryColorDark.withOpacity(0.5),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
