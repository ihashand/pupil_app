import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:pet_diary/firebase_options.dart';
import 'package:pet_diary/src/auth/auth.dart';
import 'package:pet_diary/src/auth/login_or_register.dart';
import 'package:pet_diary/src/data/services/hive_service.dart';
import 'package:pet_diary/src/providers/theme_provider.dart';
import 'package:pet_diary/src/screens/home_screen.dart';
import 'package:pet_diary/src/screens/my_animals_screen.dart';
import 'package:pet_diary/src/screens/settings_screen.dart';
import 'package:pet_diary/src/screens/users_screen.dart';
import 'package:provider/provider.dart';
import 'src/screens/profile_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final hiveService = HiveService();
  await hiveService.initHive();

  runApp(ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: EasyLocalization(
        supportedLocales: const [Locale('en'), Locale('de'), Locale('pl')],
        path: 'assets/translations',
        fallbackLocale: const Locale('en'),
        child: const MyApp(),
      )));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: const AuthWidget(),
        theme: Provider.of<ThemeProvider>(context).themeData,
        routes: {
          '/login_register_screen': (context) => const LoginOrRegister(),
          '/home_screen': (context) => const HomeScreen(),
          '/profile_screen': (context) => const ProfileScreen(),
          '/settings_screen': (context) => const SettingsScreen(),
          '/users_screen': (context) => const UsersScreen(),
          '/my_animals_screen': (context) => const MyAnimalsScreen(),
        });
  }
}
