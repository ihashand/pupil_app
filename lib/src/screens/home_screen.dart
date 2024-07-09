import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/components/add_pet_steps/add_pet_step1_name.dart';
import 'package:pet_diary/src/helper/helper_show_avatar_selection.dart';
import 'package:pet_diary/src/providers/user_avatar_provider.dart';
import 'package:pet_diary/src/providers/event_provider.dart';
import 'package:pet_diary/src/providers/pet_provider.dart';
import 'package:pet_diary/src/providers/walk_state_provider.dart';
import 'package:pet_diary/src/widgets/health_events_widgets/event_tile.dart';
import 'package:pet_diary/src/widgets/home_widgets/active_walk_card.dart';
import 'package:pet_diary/src/widgets/home_widgets/animal_card.dart';
import 'package:pet_diary/src/widgets/home_widgets/walk_card.dart';
import 'settings_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  Map<String, bool> expandedEvents = {};
  bool _isSameDate(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  @override
  Widget build(BuildContext context) {
    final avatarUrl = ref.watch(userAvatarProvider);

    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(25.0),
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
            Consumer(builder: (context, ref, _) {
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
                          return AnimalCard(pet: currentPet);
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
            }),
            const Padding(
              padding: EdgeInsets.only(top: 15, bottom: 20),
              child: WalkCard(),
            ),
            Consumer(builder: (context, ref, _) {
              final walkState = ref.watch(walkProvider);
              return walkState.isWalking
                  ? const Padding(
                      padding: EdgeInsets.only(top: 15, bottom: 20),
                      child: ActiveWalkCard(
                        pets: [],
                      ),
                    )
                  : const SizedBox.shrink();
            }),
            Consumer(builder: (context, ref, _) {
              final asyncEvents = ref.watch(eventsProvider);
              return asyncEvents.when(
                loading: () => const CircularProgressIndicator(),
                error: (err, stack) => const Text('Error fetching events'),
                data: (events) {
                  final now = DateTime.now();
                  final todayEvents = events.where((event) {
                    final eventDate = event.eventDate;
                    return _isSameDate(eventDate, now);
                  }).toList();

                  if (todayEvents.isEmpty) {
                    final futureEvents = events.where((event) {
                      final eventDate = event.eventDate;
                      return eventDate.isAfter(now);
                    }).toList();

                    if (futureEvents.isEmpty) {
                      return const SizedBox.shrink();
                    }

                    final sortedFutureEvents = futureEvents
                      ..sort((a, b) => a.eventDate.compareTo(b.eventDate));

                    final closestFutureEvents = sortedFutureEvents
                        .where((event) => _isSameDate(event.eventDate,
                            sortedFutureEvents.first.eventDate))
                        .toList();

                    return _buildEventsList(closestFutureEvents, ref);
                  }

                  final sortedTodayEvents = todayEvents
                    ..sort((a, b) => a.eventDate.compareTo(b.eventDate));

                  return _buildEventsList(sortedTodayEvents, ref);
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildEventsList(List events, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 20),
          child: Text(
            'Events',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        SizedBox(
          height: 400,
          child: ListView.builder(
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              return GestureDetector(
                onTap: () {
                  setState(() {
                    expandedEvents[event.id] =
                        !(expandedEvents[event.id] ?? false);
                  });
                },
                child: EventTile(
                  ref: ref,
                  event: event,
                  isExpanded: expandedEvents[event.id] ?? false,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
