import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/components/animal_card.dart';
import 'package:pet_diary/src/components/add_pet_steps/add_pet_step1_name.dart';
import 'package:pet_diary/src/providers/pet_provider.dart';
import 'package:pet_diary/src/providers/user_provider.dart';
import 'settings_screen.dart';

class HomePageScreen extends ConsumerStatefulWidget {
  const HomePageScreen({super.key});

  @override
  ConsumerState<HomePageScreen> createState() => _HomePageScreenState();
}

class _HomePageScreenState extends ConsumerState<HomePageScreen> {
  @override
  Widget build(BuildContext context) {
    final petState = ref.watch(petRepositoryProvider);
    final pets = petState.value?.getPets();
    User? user = ref.watch(userProvider);

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
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => AddPetStep1Name(ref: ref),
                  ));
                },
                child: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.add,
                    size: 80,
                    color: Colors.purple,
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
                          height: 300,
                          width: 180,
                          child: AnimalCard(petId: currentPet.id),
                        ),
                        if (petLenght - 1 == index)
                          InkWell(
                            onTap: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                builder: (_) => AddPetStep1Name(ref: ref),
                              ));
                            },
                            child: Container(
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.add,
                                size: 80,
                                color: Colors.purple,
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
