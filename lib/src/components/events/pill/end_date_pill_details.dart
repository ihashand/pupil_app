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
    return Flexible(
        child: GestureDetector(
      onTap: () async {
        final DateTime? picked = await showDatePicker(
            context: context,
            initialDate: endDate,
            firstDate: DateTime(2000),
            lastDate: DateTime(2101),
            builder: (BuildContext context, Widget? child) {
              return Theme(
                data: ThemeData.light().copyWith(
                  textButtonTheme: TextButtonThemeData(
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.black,
                    ),
                  ),
                ),
                child: child!,
              );
            });
        if (picked != null && picked != endDate) {
          ref.watch(pillEndDateControllerProvider.notifier).state = picked;
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
      ),
    ));
  }
}
