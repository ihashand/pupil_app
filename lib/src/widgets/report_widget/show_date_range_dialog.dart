import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/models/pet_model.dart';
import 'package:pet_diary/src/widgets/report_widget/generete_print_report.dart';

Future<void> showDateRangeDialog(
    BuildContext context, WidgetRef ref, Pet pet) async {
  DateTimeRange? selectedDateRange;
  await showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Chose date range',
                  style: TextStyle(
                      color: Theme.of(context).primaryColorDark, fontSize: 18),
                ),
                IconButton(
                  icon: Icon(Icons.close,
                      color: Theme.of(context).primaryColorDark),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            Divider(color: Theme.of(context).colorScheme.primary),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 5.0),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: ListTile(
                title: Text(
                  "This month",
                  style: TextStyle(
                      color: Theme.of(context).primaryColorDark, fontSize: 14),
                ),
                onTap: () {
                  selectedDateRange = DateTimeRange(
                    start:
                        DateTime(DateTime.now().year, DateTime.now().month, 1),
                    end: DateTime.now(),
                  );
                  Navigator.pop(context);
                },
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 5.0),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: ListTile(
                title: Text(
                  "Last quarter",
                  style: TextStyle(
                      color: Theme.of(context).primaryColorDark, fontSize: 14),
                ),
                onTap: () {
                  final now = DateTime.now();
                  final start = DateTime(now.year, now.month - 2, 1);
                  selectedDateRange = DateTimeRange(start: start, end: now);
                  Navigator.pop(context);
                },
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 5.0),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: ListTile(
                title: Text(
                  "Select range",
                  style: TextStyle(
                      color: Theme.of(context).primaryColorDark, fontSize: 14),
                ),
                onTap: () async {
                  final range = await showDateRangePicker(
                    context: context,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                    builder: (BuildContext context, Widget? child) {
                      return Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: ColorScheme.light(
                            primary: const Color(0xff68a2b6),
                            onPrimary: Theme.of(context).colorScheme.onPrimary,
                            surface: Theme.of(context).colorScheme.surface,
                            onSurface: Theme.of(context).colorScheme.onSurface,
                            secondary: const Color(0xffdfd785).withOpacity(0.5),
                          ),
                          dialogBackgroundColor:
                              Theme.of(context).colorScheme.surface,
                        ),
                        child: child!,
                      );
                    },
                  );
                  if (range != null) {
                    selectedDateRange = range;
                  }
                  // ignore: use_build_context_synchronously
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      );
    },
  );

  if (selectedDateRange != null) {
    await generateAndPrintReport(ref, pet, selectedDateRange!);
  }
}
