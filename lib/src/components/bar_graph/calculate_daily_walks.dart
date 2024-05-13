import 'package:pet_diary/src/models/walk_model.dart';

List<double> calculateDailyWalks(List<Walk?> walks) {
  // Pobierz dzisiejszą datę
  DateTime today = DateTime.now();

  // Filtruj spacery dodane dzisiaj
  List<Walk?> todayWalks = walks.where((walk) {
    if (walk != null) {
      DateTime walkDate = walk.dateTime;
      return walkDate.year == today.year &&
          walkDate.month == today.month &&
          walkDate.day == today.day;
    }
    return false;
  }).toList();

  // Posortuj spacery po godzinie
  todayWalks.sort((a, b) => a!.dateTime.compareTo(b!.dateTime));

  // Zainicjuj listę wynikową dla godzin dnia
  List<double> hoursData = List.generate(24, (index) => 0.0);

  // Iteruj po spacerkach i dodawaj przebyte kilometry do odpowiednich godzin
  for (var walk in todayWalks) {
    if (walk != null) {
      int hour = walk.dateTime.hour;
      double distance = walk.distance;
      hoursData[hour] += distance;
    }
  }

  // Zwróć dane przebytej odległości w ciągu dnia
  return hoursData;
}
