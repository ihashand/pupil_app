import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pet_diary/src/models/event_walk_model.dart';
import 'package:pet_diary/src/providers/event_walk_provider.dart';
import 'package:table_calendar/table_calendar.dart';

class HealthActivityScreen extends ConsumerStatefulWidget {
  final String petId;
  const HealthActivityScreen(this.petId, {super.key});

  @override
  createState() => _HealthActivityScreenState();
}

class _HealthActivityScreenState extends ConsumerState<HealthActivityScreen>
    with SingleTickerProviderStateMixin {
  DateTime selectedDate = DateTime.now();
  String selectedView = 'M';
  final ScrollController _scrollController = ScrollController();
  bool _isAppBarVisible = true;
  double arrowButtonSize = 14.0;
  late AnimationController _animationController;
  late Animation<double> _popupAnimation;
  DateTime? _lastSelectedDay;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      setState(() {
        _isAppBarVisible = _scrollController.position.userScrollDirection ==
            ScrollDirection.forward;
      });
    });
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _popupAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              expandedHeight: 100.0,
              floating: true,
              pinned: true,
              snap: true,
              iconTheme: IconThemeData(
                color: Theme.of(context).primaryColorDark,
              ),
              title: AnimatedOpacity(
                opacity: _isAppBarVisible ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 600),
                child: Text(
                  'A C T I V I T Y',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: Theme.of(context).primaryColorDark,
                  ),
                ),
              ),
              backgroundColor: Theme.of(context).colorScheme.primary,
              toolbarHeight: 50,
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back_ios,
                  size: 20,
                  color: Theme.of(context).primaryColorDark,
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              actions: [
                IconButton(
                  icon: Icon(
                    Icons.more_horiz,
                    color: Theme.of(context).primaryColorDark,
                    size: 24,
                  ),
                  onPressed: () {
                    // Dodaj logikę dla menu
                  },
                ),
              ],
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(64.0),
                child: _buildSwitch(context),
              ),
            ),
          ];
        },
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (selectedView == 'D')
                      _buildDayView(context)
                    else if (selectedView == 'W')
                      Column(
                        children: [
                          _buildWeekView(context),
                          if (_lastSelectedDay != null)
                            SizeTransition(
                              sizeFactor: _popupAnimation,
                              child: _buildPopup(context),
                            ),
                        ],
                      )
                    else
                      Column(
                        children: [
                          _buildMonthView(context),
                          if (_lastSelectedDay != null)
                            SizeTransition(
                              sizeFactor: _popupAnimation,
                              child: _buildPopup(context),
                            ),
                        ],
                      ),
                    _buildSectionTitle(context, "Summary"),
                    _buildSummarySection(context),
                    if (selectedView != 'D') ...[
                      _buildSectionTitle(context, "Average"),
                      _buildAverageSection(context),
                    ],
                    _buildSectionTitle(context, "Generate Report"),
                    _buildGenerateReportSection(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitch(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: ['D', 'W', 'M'].map((label) {
          String displayLabel = label;
          Color bgColor = Colors.transparent;
          if (selectedView == label) {
            if (label == 'D') displayLabel = 'Day';
            if (label == 'W') displayLabel = 'Week';
            if (label == 'M') displayLabel = 'Month';
            bgColor = const Color(0xff68a2b6)
                .withOpacity(0.2); // Niebieskie tło dla wybranego przycisku
          }
          return TextButton(
            onPressed: () {
              setState(() {
                selectedView = label;
                _animationController.forward(from: 0);
                if (label == 'M' || label == 'W') {
                  selectedDate = DateTime.now();
                }
                _lastSelectedDay = null; // Clear the popup when switching views
              });
            },
            style: TextButton.styleFrom(
              backgroundColor: bgColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              displayLabel,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: selectedView == label
                    ? Theme.of(context)
                        .primaryColorDark // Biały tekst dla wybranego przycisku
                    : Theme.of(context).primaryColorDark.withOpacity(0.5),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDayView(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(0.0),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: const BorderRadius.all(Radius.circular(10)),
        ),
        child: Column(
          children: [
            Divider(color: Theme.of(context).colorScheme.secondary, height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildArrowButton(context, Icons.arrow_back_ios, () {
                    setState(() {
                      selectedDate =
                          selectedDate.subtract(const Duration(days: 1));
                    });
                  }),
                  Text(
                    DateFormat('EEEE, d MMMM', 'en_US').format(selectedDate),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColorDark,
                    ),
                  ),
                  _buildArrowButton(context, Icons.arrow_forward_ios, () {
                    setState(() {
                      selectedDate = selectedDate.add(const Duration(days: 1));
                    });
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeekView(BuildContext context) {
    DateTime firstDayOfWeek =
        selectedDate.subtract(Duration(days: selectedDate.weekday - 1));
    DateTime lastDayOfWeek = firstDayOfWeek.add(const Duration(days: 6));

    return Padding(
      padding: const EdgeInsets.all(0.0),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
            ),
            child: Column(
              children: [
                Divider(
                    color: Theme.of(context).colorScheme.secondary, height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildArrowButton(context, Icons.arrow_back_ios, () {
                        setState(() {
                          selectedDate =
                              selectedDate.subtract(const Duration(days: 7));
                        });
                      }),
                      Text(
                        '${DateFormat('d MMM', 'en_US').format(firstDayOfWeek)} - ${DateFormat('d MMM', 'en_US').format(lastDayOfWeek)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColorDark,
                        ),
                      ),
                      _buildArrowButton(context, Icons.arrow_forward_ios, () {
                        setState(() {
                          selectedDate =
                              selectedDate.add(const Duration(days: 7));
                        });
                      }),
                    ],
                  ),
                ),
                TableCalendar(
                  focusedDay: selectedDate,
                  firstDay: DateTime.utc(2010, 10, 16),
                  lastDay: DateTime.utc(2050, 3,
                      14), //todo jakies sprawdzenie ktory mamy rok, zeby to bylo bezobslugowe
                  calendarFormat: CalendarFormat.week,
                  selectedDayPredicate: (day) {
                    return isSameDay(selectedDate, day);
                  },
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      if (_lastSelectedDay == selectedDay) {
                        _lastSelectedDay = null;
                      } else {
                        selectedDate = selectedDay;
                        _lastSelectedDay = selectedDay;
                        _animationController.forward(from: 0);
                      }
                    });
                  },
                  headerVisible: false,
                  calendarStyle: const CalendarStyle(
                      todayDecoration: BoxDecoration(
                        color: Color(0xff68a2b6),
                        shape: BoxShape.circle,
                      ),
                      selectedDecoration: BoxDecoration(
                        color: Color(0xffdfd785),
                        shape: BoxShape.circle,
                      ),
                      tablePadding: EdgeInsets.only(left: 5, right: 5)),
                  daysOfWeekVisible: false,
                  startingDayOfWeek: StartingDayOfWeek.monday,
                ),
                Container(
                  padding: const EdgeInsets.only(top: 5.0, bottom: 10.0),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text("Mon", style: TextStyle(fontSize: 10)),
                      Text("Tue", style: TextStyle(fontSize: 10)),
                      Text("Wed", style: TextStyle(fontSize: 10)),
                      Text("Thu", style: TextStyle(fontSize: 10)),
                      Text("Fri", style: TextStyle(fontSize: 10)),
                      Text("Sat", style: TextStyle(fontSize: 10)),
                      Text("Sun", style: TextStyle(fontSize: 10)),
                    ],
                  ),
                ),
                if (_lastSelectedDay != null)
                  Divider(
                      color: Theme.of(context).colorScheme.secondary,
                      height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthView(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(0.0),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
            ),
            child: Column(
              children: [
                Divider(
                    color: Theme.of(context).colorScheme.secondary, height: 20),
                TableCalendar(
                  locale: 'en_US',
                  focusedDay: selectedDate,
                  firstDay: DateTime.utc(2010, 10, 16),
                  lastDay: DateTime.utc(2030, 3, 14),
                  calendarFormat: CalendarFormat.month,
                  selectedDayPredicate: (day) {
                    return isSameDay(selectedDate, day);
                  },
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      if (_lastSelectedDay == selectedDay) {
                        _lastSelectedDay = null;
                      } else {
                        selectedDate = selectedDay;
                        _lastSelectedDay = selectedDay;
                        _animationController.forward(from: 0);
                      }
                    });
                  },
                  headerStyle: HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                    titleTextStyle: TextStyle(
                      color: Theme.of(context).primaryColorDark,
                      fontWeight: FontWeight.bold,
                    ),
                    leftChevronIcon: Icon(
                      Icons.chevron_left,
                      color: Theme.of(context).primaryColorDark,
                      size: 24,
                    ),
                    rightChevronIcon: Icon(
                      Icons.chevron_right,
                      color: Theme.of(context).primaryColorDark,
                      size: 24,
                    ),
                  ),
                  calendarStyle: const CalendarStyle(
                    todayDecoration: BoxDecoration(
                      color: Color(0xff68a2b6),
                      shape: BoxShape.circle,
                    ),
                    selectedDecoration: BoxDecoration(
                      color: Color(0xffdfd785),
                      shape: BoxShape.circle,
                    ),
                  ),
                  daysOfWeekVisible: false,
                  startingDayOfWeek: StartingDayOfWeek.monday,
                ),
                Container(
                  padding: const EdgeInsets.only(top: 5.0, bottom: 10),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text("Mon", style: TextStyle(fontSize: 10)),
                      Text("Tue", style: TextStyle(fontSize: 10)),
                      Text("Wed", style: TextStyle(fontSize: 10)),
                      Text("Thu", style: TextStyle(fontSize: 10)),
                      Text("Fri", style: TextStyle(fontSize: 10)),
                      Text("Sat", style: TextStyle(fontSize: 10)),
                      Text("Sun", style: TextStyle(fontSize: 10)),
                    ],
                  ),
                ), //todo tutaj
                if (_lastSelectedDay != null)
                  Divider(
                      color: Theme.of(context).colorScheme.secondary,
                      height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPopup(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Consumer(builder: (context, ref, _) {
            final asyncWalks = ref.watch(eventWalksProvider);

            return asyncWalks.when(
              loading: () => const CircularProgressIndicator(),
              error: (err, stack) => Text('Error fetching walks: $err'),
              data: (walks) {
                List<EventWalkModel?> petWalks =
                    walks.where((walk) => walk!.petId == widget.petId).toList();
                double steps = 0;

                if (petWalks.isNotEmpty) {
                  var dateTime = selectedDate;
                  List<EventWalkModel?> todaySortedWalks;
                  todaySortedWalks = petWalks
                      .where((element) =>
                          element?.dateTime.day == dateTime.day &&
                          element?.dateTime.year == dateTime.year &&
                          element?.dateTime.month == dateTime.month)
                      .toList();
                  for (var walk in todaySortedWalks) {
                    steps += walk!.distance;
                  }
                  return Column(
                    children: [
                      Row(
                        children: [
                          Text(
                            '${steps.toInt()} steps',
                            style: TextStyle(
                              color: Theme.of(context).primaryColorDark,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(
                            width: 35,
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.arrow_forward,
                              color: Theme.of(context).primaryColorDark,
                              size: 20,
                            ),
                            onPressed: () {
                              setState(() {
                                selectedView = 'D';
                                selectedDate = _lastSelectedDay!;
                                _lastSelectedDay = null;
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  );
                } else {
                  return Column(
                    children: [
                      Text(
                        '',
                        style: TextStyle(
                          color: Theme.of(context).primaryColorDark,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.arrow_forward,
                          color: Theme.of(context).primaryColorDark,
                          size: 20,
                        ),
                        onPressed: () {
                          setState(() {
                            selectedView = 'D';
                            selectedDate = _lastSelectedDay!;
                            _lastSelectedDay = null;
                          });
                        },
                      ),
                    ],
                  );
                }
              },
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSummarySection(BuildContext context) {
    return Consumer(builder: (context, ref, _) {
      final asyncWalks = ref.watch(eventWalksProvider);

      return asyncWalks.when(
        loading: () => const CircularProgressIndicator(),
        error: (err, stack) => Text('Error fetching walks: $err'),
        data: (walks) {
          List<EventWalkModel?> petWalks =
              walks.where((walk) => walk!.petId == widget.petId).toList();

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
              filteredWalks.fold(0, (sum, walk) => sum + walk!.distance);
          double totalActiveMinutes =
              filteredWalks.fold(0, (sum, walk) => sum + walk!.walkTime);
          double totalDistance =
              filteredWalks.fold(0, (sum, walk) => sum + walk!.distance);
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
                        Text(totalSteps.toStringAsFixed(2),
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
                    ), // Dodana ikona
                  ],
                ),
                const Divider(color: Colors.grey, height: 20),
                _buildActivityDataRow(context, "Time",
                    "${totalActiveMinutes.toStringAsFixed(2)} min"),
                const Divider(color: Colors.grey, height: 20),
                _buildActivityDataRow(context, "Distance",
                    "${totalDistance.toStringAsFixed(2)} km"),
                const Divider(color: Colors.grey, height: 20),
                _buildActivityDataRow(context, "Calories Burned",
                    "${totalCaloriesBurned.toStringAsFixed(2)} kcal"),
              ],
            ),
          );
        },
      );
    });
  }

  Widget _buildAverageSection(BuildContext context) {
    return Consumer(builder: (context, ref, _) {
      final asyncWalks = ref.watch(eventWalksProvider);

      return asyncWalks.when(
        loading: () => const CircularProgressIndicator(),
        error: (err, stack) => Text('Error fetching walks: $err'),
        data: (walks) {
          List<EventWalkModel?> petWalks =
              walks.where((walk) => walk!.petId == widget.petId).toList();

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
              filteredWalks.fold(0, (sum, walk) => sum + walk!.distance);
          double totalActiveMinutes =
              filteredWalks.fold(0, (sum, walk) => sum + walk!.walkTime);
          double totalDistance =
              filteredWalks.fold(0, (sum, walk) => sum + walk!.distance);
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
                _buildActivityDataRow(
                    context, "Average Steps", averageSteps.toStringAsFixed(2)),
                const Divider(color: Colors.grey, height: 20),
                _buildActivityDataRow(context, "Average Active Minutes",
                    "${averageActiveMinutes.toStringAsFixed(2)} min"),
                const Divider(color: Colors.grey, height: 20),
                _buildActivityDataRow(context, "Average Distance",
                    "${averageDistance.toStringAsFixed(2)} km"),
                const Divider(color: Colors.grey, height: 20),
                _buildActivityDataRow(context, "Average Calories Burned",
                    "${averageCaloriesBurned.toStringAsFixed(2)} kcal"),
              ],
            ),
          );
        },
      );
    });
  }

  Widget _buildGenerateReportSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15.0),
      margin: const EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(Icons.picture_as_pdf,
              size: 80,
              color: Theme.of(context).primaryColorDark.withOpacity(0.5)),
          const SizedBox(height: 8),
          Text(
            "Generate a detailed health report in PDF, CSV, or JSON format. Your data is secure and private.",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(context).primaryColorDark.withOpacity(0.7),
            ),
          ),
          const Divider(color: Colors.grey, height: 20),
          TextButton(
            onPressed: () {
              // Dodaj logikę generowania raportu
            },
            child: Text(
              "Generate Report",
              style: TextStyle(
                color: Theme.of(context).primaryColorDark.withOpacity(0.7),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArrowButton(
      BuildContext context, IconData icon, VoidCallback onPressed) {
    return IconButton(
      icon: Icon(
        icon,
        size: arrowButtonSize,
        color: Theme.of(context).primaryColorDark,
        weight: 20,
      ),
      onPressed: onPressed,
    );
  }

  Widget _buildActivityDataRow(
      BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Theme.of(context).primaryColorDark,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColorDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, top: 10),
      child: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18,
          color: Theme.of(context).primaryColorDark.withOpacity(0.7),
        ),
      ),
    );
  }
}
