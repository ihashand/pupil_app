import 'package:flutter/material.dart';

ThemeData lightMode = ThemeData(
  brightness: Brightness.light,
  useMaterial3: true,
  colorScheme: ColorScheme.light(
      surface: Colors.grey.shade200,
      primary: Colors.white,
      secondary: Colors.grey.shade300,
      inversePrimary: Colors.grey.shade400),
  primaryColor: const Color.fromARGB(255, 255, 255, 255),
  primaryColorLight: const Color.fromARGB(255, 40, 40, 40),
  primaryColorDark: Colors.black,
  cardColor: const Color.fromARGB(255, 149, 207, 225),
  textTheme: ThemeData.light()
      .textTheme
      .apply(bodyColor: Colors.grey[800], displayColor: Colors.black),
);
