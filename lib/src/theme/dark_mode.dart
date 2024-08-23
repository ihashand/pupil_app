import 'package:flutter/material.dart';

ThemeData darkMode = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
        surface: Colors.grey.shade900,
        primary: Colors.grey.shade800,
        secondary: Colors.grey.shade700,
        tertiary: Colors.grey.shade600,
        inversePrimary: Colors.grey.shade500),
    primaryColor: const Color.fromARGB(255, 0, 0, 0),
    primaryColorLight: const Color.fromARGB(255, 173, 173, 173),
    primaryColorDark: Colors.white,
    cardColor: const Color.fromARGB(255, 84, 146, 164),
    textTheme: ThemeData.dark()
        .textTheme
        .apply(bodyColor: Colors.grey[300], displayColor: Colors.white));
