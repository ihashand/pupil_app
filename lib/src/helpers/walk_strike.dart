import 'package:pet_diary/src/models/events_models/event_walk_model.dart';

class WalkStrikeCalculator {
  final int strike;
  final bool extendedToday;

  WalkStrikeCalculator._(this.strike, this.extendedToday);

  // Factory constructor to perform the calculation and return an instance of WalkStrikeCalculator
  factory WalkStrikeCalculator.calculate(List<EventWalkModel> walks) {
    if (walks.isEmpty) {
      return WalkStrikeCalculator._(0, false);
    }

    walks.sort((a, b) =>
        b.dateTime.compareTo(a.dateTime)); // Sort walks by date (latest first)
    DateTime today = DateTime.now();
    int strike = 0;
    bool extendedToday = false;

    for (int i = 0; i < walks.length; i++) {
      DateTime walkDate = walks[i].dateTime;

      if (i == 0) {
        // First walk: Check if it was today or yesterday
        if (walkDate.isAfter(today.subtract(const Duration(days: 2)))) {
          strike++;
          if (walkDate.isAfter(today.subtract(const Duration(days: 1)))) {
            extendedToday = true; // Strike was extended today
          }
        } else {
          break;
        }
      } else {
        // Subsequent walks: Check if the walk happened the day after the previous one
        DateTime previousWalkDate = walks[i - 1].dateTime;
        if (walkDate.isAtSameMomentAs(
            previousWalkDate.subtract(const Duration(days: 1)))) {
          strike++;
        } else {
          break; // Break if there is no consecutive day
        }
      }
    }

    return WalkStrikeCalculator._(strike, extendedToday);
  }
}
