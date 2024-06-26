import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/components/animal_card.dart';
import 'package:pet_diary/src/components/add_pet_steps/add_pet_step1_name.dart';
import 'package:pet_diary/src/components/my_button_widget.dart';
import 'package:pet_diary/src/helper/helper_show_avatar_selection.dart';
import 'package:pet_diary/src/providers/user_avatar_provider.dart';
import 'package:pet_diary/src/providers/event_provider.dart';
import 'package:pet_diary/src/providers/pet_provider.dart';
import 'package:pet_diary/src/widgets/health_events_widgets/event_tile.dart';
import 'settings_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final avatarUrl = ref.watch(userAvatarProvider);

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
                    padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
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
                          FirebaseAuth.instance.currentUser?.displayName ??
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
                  if (FirebaseAuth.instance.currentUser != null)
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const SettingsScreen()),
                        );
                      },
                      onLongPress: () {
                        showAvatarSelectionDialog(
                          context: context,
                          onAvatarSelected: (String path) {
                            ref.read(userAvatarProvider.notifier).state = path;
                            FirebaseAuth.instance.currentUser
                                ?.updatePhotoURL(path);
                          },
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(
                          right: 12.0,
                        ),
                        child: CircleAvatar(
                          backgroundColor: Colors.transparent,
                          backgroundImage: AssetImage(avatarUrl),
                          radius: 40,
                        ),
                      ),
                    )
                ],
              ),
            ),
            Consumer(builder: (context, ref, _) {
              final asyncPets = ref.watch(petsProvider);

              return asyncPets.when(
                loading: () => const CircularProgressIndicator(),
                error: (err, stack) => const Text('Error fetching pets'),
                data: (pets) {
                  return SizedBox(
                    height: 220,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: pets.length + 1,
                      itemBuilder: (context, index) {
                        if (index < pets.length) {
                          final currentPet = pets[index];
                          return SizedBox(
                            height: 300,
                            width: 180,
                            child: AnimalCard(pet: currentPet),
                          );
                        } else {
                          return InkWell(
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
                          );
                        }
                      },
                    ),
                  );
                },
              );
            }),
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
              imageAsset: "assets/images/dog_details_background_02.png",
              borderRadius: 20.0,
              width: 350.0,
              fontSize: 14.0,
              opacity: 0.6,
              bottomColor: Theme.of(context).colorScheme.primary,
              topHeight: 85,
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
                    ]),
              ),
            ),
            const SizedBox(
              child: Padding(
                padding: EdgeInsets.fromLTRB(10, 15.0, 290.0, 15.0),
                child: Text(
                  'Events',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
            Consumer(builder: (context, ref, _) {
              final asyncEvents = ref.watch(eventsProvider);

              return asyncEvents.when(
                loading: () => const CircularProgressIndicator(),
                error: (err, stack) => const Text('Error fetching events'),
                data: (events) {
                  if (events.isEmpty) {
                    return const Text(
                      'No events for today or in the future',
                    );
                  }
                  return SizedBox(
                    height: 380,
                    child: ListView.builder(
                      scrollDirection: Axis.vertical,
                      itemCount: events.length,
                      itemBuilder: (context, index) {
                        final currentEvent = events[index];
                        return SizedBox(
                          height: 93,
                          width: 400,
                          child: EventTile(
                            event: currentEvent,
                            ref: ref,
                            isExpanded: false,
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            }),
          ],
        ),
      ),
    );
  }
}
