// ignore_for_file: unused_result
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/providers/pills_provider.dart';

class StartDatePillDetails extends ConsumerWidget {
  const StartDatePillDetails({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var startDate = ref.watch(pillStartDateControllerProvider);
    return GestureDetector(
      onTap: () async {
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: startDate,
          firstDate: DateTime(2000),
          lastDate: DateTime(2101),
          builder: (BuildContext context, Widget? child) {
            return Theme(
              data: ThemeData.light().copyWith(
                textButtonTheme: TextButtonThemeData(
                  style: TextButton.styleFrom(
                    foregroundColor:
                        Colors.black, // Kolor tekstu przycisku 'OK'
                  ),
                ),
              ),
              child: child!,
            );
          },
        );
        if (picked != null &&
            picked != ref.read(pillStartDateControllerProvider)) {
          ref.watch(pillStartDateControllerProvider.notifier).state = picked;
        }
      },
      child: SizedBox(
        width: 150, // Ograniczenie szerokości InputDecorator
        child: InputDecorator(
          decoration: const InputDecoration(
            labelText: 'S t a r t',
            hintText: 'DD-MM-YYYY',
            border: OutlineInputBorder(),
            labelStyle: TextStyle(
              fontSize: 16, // Ustaw rozmiar czcionki dla tekstu etykiety
            ),
          ),
          child: Text(
            '${startDate.day.toString().padLeft(2, '0')}-${startDate.month.toString().padLeft(2, '0')}-${startDate.year}',
          ),
        ),
      ),
    );
  }
}
