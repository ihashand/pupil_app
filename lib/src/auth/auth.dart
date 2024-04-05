import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pet_diary/src/auth/login_or_register.dart';
import 'package:pet_diary/bottom_app_bar.dart';

class AuthWidget extends StatelessWidget {
  const AuthWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // If user is loged in
          if (snapshot.hasData) {
            return const BotomAppBar();
          }
          // If user is NOT logged in
          else {
            return const LoginOrRegister();
          }
        },
      ),
    );
  }
}
