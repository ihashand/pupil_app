import 'package:flutter/material.dart';

Future<TimeOfDay?> showStyledTimePicker({
  required BuildContext context,
  required TimeOfDay initialTime,
}) {
  return showTimePicker(
    context: context,
    initialTime: initialTime,
    builder: (BuildContext context, Widget? child) {
      return Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(
            primary: Theme.of(context).colorScheme.secondary,
            onPrimary: Theme.of(context).primaryColorDark,
            onSurface: Theme.of(context).primaryColorDark,
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).primaryColorDark,
            ),
          ),
        ),
        child: child!,
      );
    },
  );
}
