import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/components/animal_card.dart';
import 'package:pet_diary/src/components/my_button_widget.dart';
import 'package:pet_diary/src/providers/pet_provider.dart';
import 'package:pet_diary/src/providers/user_provider.dart';
import 'package:pet_diary/src/screens/new_pet_screen.dart';
import 'settings_screen.dart';

class HomePageScreen extends ConsumerWidget {
  const HomePageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final petState = ref.watch(petRepositoryProvider);
    final pets = petState.value?.getPets();

    User? user = ref.watch(userProvider); // Watch the user provider

    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Welcome back,',
                            style: TextStyle(
                              fontSize: 15,
                              fontFamily: 'San Francisco',
                            ),
                          ),
                          Text(
                            FirebaseAuth.instance.currentUser?.email ??
                                'Brak dostępnych informacji o użytkowniku',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'San Francisco',
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (user != null)
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const SettingsScreen()),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(
                            right: 12.0,
                          ),
                          child: CircleAvatar(
                            backgroundColor:
                                const Color.fromARGB(255, 201, 120, 197),
                            backgroundImage:
                                ExactAssetImage(user.photoURL ?? ''),
                            radius: 40,
                          ),
                        ),
                      )
                  ]),
            ),
            const SizedBox(height: 10),
            if (pets != null && pets.isEmpty)
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const NewPetScreen()),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: Colors.transparent, // Dostosuj kolor tła ikony
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.add,
                    size: 80, // Dostosuj rozmiar ikony
                    color: Colors.purple, // Dostosuj kolor ikony
                  ),
                ),
              )
            else
              SizedBox(
                height: 220,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: pets?.length ?? 0,
                  itemBuilder: (context, index) {
                    final currentPet = pets![index];
                    final petLenght = pets.length;
                    return Row(
                      children: [
                        SizedBox(
                          height: 220,
                          width: 165,
                          child: AnimalCard(pet: currentPet),
                        ),
                        if (petLenght - 1 == index)
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const NewPetScreen()),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                color: Colors
                                    .transparent, // Dostosuj kolor tła ikony
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.add,
                                size: 80, // Dostosuj rozmiar ikony
                                color: Colors.purple, // Dostosuj kolor ikony
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),
            const SizedBox(height: 30),
            Column(
              children: [
                SizedBox(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Invitation for a walk                ',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'San Francisco',
                          color: Theme.of(context).primaryColorDark,
                        ),
                      ),
                      TextButton(
                          onPressed: () {},
                          child: const Text(
                            "Create",
                            style: TextStyle(
                                color: Color.fromARGB(255, 201, 120, 197),
                                fontSize: 18,
                                fontFamily: 'San Francisco',
                                fontWeight: FontWeight.bold),
                          ))
                    ],
                  ),
                ),
                MyRectangleWidget(
                  onTap: () {
                    if (kDebugMode) {
                      print('Widget tapped');
                    }
                  },
                  imageAsset: "assets/images/background_03.jpg",
                  borderRadius: 20.0,
                  width: 350.0,
                  fontSize: 14.0,
                  opacity: 0.6,
                  bottomColor: Theme.of(context).colorScheme.primary,
                  topHeight: 130,
                  bottomHeight: 80,
                  bottomContent: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Sid and Lilu',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'San Francisco',
                                color: Theme.of(context).primaryColorDark,
                              ),
                            ),
                            Text(
                              'Today 12:00',
                              style: TextStyle(
                                fontSize: 12,
                                fontFamily: 'San Francisco',
                                color: Theme.of(context).primaryColorDark,
                              ),
                            ),
                          ],
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromARGB(255, 201, 120, 197),
                            minimumSize: const Size(20, 35),
                          ),
                          onPressed: () {},
                          child: Text(
                            'Route',
                            style: TextStyle(
                              fontSize: 16,
                              fontFamily: 'San Francisco',
                              color: Theme.of(context).primaryColorDark,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
