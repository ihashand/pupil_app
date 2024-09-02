import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

class MoodScreen extends StatefulWidget {
  const MoodScreen({super.key});

  @override
  createState() => _MoodScreenState();
}

class _MoodScreenState extends State<MoodScreen> {
  String _selectedView = 'D';
  DateTime selectedDateTime = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mood Tracker'),
      ),
      body: Column(
        children: [
          ToggleSwitch(
            selectedView: _selectedView,
            onViewChanged: (String view) {
              setState(() {
                _selectedView = view;
              });
            },
          ),
          Expanded(
            child: SingleChildScrollView(
              child: ChartView(
                selectedView: _selectedView,
                selectedDateTime: selectedDateTime,
                onDateSelected: (DateTime date) {
                  setState(() {
                    selectedDateTime = date;
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ToggleSwitch extends StatelessWidget {
  final String selectedView;
  final Function(String) onViewChanged;

  const ToggleSwitch(
      {super.key, required this.selectedView, required this.onViewChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildTimePeriodButton('D', context),
        _buildTimePeriodButton('W', context),
        _buildTimePeriodButton('M', context),
      ],
    );
  }

  Widget _buildTimePeriodButton(String label, BuildContext context) {
    String fullLabel;
    switch (label) {
      case 'D':
        fullLabel = selectedView == 'D' ? 'Day' : 'D';
        break;
      case 'W':
        fullLabel = selectedView == 'W' ? 'Week' : 'W';
        break;
      case 'M':
        fullLabel = selectedView == 'M' ? 'Month' : 'M';
        break;
      default:
        fullLabel = label;
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return ScaleTransition(scale: animation, child: child);
      },
      child: TextButton(
        key: ValueKey<String>(fullLabel),
        onPressed: () {
          onViewChanged(label);
        },
        style: TextButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(
          fullLabel,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: selectedView == label
                ? Theme.of(context).primaryColorDark
                : Theme.of(context).primaryColorDark.withOpacity(0.5),
          ),
        ),
      ),
    );
  }
}

class ChartView extends StatelessWidget {
  final String selectedView;
  final DateTime selectedDateTime;
  final Function(DateTime) onDateSelected;

  const ChartView({
    super.key,
    required this.selectedView,
    required this.selectedDateTime,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    switch (selectedView) {
      case 'D':
        return _buildDayChart(context);
      case 'W':
        return _buildWeekChart(context);
      case 'M':
        return _buildMonthChart(context);
      default:
        return Container();
    }
  }

  Widget _buildDayChart(BuildContext context) {
    return Container(
      height: 400,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          SizedBox(
            height: 300, // Define a fixed height for the BarChart
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                barTouchData: BarTouchData(
                  touchCallback: (FlTouchEvent event, barTouchResponse) {
                    if (!event.isInterestedForInteractions ||
                        barTouchResponse == null ||
                        barTouchResponse.spot == null) {
                      return;
                    }
                    // Display steps for the touched bar
                    // Customize this part to show actual data
                  },
                ),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        switch (value.toInt()) {
                          case 0:
                            return const Text('00');
                          case 1:
                            return const Text('04');
                          case 2:
                            return const Text('08');
                          case 3:
                            return const Text('12');
                          case 4:
                            return const Text('16');
                          case 5:
                            return const Text('20');
                          case 6:
                            return const Text('00');
                          default:
                            return const Text('');
                        }
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                gridData: const FlGridData(show: false),
                barGroups: [
                  BarChartGroupData(
                    x: 0,
                    barRods: [
                      BarChartRodData(toY: 8, color: Colors.lightBlueAccent)
                    ],
                  ),
                  BarChartGroupData(
                    x: 1,
                    barRods: [
                      BarChartRodData(toY: 10, color: Colors.lightBlueAccent)
                    ],
                  ),
                  BarChartGroupData(
                    x: 2,
                    barRods: [
                      BarChartRodData(toY: 14, color: Colors.lightBlueAccent)
                    ],
                  ),
                  BarChartGroupData(
                    x: 3,
                    barRods: [
                      BarChartRodData(toY: 15, color: Colors.lightBlueAccent)
                    ],
                  ),
                  BarChartGroupData(
                    x: 4,
                    barRods: [
                      BarChartRodData(toY: 13, color: Colors.lightBlueAccent)
                    ],
                  ),
                  BarChartGroupData(
                    x: 5,
                    barRods: [
                      BarChartRodData(toY: 10, color: Colors.lightBlueAccent)
                    ],
                  ),
                  BarChartGroupData(
                    x: 6,
                    barRods: [
                      BarChartRodData(toY: 5, color: Colors.lightBlueAccent)
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildSelectedDataInfo(
              context, 'Steps: 1000'), // Placeholder for selected data info
        ],
      ),
    );
  }

  Widget _buildWeekChart(BuildContext context) {
    return Container(
      height: 400,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          SizedBox(
            height: 300, // Define a fixed height for the BarChart
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                barTouchData: BarTouchData(
                  touchCallback: (FlTouchEvent event, barTouchResponse) {
                    if (!event.isInterestedForInteractions ||
                        barTouchResponse == null ||
                        barTouchResponse.spot == null) {
                      return;
                    }
                    // Display steps for the touched bar
                    // Customize this part to show actual data
                  },
                ),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        switch (value.toInt()) {
                          case 0:
                            return const Text('Mon');
                          case 1:
                            return const Text('Tue');
                          case 2:
                            return const Text('Wed');
                          case 3:
                            return const Text('Thu');
                          case 4:
                            return const Text('Fri');
                          case 5:
                            return const Text('Sat');
                          case 6:
                            return const Text('Sun');
                          default:
                            return const Text('');
                        }
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                gridData: const FlGridData(show: false),
                barGroups: [
                  BarChartGroupData(
                    x: 0,
                    barRods: [
                      BarChartRodData(toY: 8, color: Colors.lightBlueAccent)
                    ],
                  ),
                  BarChartGroupData(
                    x: 1,
                    barRods: [
                      BarChartRodData(toY: 10, color: Colors.lightBlueAccent)
                    ],
                  ),
                  BarChartGroupData(
                    x: 2,
                    barRods: [
                      BarChartRodData(toY: 14, color: Colors.lightBlueAccent)
                    ],
                  ),
                  BarChartGroupData(
                    x: 3,
                    barRods: [
                      BarChartRodData(toY: 15, color: Colors.lightBlueAccent)
                    ],
                  ),
                  BarChartGroupData(
                    x: 4,
                    barRods: [
                      BarChartRodData(toY: 13, color: Colors.lightBlueAccent)
                    ],
                  ),
                  BarChartGroupData(
                    x: 5,
                    barRods: [
                      BarChartRodData(toY: 10, color: Colors.lightBlueAccent)
                    ],
                  ),
                  BarChartGroupData(
                    x: 6,
                    barRods: [
                      BarChartRodData(toY: 5, color: Colors.lightBlueAccent)
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildSelectedDataInfo(
              context, 'Steps: 5000'), // Placeholder for selected data info
        ],
      ),
    );
  }

  Widget _buildMonthChart(BuildContext context) {
    return _buildCalendarView(context, selectedDateTime);
  }

  Widget _buildSelectedDataInfo(BuildContext context, String info) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Text(
        info,
        style: TextStyle(
          color: Theme.of(context).primaryColorDark,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildCalendarView(BuildContext context, DateTime eventDateTime) {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  TableCalendar(
                    firstDay: DateTime.utc(2010, 10, 16),
                    lastDay: DateTime.utc(2030, 3, 14),
                    focusedDay: eventDateTime,
                    calendarFormat: CalendarFormat.month,
                    startingDayOfWeek: StartingDayOfWeek.monday,
                    selectedDayPredicate: (day) {
                      return isSameDay(eventDateTime, day);
                    },
                    onDaySelected: (date, focusedDate) {
                      onDateSelected(date);
                      // Display steps for the selected day
                      // Customize this part to show actual data
                    },
                    onPageChanged: (focusedDate) {
                      onDateSelected(focusedDate);
                    },
                    locale: 'en_En',
                    calendarStyle: const CalendarStyle(
                      selectedDecoration: BoxDecoration(
                        color: Color(0xffdfd785),
                        shape: BoxShape.circle,
                      ),
                      todayDecoration: BoxDecoration(
                        color: Color(0xff68a2b6),
                        shape: BoxShape.circle,
                      ),
                    ),
                    headerStyle: HeaderStyle(
                      formatButtonVisible: false,
                      titleCentered: true,
                      titleTextStyle: TextStyle(
                          color: Theme.of(context).primaryColorDark,
                          fontWeight: FontWeight.bold),
                      leftChevronIcon: Icon(Icons.chevron_left,
                          color: Theme.of(context).primaryColorDark),
                      rightChevronIcon: Icon(Icons.chevron_right,
                          color: Theme.of(context).primaryColorDark),
                    ),
                    daysOfWeekVisible: false, // Ukryj domyślne dni tygodnia
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: List.generate(7, (index) {
                        final dayOfWeek = DateFormat.E('en_En').format(
                            DateTime.utc(2020, 6, 1)
                                .add(Duration(days: index)));
                        return Text(
                          dayOfWeek,
                          style: const TextStyle(
                            color: Colors.green,
                            fontSize: 16,
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildSelectedDataInfo(
              context, 'Steps: 3000'), // Placeholder for selected data info
        ],
      ),
    );
  }
}
