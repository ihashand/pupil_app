import 'package:flutter/material.dart';

class DatePickerReminder extends StatelessWidget {
  final BuildContext context;
  final String label;
  final DateTime date;
  final Function(BuildContext) selectDate;

  const DatePickerReminder({
    super.key,
    required this.context,
    required this.label,
    required this.date,
    required this.selectDate,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 5),
        GestureDetector(
          onTap: () => selectDate(context),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              border: Border.all(color: Colors.black),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today),
                const SizedBox(width: 10),
                Text(
                  '${date.day}-${date.month}-${date.year}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).primaryColorDark,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
