import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // loggout user
  void logout() {
    FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: const Text('Home'),
            backgroundColor: Colors.deepPurple,
            actions: [
              IconButton(onPressed: logout, icon: Icon(Icons.logout)),
            ]),
        body: Center(
          child:
              Text(FirebaseAuth.instance.currentUser?.email ?? 'Not logged in'),
        ));
  }
}
