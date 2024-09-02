import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/screens/food_screen.dart';
import 'package:pet_diary/src/components/events/event_food/others/_get_formatted_date.dart';

Widget buildDateSelector(BuildContext context, WidgetRef ref) {
  final selectedDate = ref.watch(selectedDateProvider);
  final today = DateTime.now();
  final formattedDate = getFormattedDate(selectedDate, today);

  return GestureDetector(
    onTap: () async {
      final pickedDate = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(2000),
        lastDate: DateTime(2101),
      );
      if (pickedDate != null) {
        ref.read(selectedDateProvider.notifier).state = pickedDate;
      }
    },
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon:
              Icon(Icons.arrow_left, color: Theme.of(context).primaryColorDark),
          onPressed: () {
            ref.read(selectedDateProvider.notifier).state =
                selectedDate.subtract(const Duration(days: 1));
          },
        ),
        Text(
          formattedDate,
          style: TextStyle(
            fontSize: 16,
            color: Theme.of(context).primaryColorDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        IconButton(
          icon: Icon(Icons.arrow_right,
              color: Theme.of(context).primaryColorDark),
          onPressed: () {
            ref.read(selectedDateProvider.notifier).state =
                selectedDate.add(const Duration(days: 1));
          },
        ),
      ],
    ),
  );
}
