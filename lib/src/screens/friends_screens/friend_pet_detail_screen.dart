import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/helpers/others/calculate_age.dart';
import 'package:pet_diary/src/models/events_models/event_walk_model.dart';
import 'package:pet_diary/src/models/others/pet_model.dart';
import 'package:pet_diary/src/providers/events_providers/event_walk_provider.dart';
import 'package:pet_diary/src/providers/others_providers/pet_provider.dart';

class FriendPetDetailScreen extends ConsumerWidget {
  final String petId;

  const FriendPetDetailScreen({required this.petId, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final petAsyncValue = ref.watch(petFriendServiceProvider(petId));
    final walksAsyncValue = ref.watch(eventWalksProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pet Details'),
      ),
      body: petAsyncValue.when(
        data: (pet) => SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPetInfoSection(context, pet.first),
              const Divider(),
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'Recent Activities',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              walksAsyncValue.when(
                data: (walks) {
                  final petWalks =
                      walks.where((walk) => walk!.petId == petId).toList();
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: petWalks.length,
                    itemBuilder: (context, index) {
                      final walk = petWalks[index];
                      return _buildActivityTile(context, walk!);
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(child: Text('Error: $error')),
              ),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _buildPetInfoSection(BuildContext context, Pet pet) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      margin: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Name: ${pet.name}",
              style: TextStyle(
                  color: Theme.of(context).primaryColorDark,
                  fontWeight: FontWeight.bold,
                  fontSize: 16)),
          const SizedBox(height: 5),
          Text("Birth Date: ${pet.dateTime}",
              style: TextStyle(
                  color: Theme.of(context).primaryColorDark, fontSize: 14)),
          const SizedBox(height: 5),
          Text("Breed: ${pet.breed}",
              style: TextStyle(
                  color: Theme.of(context).primaryColorDark, fontSize: 14)),
          const SizedBox(height: 5),
          Text("Current Age: ${calculateAge(pet.age)}",
              style: TextStyle(
                  color: Theme.of(context).primaryColorDark, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildActivityTile(BuildContext context, EventWalkModel walk) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: ListTile(
        leading: const Icon(Icons.directions_walk),
        title: Text('Walk on ${walk.dateTime.toLocal()}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Steps: ${walk.steps}'),
            Text('Duration: ${walk.walkTime} minutes'),
          ],
        ),
      ),
    );
  }
}
