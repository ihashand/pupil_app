import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pet_diary/src/widgets/health_activity_widgets/arrow_button.dart';

class DayView extends StatelessWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateChanged;

  const DayView({
    required this.selectedDate,
    required this.onDateChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(0.0),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: const BorderRadius.all(Radius.circular(10)),
        ),
        child: Column(
          children: [
            Divider(color: Theme.of(context).colorScheme.secondary, height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ArrowButton(
                    icon: Icons.arrow_back_ios,
                    onPressed: () {
                      onDateChanged(
                          selectedDate.subtract(const Duration(days: 1)));
                    },
                  ),
                  Text(
                    DateFormat('EEEE, d MMMM', 'en_US').format(selectedDate),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColorDark,
                    ),
                  ),
                  ArrowButton(
                    icon: Icons.arrow_forward_ios,
                    onPressed: () {
                      onDateChanged(selectedDate.add(const Duration(days: 1)));
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
