import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/bottom_app_bar.dart';
import 'package:pet_diary/firebase_options.dart';
import 'package:pet_diary/src/auth/auth.dart';
import 'package:pet_diary/src/providers/others_providers/theme_provider.dart';
import 'package:pet_diary/src/providers/others_providers/user_provider.dart';
import 'package:pet_diary/src/screens/login_register_screens/login_screen.dart';
import 'package:pet_diary/src/screens/other_screens/settings_screen.dart';
import 'package:pet_diary/src/services/achievements_services/achievement_service.dart';
import 'package:pet_diary/src/services/events_services/event_type_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:pet_diary/src/services/notification_services/notification_services.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final notificationService = NotificationService();
  await notificationService.initialize();

  await EasyLocalization.ensureInitialized();
  await initializeDateFormatting('en_US', null);
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Inicjalizacja osiągnięć i ustawień użytkownika
  await AchievementService().initializeAchievements();
  await initializeUserSettings();

  runApp(ProviderScope(
    overrides: [
      userIdProvider.overrideWith((ref) {
        final currentUser = FirebaseAuth.instance.currentUser;
        return currentUser?.uid;
      }),
    ],
    child: EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('de'), Locale('pl')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      child: const MyApp(),
    ),
  ));
}

Future<void> initializeUserSettings() async {
  // Inicjalizacja preferencji typu wydarzeń
  final eventTypeService = EventTypeService();
  await eventTypeService.initializeEventTypePreferences();
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
          '/home_screen': (context) => const BotomAppBar(),
          '/settings_screen': (context) => const SettingsScreen(),
          '/login_screen': (context) => const LoginScreen(),
        },
      );
    });
  }
}
