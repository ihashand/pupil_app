import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class MonthView extends StatelessWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateChanged;
  final ValueChanged<DateTime> onDaySelected;
  final DateTime? lastSelectedDay;

  const MonthView({
    required this.selectedDate,
    required this.onDateChanged,
    required this.onDaySelected,
    required this.lastSelectedDay,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
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
                    onDaySelected(selectedDay);
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
