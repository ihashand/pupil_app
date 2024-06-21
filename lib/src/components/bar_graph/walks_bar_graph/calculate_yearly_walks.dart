import 'package:pet_diary/src/models/event_walk_model.dart';

List<double> calculateYearlyWalks(List<EventWalkModel?> walks) {
  // Pobierz dzisiejszą datę
  DateTime today = DateTime.now();

  // Inicjalizuj listę wynikową dla miesięcy w roku
  List<double> monthsData = List.generate(24, (index) => 0.0);

  // Iteruj po spacerkach i dodawaj przebyte kilometry do odpowiednich miesięcy
  for (var walk in walks) {
    if (walk != null) {
      DateTime walkDate = walk.dateTime; // Użyj dateTime zamiast date
      if (walkDate.year == today.year) {
        int month = walkDate.month -
            1; // Pobierz indeks dla miesiąca (0 - styczeń, ..., 11 - grudzień)
        double distance = walk.distance;
        monthsData[month] += distance;
      }
    }
  }

  // Zwróć dane przebytej odległości w ciągu roku
  return monthsData;
}
