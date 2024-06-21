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
        title: const Text("Chose date range"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                  color: const Color(0xff68a2b6).withOpacity(0.2),
                  borderRadius: const BorderRadius.all(Radius.circular(10))),
              child: ListTile(
                title: const Text("This month"),
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
              margin: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                  color: const Color(0xff68a2b6).withOpacity(0.2),
                  borderRadius: const BorderRadius.all(Radius.circular(10))),
              child: ListTile(
                title: const Text("Last quarter"),
                onTap: () {
                  final now = DateTime.now();
                  final start = DateTime(now.year, now.month - 2, 1);
                  selectedDateRange = DateTimeRange(start: start, end: now);
                  Navigator.pop(context);
                },
              ),
            ),
            Container(
              margin: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                  color: const Color(0xff68a2b6).withOpacity(0.2),
                  borderRadius: const BorderRadius.all(Radius.circular(10))),
              child: ListTile(
                title: const Text("Select range"),
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
                              onPrimary:
                                  Theme.of(context).colorScheme.onPrimary,
                              surface: Theme.of(context).colorScheme.surface,
                              onSurface:
                                  Theme.of(context).colorScheme.onSurface,
                              secondary:
                                  const Color(0xffdfd785).withOpacity(0.5)),
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
