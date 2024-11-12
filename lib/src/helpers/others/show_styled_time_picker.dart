import 'package:flutter/material.dart';

Future<TimeOfDay?> showStyledTimePicker({
  required BuildContext context,
  required TimeOfDay initialTime,
}) {
  final isDarkMode = Theme.of(context).brightness == Brightness.dark;

  return showTimePicker(
    context: context,
    initialTime: initialTime,
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
