import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pet_diary/src/components/animal_cards.dart';
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
        // app bar
        appBar: AppBar(
          backgroundColor: Colors.transparent,
        ),
        drawer: const MyDrawer(),
        body: SafeArea(
            child: Column(children: [
          Padding(
            padding: (const EdgeInsets.symmetric(horizontal: 25.0)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // MyDrawer
                Row(
                  children: [
                    Text(
                      "My",
                      style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.inversePrimary),
                    ),
                    Text(
                      " pupils",
                      style: TextStyle(
                          fontSize: 28,
                          color: Theme.of(context).colorScheme.inversePrimary),
                    ),
                  ],
                ),

                // Add new animal
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.inversePrimary,
                      shape: BoxShape.circle),
                  child: const Icon(Icons.add),
                )
              ],
            ),
          ),
          const SizedBox(height: 25),
          SizedBox(
              height: 240,
              child: PageView(
                scrollDirection: Axis.horizontal,
                children: const [AnimalCards(), AnimalCards(), AnimalCards()],
              )),
        ])));
  }
}
