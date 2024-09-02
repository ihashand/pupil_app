import 'package:pet_diary/src/models/events_models/event_mood_model.dart';

List<double> calculateDailyMoods(List<EventMoodModel?> moods) {
  // Pobierz dzisiejszą datę
  DateTime today = DateTime.now();

  // Filtruj spacery dodane dzisiaj
  List<EventMoodModel?> todayMoods = moods.where((moods) {
    if (moods != null) {
      DateTime moodsDate = moods.dateTime;
      return moodsDate.year == today.year &&
          moodsDate.month == today.month &&
          moodsDate.day == today.day;
    }
    return false;
  }).toList();

  // Posortuj spacery po godzinie
  todayMoods.sort((a, b) => a!.dateTime.compareTo(b!.dateTime));

  List<double> result = List.generate(24, (index) => 0.0);

  // Iteruj po spacerkach i dodawaj przebyte kilometry do odpowiednich godzin
  for (var mood in todayMoods) {
    if (mood != null) {
      int hour = mood.dateTime.hour;
      result[hour] += mood.moodRating;
    }
  }

  return result;
}
