import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/helper/calculate_age.dart';
import 'package:pet_diary/src/models/event_walk_model.dart';
import 'package:pet_diary/src/models/pet_model.dart';
import 'package:pet_diary/src/providers/event_walk_provider.dart';
import 'package:pet_diary/src/providers/pet_provider.dart';
import 'package:pet_diary/src/widgets/health_activity_widgets/activity_data_row.dart';
import 'package:pet_diary/src/widgets/health_activity_widgets/section_title.dart';

class StatisticsScreen extends ConsumerStatefulWidget {
  final Pet initialPet;
  final String userId;

  const StatisticsScreen(
      {required this.initialPet, required this.userId, super.key});

  @override
  createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends ConsumerState<StatisticsScreen> {
  late Pet selectedPet;

  @override
  void initState() {
    super.initState();
    selectedPet = widget.initialPet;
  }

  @override
  Widget build(BuildContext context) {
    final asyncPets = ref.watch(petFriendServiceProvider(widget.userId));
    final asyncWalks = ref.watch(eventWalksFriendProvider(widget.userId));

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: const Text(
          'S T A T I S T I T C',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
        ),
        iconTheme:
            IconThemeData(color: Theme.of(context).primaryColorDark, size: 20),
        toolbarHeight: 50,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(25),
                      bottomRight: Radius.circular(25))),
              child: Column(
                children: [
                  Divider(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  asyncPets.when(
                    data: (pets) {
                      final userPets = pets
                          .where((pet) => pet.userId == widget.userId)
                          .toList();
                      if (userPets.isEmpty) {
                        return const Text('No pets found.');
                      }
                      return _buildPetAvatarList(context, userPets);
                    },
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (error, stack) =>
                        Center(child: Text('Error: $error')),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 26.0),
              child: asyncWalks.when(
                data: (walks) {
                  final petWalks = walks
                      .where((walk) => walk.petId == selectedPet.id)
                      .toList();
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SectionTitle(title: "Summary"),
                      _buildSummarySection(context, petWalks),
                      const SectionTitle(title: "Average"),
                      _buildAverageSection(context, petWalks),
                    ],
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(child: Text('Error: $error')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPetAvatarList(BuildContext context, List<Pet> pets) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: SizedBox(
        height: 60,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: pets.length,
          itemBuilder: (context, index) {
            final pet = pets[index];
            return GestureDetector(
              onTap: () {
                setState(() {
                  selectedPet = pet;
                });
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 5.0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color:
                        selectedPet == pet ? Colors.amber : Colors.transparent,
                    width: 3,
                  ),
                ),
                child: CircleAvatar(
                  radius: 25,
                  backgroundImage: AssetImage(pet.avatarImage),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSummarySection(
      BuildContext context, List<EventWalkModel?> walks) {
    double totalSteps = walks.fold(0, (sum, walk) => sum + walk!.steps);
    double totalActiveMinutes =
        walks.fold(0, (sum, walk) => sum + walk!.walkTime);
    double totalDistance = walks.fold(0, (sum, walk) => sum + walk!.steps);
    double totalCaloriesBurned = totalSteps * 0.04;

    return Container(
      padding: const EdgeInsets.all(15.0),
      margin: const EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(
                    top: 8.0, bottom: 8, left: 10, right: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(selectedPet.name,
                        style: TextStyle(
                            color: Theme.of(context).primaryColorDark,
                            fontWeight: FontWeight.bold,
                            fontSize: 16)),
                    Text(calculateAge(selectedPet.age),
                        style: TextStyle(
                          color: Theme.of(context).primaryColorDark,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        )),
                  ],
                ),
              ),
              Divider(
                  color: Theme.of(context).colorScheme.secondary, height: 20),
              Row(
                children: [
                  Text("Steps",
                      style: TextStyle(
                        color: Theme.of(context).primaryColorDark,
                      )),
                  const Spacer(),
                  Text(totalSteps.toStringAsFixed(0),
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColorDark,
                          fontSize: 18)),
                ],
              ),
            ],
          ),
          Divider(color: Theme.of(context).colorScheme.secondary, height: 20),
          ActivityDataRow(
              context, "Time", "${totalActiveMinutes.toStringAsFixed(0)} min"),
          Divider(color: Theme.of(context).colorScheme.secondary, height: 20),
          ActivityDataRow(
              context, "Distance", "${totalDistance.toStringAsFixed(0)} km"),
          Divider(color: Theme.of(context).colorScheme.secondary, height: 20),
          ActivityDataRow(context, "Calories Burned",
              "${totalCaloriesBurned.toStringAsFixed(0)} kcal"),
        ],
      ),
    );
  }

  Widget _buildAverageSection(
      BuildContext context, List<EventWalkModel?> walks) {
    double totalSteps = walks.fold(0, (sum, walk) => sum + walk!.steps);
    double totalActiveMinutes =
        walks.fold(0, (sum, walk) => sum + walk!.walkTime);
    double totalDistance = walks.fold(0, (sum, walk) => sum + walk!.steps);
    double totalCaloriesBurned = totalSteps * 0.04;
    int totalDays =
        walks.map((walk) => walk!.dateTime.toLocal().day).toSet().length;

    double averageSteps = totalSteps / totalDays;
    double averageActiveMinutes = totalActiveMinutes / totalDays;
    double averageDistance = totalDistance / totalDays;
    double averageCaloriesBurned = totalCaloriesBurned / totalDays;

    return Container(
      padding: const EdgeInsets.all(15.0),
      margin: const EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ActivityDataRow(
              context, "Average Steps", averageSteps.toStringAsFixed(0)),
          Divider(color: Theme.of(context).colorScheme.secondary, height: 20),
          ActivityDataRow(context, "Average Active Minutes",
              "${averageActiveMinutes.toStringAsFixed(0)} min"),
          Divider(color: Theme.of(context).colorScheme.secondary, height: 20),
          ActivityDataRow(context, "Average Distance",
              "${averageDistance.toStringAsFixed(0)} km"),
          Divider(color: Theme.of(context).colorScheme.secondary, height: 20),
          ActivityDataRow(context, "Average Calories Burned",
              "${averageCaloriesBurned.toStringAsFixed(0)} kcal"),
        ],
      ),
    );
  }
}
