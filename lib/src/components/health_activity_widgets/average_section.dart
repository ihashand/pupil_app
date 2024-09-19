import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/models/events_models/event_walk_model.dart';
import 'package:pet_diary/src/providers/events_providers/event_walk_provider.dart';
import 'package:pet_diary/src/components/health_activity_widgets/activity_data_row.dart';

class AverageSection extends StatelessWidget {
  final String selectedView;
  final DateTime selectedDate;
  final String petId;

  const AverageSection({
    required this.selectedView,
    required this.selectedDate,
    required this.petId,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, _) {
      final asyncWalks = ref.watch(eventWalksProvider);

      return asyncWalks.when(
        loading: () => const CircularProgressIndicator(),
        error: (err, stack) => Text('Error fetching walks: $err'),
        data: (walks) {
          List<EventWalkModel?> petWalks =
              walks.where((walk) => walk!.petId == petId).toList();

          List<EventWalkModel?> filteredWalks;
          int totalDays;

          if (selectedView == 'W') {
            DateTime firstDayOfWeek =
                selectedDate.subtract(Duration(days: selectedDate.weekday - 1));
            DateTime lastDayOfWeek =
                firstDayOfWeek.add(const Duration(days: 6));
            filteredWalks = petWalks.where((walk) {
              return walk!.dateTime.isAfter(
                      firstDayOfWeek.subtract(const Duration(days: 1))) &&
                  walk.dateTime
                      .isBefore(lastDayOfWeek.add(const Duration(days: 1)));
            }).toList();
            totalDays = 7;
          } else {
            filteredWalks = petWalks.where((walk) {
              return walk!.dateTime.year == selectedDate.year &&
                  walk.dateTime.month == selectedDate.month;
            }).toList();
            totalDays =
                DateTime(selectedDate.year, selectedDate.month + 1, 0).day;
          }

          double totalSteps =
              filteredWalks.fold(0, (sum, walk) => sum + walk!.steps);
          double totalActiveMinutes =
              filteredWalks.fold(0, (sum, walk) => sum + walk!.walkTime);
          double totalDistance =
              filteredWalks.fold(0, (sum, walk) => sum + walk!.steps);
          double totalCaloriesBurned = totalSteps * 0.04;

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
                const Divider(color: Colors.grey, height: 20),
                ActivityDataRow(context, "Average Active Minutes",
                    "${averageActiveMinutes.toStringAsFixed(0)} min"),
                const Divider(color: Colors.grey, height: 20),
                ActivityDataRow(context, "Average Distance",
                    "${averageDistance.toStringAsFixed(0)} km"),
                const Divider(color: Colors.grey, height: 20),
                ActivityDataRow(context, "Average Calories Burned",
                    "${averageCaloriesBurned.toStringAsFixed(0)} kcal"),
              ],
            ),
          );
        },
      );
    });
  }
}
