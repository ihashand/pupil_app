import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pet_diary/bottom_app_bar.dart';
import 'package:pet_diary/src/screens/login_register_screens/login_screen.dart';

class AuthWidget extends StatelessWidget {
  const AuthWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Jeśli stan logowania jest określony
        if (snapshot.connectionState == ConnectionState.active) {
          final User? user = snapshot.data;

          // Jeśli użytkownik jest zalogowany
          if (user != null) {
            // Nawigacja do HomeScreen z animacją
            Future.microtask(() {
              // ignore: use_build_context_synchronously
              Navigator.of(context).pushReplacement(
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      const BotomAppBar(),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                    const begin = Offset(-1.0, 0.0);
                    const end = Offset.zero;
                    const curve = Curves.easeInOutCubic;

                    final tween = Tween(begin: begin, end: end)
                        .chain(CurveTween(curve: curve));
                    final offsetAnimation = animation.drive(tween);

                    return SlideTransition(
                      position: offsetAnimation,
                      child: child,
                    );
                  },
                ),
              );
            });
          } else {
            // Nawigacja do LoginScreen z animacją
            Future.microtask(() {
              // ignore: use_build_context_synchronously
              Navigator.of(context).pushReplacement(
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      const LoginScreen(),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                    const begin = Offset(0.0, 1.0);
                    const end = Offset.zero;
                    const curve = Curves.easeInOutCubic;

                    final tween = Tween(begin: begin, end: end)
                        .chain(CurveTween(curve: curve));
                    final offsetAnimation = animation.drive(tween);

                    return SlideTransition(
                      position: offsetAnimation,
                      child: child,
                    );
                  },
                ),
              );
            });
          }
        }

        // Wyświetlanie loadera podczas inicjalizacji stanu logowania
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}
