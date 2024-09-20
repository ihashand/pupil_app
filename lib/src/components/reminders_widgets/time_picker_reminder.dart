import 'package:flutter/material.dart';

class TimePickerReminder extends StatelessWidget {
  final BuildContext context;
  final TimeOfDay selectedTime;
  final Function(TimeOfDay) onTimeSelected;

  const TimePickerReminder({
    super.key,
    required this.context,
    required this.selectedTime,
    required this.onTimeSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Time',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 5),
        GestureDetector(
          onTap: () => _selectTime(context),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              children: [
                const Icon(Icons.access_time),
                const SizedBox(width: 10),
                Text(
                  '${selectedTime.hour}:${selectedTime.minute}',
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: Theme(
            data: ThemeData(
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(
                    foregroundColor: Theme.of(context).primaryColorDark),
              ),
              colorScheme: ColorScheme.light(
                primary: const Color(0xff68a2b6),
                onPrimary: Theme.of(context).primaryColorDark,
                surface: Theme.of(context).colorScheme.primary,
                onSurface: Theme.of(context).primaryColorDark,
              ),
            ),
            child: child!,
          ),
        );
      },
    );

    if (picked != null && picked != selectedTime) {
      onTimeSelected(picked);
    }
  }
}
