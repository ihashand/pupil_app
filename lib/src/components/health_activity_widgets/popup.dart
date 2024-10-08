import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/models/events_models/event_walk_model.dart';
import 'package:pet_diary/src/providers/events_providers/event_walk_provider.dart';

class Popup extends StatelessWidget {
  final DateTime selectedDate;
  final String petId;
  final ValueChanged<String> onSelectedViewChanged;

  const Popup({
    required this.selectedDate,
    required this.petId,
    required this.onSelectedViewChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Consumer(builder: (context, ref, _) {
            final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

            // Używaj nowego providera z userId i petId
            final asyncWalks = ref.watch(eventWalksProviderFamily(
                {'userId': currentUserId, 'petId': petId}));

            return asyncWalks.when(
              loading: () => const CircularProgressIndicator(),
              error: (err, stack) => Text('Error fetching walks: $err'),
              data: (walks) {
                List<EventWalkModel?> petWalks =
                    walks.where((walk) => walk.petId == petId).toList();
                double steps = 0;

                if (petWalks.isNotEmpty) {
                  var dateTime = selectedDate;
                  List<EventWalkModel?> todaySortedWalks;
                  todaySortedWalks = petWalks
                      .where((element) =>
                          element?.dateTime.day == dateTime.day &&
                          element?.dateTime.year == dateTime.year &&
                          element?.dateTime.month == dateTime.month)
                      .toList();
                  for (var walk in todaySortedWalks) {
                    steps += walk!.steps;
                  }
                  return Column(
                    children: [
                      Row(
                        children: [
                          Text(
                            '${steps.toInt()} steps',
                            style: TextStyle(
                              color: Theme.of(context).primaryColorDark,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.arrow_forward,
                              color: Theme.of(context).primaryColorDark,
                              size: 20,
                            ),
                            onPressed: () {
                              onSelectedViewChanged('D');
                            },
                          ),
                        ],
                      ),
                    ],
                  );
                } else {
                  return Column(
                    children: [
                      Text(
                        '',
                        style: TextStyle(
                          color: Theme.of(context).primaryColorDark,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.arrow_forward,
                          color: Theme.of(context).primaryColorDark,
                          size: 20,
                        ),
                        onPressed: () {
                          onSelectedViewChanged('D');
                        },
                      ),
                    ],
                  );
                }
              },
            );
          }),
        ],
      ),
    );
  }
}
