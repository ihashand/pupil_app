import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/providers/medicine_provider.dart';

class MedicinieDetailsEndDate extends ConsumerWidget {
  const MedicinieDetailsEndDate({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    DateTime endDate = ref.watch(medicineEndDateControllerProvider);
    return GestureDetector(
        onTap: () async {
          final DateTime? picked = await showDatePicker(
              context: context,
              initialDate: endDate,
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
              });
          if (picked != null && picked != endDate) {
            ref.watch(medicineEndDateControllerProvider.notifier).state =
                picked;
          }
        },
        child: SizedBox(
          width: 150,
          child: InputDecorator(
            decoration: const InputDecoration(
              labelText: 'End',
              hintText: 'DD-MM-YYYY',
              border: OutlineInputBorder(),
              labelStyle: TextStyle(
                fontSize: 16,
              ),
            ),
            child: Text(
              '${endDate.day.toString().padLeft(2, '0')}-${endDate.month.toString().padLeft(2, '0')}-${endDate.year}',
            ),
          ),
        ));
  }
}
