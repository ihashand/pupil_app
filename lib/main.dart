import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:pet_diary/firebase_options.dart';
import 'package:pet_diary/src/auth/auth.dart';
import 'package:pet_diary/src/auth/login_or_register.dart';
import 'package:pet_diary/src/theme/light_mode.dart';

import 'src/theme/dark_mode.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(EasyLocalization(
    supportedLocales: const [Locale('en'), Locale('de'), Locale('pl')],
    path: 'assets/translations',
    fallbackLocale: const Locale('en'),
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const AuthWidget(),
      theme: lightMode,
      darkTheme: darkMode,
    );
  }
}
