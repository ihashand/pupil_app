import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/components/add_pet_steps/add_pet_step1_name.dart';
import 'package:pet_diary/src/helper/helper_show_avatar_selection.dart';
import 'package:pet_diary/src/providers/home_preferences_notifier.dart';
import 'package:pet_diary/src/providers/user_avatar_provider.dart';
import 'package:pet_diary/src/providers/pet_provider.dart';
import 'package:pet_diary/src/widgets/home_widgets/active_walk_card.dart';
import 'package:pet_diary/src/widgets/home_widgets/animal_card.dart';
import 'package:pet_diary/src/widgets/home_widgets/appoitment_card.dart';
import 'package:pet_diary/src/widgets/home_widgets/walk_card.dart';
import 'package:pet_diary/src/widgets/home_widgets/reminder_card.dart';
import 'settings_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  Map<String, bool> expandedEvents = {};

  @override
  void initState() {
    super.initState();
    // Inicjalizujemy userId w HomePreferencesNotifier podczas inicjalizacji
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      ref.read(homePreferencesProvider.notifier).setUserId(userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final avatarUrl = ref.watch(userAvatarProvider);
    final homePreferences = ref.watch(homePreferencesProvider);
    final homePreferencesNotifier = ref.read(homePreferencesProvider.notifier);

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(
                top: 25.0, left: 25.0, right: 25.0, bottom: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                      top: 10.0, right: 10.0, bottom: 10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Welcome back,',
                        style: TextStyle(
                          fontSize: 13,
                          fontFamily: 'San Francisco',
                        ),
                      ),
                      Text(
                        FirebaseAuth.instance.currentUser?.displayName ??
                            FirebaseAuth.instance.currentUser?.email ??
                            'Brak dostępnych informacji o użytkowniku',
                        style: const TextStyle(
                          fontSize: 18,
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
                    child: CircleAvatar(
                      backgroundColor: Colors.transparent,
                      backgroundImage: AssetImage(avatarUrl),
                      radius: 35,
                    ),
                  ),
              ],
            ),
          ),
          Divider(
            color: Theme.of(context).colorScheme.secondary,
            thickness: 1.2,
          ),
          Expanded(
            child: ReorderableListView(
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  if (newIndex > oldIndex) {
                    newIndex -= 1;
                  }
                  final item = homePreferences.sectionOrder.removeAt(oldIndex);
                  homePreferences.sectionOrder.insert(newIndex, item);
                  homePreferencesNotifier
                      .updateSectionOrder(homePreferences.sectionOrder);
                });
              },
              children: homePreferences.sectionOrder.map((section) {
                switch (section) {
                  case 'AnimalCard':
                    return const AnimalSection(key: ValueKey('AnimalCard'));
                  case 'WalkCard':
                    return const Padding(
                      key: ValueKey('WalkCard'),
                      padding: EdgeInsets.only(
                        top: 10,
                        bottom: 10,
                      ),
                      child: WalkCard(),
                    );
                  case 'ActiveWalkCard':
                    return const Padding(
                      key: ValueKey('ActiveWalkCard'),
                      padding: EdgeInsets.only(
                        top: 10,
                        bottom: 10,
                      ),
                      child: ActiveWalkCard(),
                    );
                  case 'ReminderCard':
                    return const Padding(
                      key: ValueKey('ReminderCard'),
                      padding: EdgeInsets.only(
                        top: 10,
                        bottom: 10,
                      ),
                      child: ReminderCard(),
                    );
                  case 'AppointmentCard':
                    return const Padding(
                      key: ValueKey('AppointmentCard'),
                      padding: EdgeInsets.only(
                        top: 10,
                        bottom: 10,
                      ),
                      child: AppointmentCard(),
                    );
                  default:
                    return Container(
                      key: ValueKey(section),
                    );
                }
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class AnimalSection extends ConsumerWidget {
  const AnimalSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncPets = ref.watch(petsProvider);
    return asyncPets.when(
      loading: () => const CircularProgressIndicator(),
      error: (err, stack) => const Text('Error fetching pets'),
      data: (pets) {
        return SizedBox(
          height: 230,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: pets.length + 1,
            itemBuilder: (context, index) {
              if (index < pets.length) {
                final currentPet = pets[index];
                return AnimalCard(
                    pet: currentPet, key: ValueKey(currentPet.id));
              } else {
                return InkWell(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => AddPetStep1Name(ref: ref),
                    ));
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.add,
                        size: 70, color: Color(0xff68a2b6)),
                  ),
                );
              }
            },
          ),
        );
      },
    );
  }
}
