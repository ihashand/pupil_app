import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/models/event_walk_model.dart';
import 'package:pet_diary/src/providers/event_walk_provider.dart';
import 'package:pet_diary/src/widgets/health_activity_widgets/activity_data_row.dart';
import 'package:table_calendar/table_calendar.dart';

class SummarySection extends StatelessWidget {
  final String selectedView;
  final DateTime selectedDate;
  final String petId;

  const SummarySection({
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
          if (selectedView == 'D') {
            filteredWalks = petWalks
                .where((walk) => isSameDay(walk!.dateTime, selectedDate))
                .toList();
          } else if (selectedView == 'W') {
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
          } else {
            filteredWalks = petWalks.where((walk) {
              return walk!.dateTime.year == selectedDate.year &&
                  walk.dateTime.month == selectedDate.month;
            }).toList();
          }

          double totalSteps =
              filteredWalks.fold(0, (sum, walk) => sum + walk!.steps);
          double totalActiveMinutes =
              filteredWalks.fold(0, (sum, walk) => sum + walk!.walkTime);
          double totalDistance =
              filteredWalks.fold(0, (sum, walk) => sum + walk!.steps);
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
                    Text("Steps",
                        style: TextStyle(
                            color: Theme.of(context).primaryColorDark,
                            fontWeight: FontWeight.bold,
                            fontSize: 12)),
                    Row(
                      children: [
                        Text(totalSteps.toStringAsFixed(0),
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).primaryColorDark,
                                fontSize: 18)),
                        const Spacer(),
                        const Icon(
                          Icons.directions_walk,
                          color: Color(0xff68a2b6),
                          size: 40,
                        ),
                      ],
                    ),
                  ],
                ),
                const Divider(color: Colors.grey, height: 20),
                ActivityDataRow(context, "Time",
                    "${totalActiveMinutes.toStringAsFixed(0)} min"),
                const Divider(color: Colors.grey, height: 20),
                ActivityDataRow(context, "Distance",
                    "${totalDistance.toStringAsFixed(0)} km"),
                const Divider(color: Colors.grey, height: 20),
                ActivityDataRow(context, "Calories Burned",
                    "${totalCaloriesBurned.toStringAsFixed(0)} kcal"),
              ],
            ),
          );
        },
      );
    });
  }
}
