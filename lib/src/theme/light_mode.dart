import 'package:flutter/material.dart';

ThemeData lightMode = ThemeData(
  brightness: Brightness.light,
  useMaterial3: true,
  colorScheme: ColorScheme.light(
    onPrimary: Colors.grey.shade100,
    surface: Colors.grey.shade200,
    primary: Colors.white,
    secondary: Colors.grey.shade300,
    inversePrimary: Colors.grey.shade400,
    onSecondary: Colors.grey.shade500,
  ),
  primaryColor: const Color.fromARGB(255, 255, 255, 255),
  primaryColorLight: const Color.fromARGB(255, 40, 40, 40),
  primaryColorDark: Colors.black,
  cardColor: const Color(0xFF023047),
  textTheme: ThemeData.light()
      .textTheme
      .apply(bodyColor: Colors.grey[800], displayColor: Colors.black),
);
