import 'package:flutter/material.dart';

Future<DateTime?> showStyledDatePicker({
  required BuildContext context,
  required DateTime initialDate,
  DateTime? firstDate,
  DateTime? lastDate,
}) {
  final isDarkMode = Theme.of(context).brightness == Brightness.dark;

  return showDatePicker(
    context: context,
    initialDate: initialDate,
    firstDate: firstDate ?? DateTime(2000),
    lastDate: lastDate ?? DateTime(2100),
    builder: (BuildContext context, Widget? child) {
      return Theme(
        data: Theme.of(context).copyWith(
          colorScheme: isDarkMode
              ? ColorScheme.dark(
                  primary: Theme.of(context).colorScheme.secondary,
                  onPrimary: Theme.of(context).primaryColorLight,
                  onSurface: Theme.of(context).primaryColorLight,
                )
              : ColorScheme.light(
                  primary: Theme.of(context).colorScheme.secondary,
                  onPrimary: Theme.of(context).primaryColorDark,
                  onSurface: Theme.of(context).primaryColorDark,
                ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: isDarkMode
                  ? Theme.of(context).primaryColorLight
                  : Theme.of(context).primaryColorDark,
            ),
          ),
        ),
        child: child!,
      );
    },
  );
}
