// ignore_for_file: unused_result

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/providers/pills_provider.dart';

class EndDatePillDetails extends ConsumerWidget {
  const EndDatePillDetails({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    DateTime endDate = ref.watch(pillEndDateControllerProvider);
    return GestureDetector(
      onTap: () async {
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: endDate,
          firstDate: DateTime(2000),
          lastDate: DateTime(2101),
        );
        if (picked != null && picked != endDate) {
          ref.watch(pillEndDateControllerProvider.notifier).state = picked;
        }
      },
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'E n d  d a t e',
          hintText: 'DD-MM-YYYY',
          border: OutlineInputBorder(),
          labelStyle: TextStyle(
            fontSize: 21, // Ustaw rozmiar czcionki dla tekstu etykiety
          ),
        ),
        child: Text(
          '${endDate.day.toString().padLeft(2, '0')}-${endDate.month.toString().padLeft(2, '0')}-${endDate.year}',
        ),
      ),
    );
  }
}
