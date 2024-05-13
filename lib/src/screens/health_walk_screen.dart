import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/components/bar_graph/bar_graph.dart';
import 'package:pet_diary/src/models/walk_model.dart';
import 'package:pet_diary/src/providers/walk_provider.dart';

class HealthWalkScreen extends ConsumerStatefulWidget {
  const HealthWalkScreen(this.petId, {super.key});
  final String petId;

  @override
  createState() => _HealthWalkScreenState();
}

class _HealthWalkScreenState extends ConsumerState<HealthWalkScreen> {
  DateTime selectedDateTime = DateTime.now();
  String selectedTimePeriod = 'M';

  List<double> graphBarData = [10, 20, 30, 40, 50];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Walk'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        toolbarHeight: 50,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: TextButton(
              onPressed: () {},
              child: Text('Add new',
                  style: TextStyle(color: Theme.of(context).primaryColorDark)),
            ),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Expanded(
              child: StreamBuilder<List<Walk?>>(
                stream: ref.read(walkServiceProvider).getWalksStream(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Text('Error fetching walks: ${snapshot.error}');
                  }

                  if (snapshot.hasData) {
                    List<Walk?> walks = snapshot.data!
                        .where((walk) => walk!.petId == widget.petId)
                        .toList();

                    // Aktualizacja danych spacerek w zależności od wybranego okresu czasu
                    switch (selectedTimePeriod) {
                      case 'D':
                        graphBarData = calculateDailyWalks(walks);
                        break;
                      case 'W':
                        graphBarData = calculateWeeklyWalks(walks);
                        break;
                      case 'M':
                        graphBarData = calculateMonthlyWalks(walks);
                        break;
                      case 'Y':
                        graphBarData = calculateYearlyWalks(walks);
                        break;
                    }

                    return Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.only(
                              right: 230, bottom: 12, top: 10),
                          child: Text(
                            'Average : ${calculateAverage(graphBarData).toStringAsFixed(2)}',
                            style: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: Container(
                            height: 50,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: ['D', 'W', 'M', 'Y']
                                  .map((label) =>
                                      _buildTimePeriodButton(label, context))
                                  .toList(),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 10.0, left: 10, right: 10),
                          child: SizedBox(
                              height: 300,
                              child: MyBarGraph(
                                barGraphData: graphBarData,
                                selectedTimePeriod: selectedTimePeriod,
                              )),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 250.0, left: 20, right: 20),
                          child: SizedBox(
                            width: 350,
                            child: ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    Theme.of(context).colorScheme.primary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Text(
                                'Pokaż wszystkie dane',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).primaryColorDark),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  } else {
                    return const CircularProgressIndicator();
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  double calculateAverage(List<double> data) {
    if (data.isEmpty) {
      return 0.0;
    }

    double sum = 0.0;
    int nonZeroCount = 0;

    for (double number in data) {
      if (number != 0) {
        sum += number;
        nonZeroCount++;
      }
    }

    if (nonZeroCount == 0) {
      return 0.0;
    }

    return sum / nonZeroCount;
  }

  Widget _buildTimePeriodButton(String label, BuildContext context) {
    return TextButton(
      onPressed: () {
        setState(() {
          selectedTimePeriod = label;
        });
      },
      child: Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: selectedTimePeriod == label
              ? Theme.of(context).primaryColorDark
              : Theme.of(context).primaryColorDark.withOpacity(0.5),
        ),
      ),
    );
  }

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

  List<double> calculateWeeklyWalks(List<Walk?> walks) {
    // Pobierz dzisiejszą datę
    DateTime today = DateTime.now();

    // Znajdź pierwszy dzień tygodnia (poniedziałek)
    DateTime monday = today.subtract(Duration(days: today.weekday - 1));

    // Znajdź ostatni dzień tygodnia (niedziela)
    DateTime sunday = monday.add(const Duration(days: 6));

    // Filtruj spacery dodane w bieżącym tygodniu
    List<Walk?> thisWeekWalks = walks.where((walk) {
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
        double distance = walk.distance;
        daysData[day] += distance;
      }
    }

    // Zwróć dane przebytej odległości w ciągu tygodnia
    return daysData;
  }

  List<double> calculateMonthlyWalks(List<Walk?> walks) {
    // Pobierz dzisiejszą datę
    DateTime today = DateTime.now();

    // Znajdź pierwszy dzień bieżącego miesiąca
    DateTime firstDayOfMonth = DateTime(today.year, today.month, 1);

    // Znajdź ostatni dzień bieżącego miesiąca
    DateTime lastDayOfMonth = DateTime(today.year, today.month + 1, 0);

    // Filtruj spacery dodane w bieżącym miesiącu
    List<Walk?> thisMonthWalks = walks.where((walk) {
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

  List<double> calculateYearlyWalks(List<Walk?> walks) {
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
}
