import 'package:pet_diary/src/models/event_walk_model.dart';

List<double> calculateWeeklyWalks(List<EventWalkModel?> walks) {
  // Pobierz dzisiejszą datę
  DateTime today = DateTime.now();

  // Znajdź pierwszy dzień tygodnia (poniedziałek)
  DateTime monday = today.subtract(Duration(days: today.weekday - 1));

  // Znajdź ostatni dzień tygodnia (niedziela)
  DateTime sunday = monday.add(const Duration(days: 6));

  // Filtruj spacery dodane w bieżącym tygodniu
  List<EventWalkModel?> thisWeekWalks = walks.where((walk) {
    if (walk != null) {
      DateTime walkDate = walk.dateTime; // Użyj dateTime zamiast date
      return walkDate.isAfter(monday.subtract(const Duration(days: 1))) &&
          walkDate.isBefore(sunday.add(const Duration(days: 1)));
    }
    return false;
  }).toList();

  // Inicjalizuj listę wynikową dla dni tygodnia
  List<double> daysData = List.generate(24, (index) => 0.0);

  // Iteruj po spacerkach i dodawaj przebyte kilometry do odpowiednich dni tygodnia
  for (var walk in thisWeekWalks) {
    if (walk != null) {
      int day = walk.dateTime.weekday -
          1; // Pobierz indeks dla dnia tygodnia (0 - poniedziałek, ..., 6 - niedziela)
      double distance = walk.steps;
      daysData[day] += distance;
    }
  }

  // Zwróć dane przebytej odległości w ciągu tygodnia
  return daysData;
}
