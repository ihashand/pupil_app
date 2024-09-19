import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pet_diary/src/components/health_activity_widgets/arrow_button.dart';
import 'package:table_calendar/table_calendar.dart';

class WeekView extends StatelessWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateChanged;
  final ValueChanged<DateTime> onDaySelected;
  final DateTime? lastSelectedDay;

  const WeekView({
    required this.selectedDate,
    required this.onDateChanged,
    required this.onDaySelected,
    required this.lastSelectedDay,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
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
                      ArrowButton(
                        icon: Icons.arrow_back_ios,
                        onPressed: () {
                          onDateChanged(
                              selectedDate.subtract(const Duration(days: 7)));
                        },
                      ),
                      Text(
                        '${DateFormat('d MMM', 'en_US').format(firstDayOfWeek)} - ${DateFormat('d MMM', 'en_US').format(lastDayOfWeek)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColorDark,
                        ),
                      ),
                      ArrowButton(
                        icon: Icons.arrow_forward_ios,
                        onPressed: () {
                          onDateChanged(
                              selectedDate.add(const Duration(days: 7)));
                        },
                      ),
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
                    onDaySelected(selectedDay);
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
                if (lastSelectedDay != null)
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
}
