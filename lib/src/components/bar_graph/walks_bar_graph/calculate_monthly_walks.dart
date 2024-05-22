import 'package:pet_diary/src/models/event_walk_model.dart';

List<double> calculateMonthlyWalks(List<EventWalkModel?> walks) {
  // Pobierz dzisiejszą datę
  DateTime today = DateTime.now();

  // Znajdź pierwszy dzień bieżącego miesiąca
  DateTime firstDayOfMonth = DateTime(today.year, today.month, 1);

  // Znajdź ostatni dzień bieżącego miesiąca
  DateTime lastDayOfMonth = DateTime(today.year, today.month + 1, 0);

  // Filtruj spacery dodane w bieżącym miesiącu
  List<EventWalkModel?> thisMonthWalks = walks.where((walk) {
    if (walk != null) {
      DateTime walkDate = walk.dateTime; // Użyj dateTime zamiast date
      return walkDate
              .isAfter(firstDayOfMonth.subtract(const Duration(days: 1))) &&
          walkDate.isBefore(lastDayOfMonth.add(const Duration(days: 1)));
    }
    return false;
  }).toList();

  // Inicjalizuj listę wynikową dla dni miesiąca
  List<double> daysData = List.generate(lastDayOfMonth.day, (index) => 0.0);

  // Iteruj po spacerkach i dodawaj przebyte kilometry do odpowiednich dni miesiąca
  for (var walk in thisMonthWalks) {
    if (walk != null) {
      int day = walk.dateTime.day -
          1; // Pobierz indeks dla dnia miesiąca (0 - pierwszy dzień, ..., 29/30/31 - ostatni dzień)
      double distance = walk.distance;
      daysData[day] += distance;
    }
  }

  // Zwróć dane przebytej odległości w ciągu miesiąca
  return daysData;
}
