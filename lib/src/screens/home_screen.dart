import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:pet_diary/src/components/animal_card.dart';
import 'package:pet_diary/src/components/my_drawer.dart';
import 'package:pet_diary/src/models/pet_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  Box<Pet>? _petBox;

  @override
  void initState() {
    super.initState();
    _openPetBox();
  }

  Future<void> _openPetBox() async {
    _petBox = await Hive.openBox<Pet>('petBox');
  }

  // Logout user
  void logout() {
    FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
      ),
      drawer: const MyDrawer(),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        "My",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.inversePrimary,
                        ),
                      ),
                      Text(
                        " pupils",
                        style: TextStyle(
                          fontSize: 28,
                          color: Theme.of(context).colorScheme.inversePrimary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),
            SizedBox(
              height: 240,
              child: FutureBuilder(
                future: Hive.openBox<Pet>('petBox'),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done &&
                      _petBox != null &&
                      _petBox!.isNotEmpty) {
                    return PageView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _petBox!.length,
                      itemBuilder: (context, index) {
                        final pet = _petBox!.getAt(index);
                        return AnimalCard(pet: pet!);
                      },
                    );
                  } else {
                    return const Center(
                      child: Text('No pets available.'),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
