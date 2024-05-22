import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/providers/event_medicine_provider.dart';

class MedicineDetailsStartDate extends ConsumerWidget {
  const MedicineDetailsStartDate({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var startDate = ref.watch(eventMedicineStartDateControllerProvider);
    return GestureDetector(
        onTap: () async {
          final DateTime? picked = await showDatePicker(
            context: context,
            initialDate: startDate,
            firstDate: DateTime(2000),
            lastDate: DateTime(2101),
            builder: (BuildContext context, Widget? child) {
              return Theme(
                data: ThemeData(
                  textTheme: const TextTheme(
                    bodyLarge: TextStyle(color: Colors.black),
                  ),
                  textButtonTheme: TextButtonThemeData(
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.black,
                    ),
                  ),
                  colorScheme: const ColorScheme.light(
                    primary: Color(0xffdfd785),
                    onPrimary: Colors.black,
                  ),
                ),
                child: child!,
              );
            },
          );
          if (picked != null &&
              picked != ref.read(eventMedicineStartDateControllerProvider)) {
            ref.watch(eventMedicineStartDateControllerProvider.notifier).state =
                picked;
          }
        },
        child: SizedBox(
          width: 150,
          child: InputDecorator(
            decoration: const InputDecoration(
              labelText: 'Start',
              hintText: 'DD-MM-YYYY',
              border: OutlineInputBorder(),
              labelStyle: TextStyle(
                fontSize: 16,
              ),
            ),
            child: Text(
              '${startDate.day.toString().padLeft(2, '0')}-${startDate.month.toString().padLeft(2, '0')}-${startDate.year}',
            ),
          ),
        ));
  }
}
