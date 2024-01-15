import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/firebase_options.dart';
import 'package:pet_diary/src/auth/auth.dart';
import 'package:pet_diary/src/auth/login_or_register.dart';
import 'package:pet_diary/src/data/services/hive_service.dart';
import 'package:pet_diary/src/data/services/local_notification_service.dart';
import 'package:pet_diary/src/providers/theme_provider.dart';
import 'package:pet_diary/src/screens/home_screen.dart';
import 'package:pet_diary/src/screens/my_animals_screen.dart';
import 'package:pet_diary/src/screens/settings_screen.dart';
import 'package:pet_diary/src/screens/new_event_screen.dart';
import 'src/screens/my_calendar_screen.dart';
import 'package:intl/date_symbol_data_local.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final hiveService = HiveService();
  await hiveService.initHive();
  await LocalNotificationService().setup();
  initializeDateFormatting('en_US', null);

  runApp(ProviderScope(
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
    return Consumer(builder: (context, watch, _) {
      final theme = watch.watch(themeProvider);

      return MaterialApp(
          debugShowCheckedModeBanner: false,
          home: const AuthWidget(),
          theme: theme.themeData,
          routes: {
            '/login_register_screen': (context) => const LoginOrRegister(),
            '/home_screen': (context) => const HomeScreen(),
            '/profile_screen': (context) => const MyCalendarScreen(),
            '/settings_screen': (context) => const SettingsScreen(),
            '/my_animals_screen': (context) => const MyAnimalsScreen(),
          });
    });
  }
}
