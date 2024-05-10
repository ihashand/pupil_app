import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/firebase_options.dart';
import 'package:pet_diary/src/auth/auth.dart';
import 'package:pet_diary/src/data/services/hive_service.dart';
import 'package:pet_diary/src/data/services/local_notification_service.dart';
import 'package:pet_diary/src/helper/notifier_service.dart';
import 'package:pet_diary/src/providers/theme_provider.dart';
import 'package:pet_diary/bottom_app_bar.dart';
import 'package:pet_diary/src/screens/settings_screen.dart';
import 'package:intl/date_symbol_data_local.dart';
// ignore: depend_on_referenced_packages
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// ignore: constant_identifier_names
const bool USE_EMULATOR = false;

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await NotificationService().initNotification();
  tz.initializeTimeZones();

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
            '/home_screen': (context) => const BotomAppBar(),
            '/settings_screen': (context) => const SettingsScreen(),
          });
    });
  }
}

// Future _connectToFirebaseEmulator() async {
//   final localHostString = Platform.isAndroid ? '10.0.2.2' : 'localhost';

//   FirebaseFirestore.instance.settings = Settings(
//     host: '$localHostString:8080',
//     sslEnabled: false,
//     persistenceEnabled: false,
//   );

//   await FirebaseAuth.instance.useAuthEmulator(localHostString, 9099);
// }
