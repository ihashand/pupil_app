import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
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
        vsync: this, duration: const Duration(milliseconds: 300));
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
                duration: const Duration(milliseconds: 350),
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
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (selectedView == 'D')
                SizeTransition(
                  sizeFactor: CurvedAnimation(
                      parent: _animationController, curve: Curves.easeInOut),
                  child: _buildDayView(context),
                )
              else if (selectedView == 'W')
                SizeTransition(
                  sizeFactor: CurvedAnimation(
                      parent: _animationController, curve: Curves.easeInOut),
                  child: _buildWeekView(context),
                )
              else
                SizeTransition(
                  sizeFactor: CurvedAnimation(
                      parent: _animationController, curve: Curves.easeInOut),
                  child: _buildMonthView(context),
                ),
              _buildSectionTitle(context, "Summary"),
              _buildSummarySection(context),
              _buildSectionTitle(context, "Average"),
              _buildAverageSection(context),
              _buildSectionTitle(context, "Generate Report"),
              _buildGenerateReportSection(context),
            ],
          ),
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
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: const BorderRadius.all(Radius.circular(10)),
        ),
        child: Column(
          children: [
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
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: const BorderRadius.all(Radius.circular(10)),
            ),
            child: Column(
              children: [
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
                  lastDay: DateTime.utc(2030, 3, 14),
                  calendarFormat: CalendarFormat.week,
                  selectedDayPredicate: (day) {
                    return isSameDay(selectedDate, day);
                  },
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      selectedDate = selectedDay;
                      _showStepsPopup(context, selectedDay);
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
                  ),
                  daysOfWeekVisible: false,
                ),
                Container(
                  padding: const EdgeInsets.all(8.0),
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
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthView(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: const BorderRadius.all(Radius.circular(10)),
            ),
            child: Column(
              children: [
                TableCalendar(
                  locale: 'en_US', // Ustawienie formatu na angielski
                  focusedDay: selectedDate,
                  firstDay: DateTime.utc(2010, 10, 16),
                  lastDay: DateTime.utc(2030, 3, 14),
                  calendarFormat: CalendarFormat.month,
                  selectedDayPredicate: (day) {
                    return isSameDay(selectedDate, day);
                  },
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      selectedDate = selectedDay;
                      _showStepsPopup(context, selectedDay);
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
                ),
                Container(
                  padding: const EdgeInsets.all(8.0),
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
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showStepsPopup(BuildContext context, DateTime selectedDay) {
    final RenderBox calendarBox = context.findRenderObject() as RenderBox;
    final calendarPosition = calendarBox.localToGlobal(Offset.zero);

    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (BuildContext context) {
        return Stack(
          children: [
            Positioned(
              left: calendarPosition.dx,
              top: calendarPosition.dy - 40, // Adjust this value as needed
              child: Material(
                color: Colors.transparent,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      const BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "${DateFormat('d MMM').format(selectedDay)}\n3851 Steps",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.arrow_forward,
                        color: Colors.white,
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSummarySection(BuildContext context) {
    // Mock data for total values, replace with real data
    int totalSteps = 10000;
    int totalActiveMinutes = 500;
    double totalDistance = 35.0;
    double totalCaloriesBurned = 1200.0;

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
                  Text("$totalSteps",
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
          _buildActivityDataRow(context, "Time", "$totalActiveMinutes" " min"),
          const Divider(color: Colors.grey, height: 20),
          _buildActivityDataRow(
              context, "Distance", "${totalDistance.toStringAsFixed(2)} km"),
          const Divider(color: Colors.grey, height: 20),
          _buildActivityDataRow(context, "Calories Burned",
              "${totalCaloriesBurned.toStringAsFixed(2)} kcal"),
        ],
      ),
    );
  }

  Widget _buildAverageSection(BuildContext context) {
    // Mock data for average values, replace with real data
    int averageSteps = 5000;
    int averageActiveMinutes = 250;
    double averageDistance = 17.5;
    double averageCaloriesBurned = 600.0;

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
          _buildActivityDataRow(context, "Average Steps", "$averageSteps"),
          const Divider(color: Colors.grey, height: 20),
          _buildActivityDataRow(
              context, "Average Active Minutes", "$averageActiveMinutes"),
          const Divider(color: Colors.grey, height: 20),
          _buildActivityDataRow(context, "Average Distance",
              "${averageDistance.toStringAsFixed(2)} km"),
          const Divider(color: Colors.grey, height: 20),
          _buildActivityDataRow(context, "Average Calories Burned",
              "${averageCaloriesBurned.toStringAsFixed(2)} kcal"),
        ],
      ),
    );
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
