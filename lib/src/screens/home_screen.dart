import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pet_diary/src/components/my_drawer.dart';

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
            backgroundColor: Colors.transparent,
            actions: [
              IconButton(onPressed: logout, icon: const Icon(Icons.logout)),
            ]),
        drawer: const MyDrawer(),
        body: Center(
          child:
              Text(FirebaseAuth.instance.currentUser?.email ?? 'Not logged in'),
        ));
  }
}
