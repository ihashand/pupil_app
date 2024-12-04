import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/screens/events_screens/event_type_selection_screen.dart';
import 'package:pet_diary/src/providers/events_providers/event_provider.dart';
import 'package:pet_diary/src/components/events/others/event_tile.dart';
import 'package:table_calendar/table_calendar.dart';

class EventsScreen extends ConsumerStatefulWidget {
  const EventsScreen(this.petId, {super.key});
  final String petId;

  @override
  createState() => _EventsScreenState();
}

class _EventsScreenState extends ConsumerState<EventsScreen>
    with SingleTickerProviderStateMixin {
  bool isCurrentSelected = true;
  bool isCalendarView = true;
  int itemsToLoad = 5;
  CalendarFormat calendarFormat = CalendarFormat.week;
  DateTime selectedDate = DateTime.now();

  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final asyncEvents = ref.watch(eventsByPetIdProvider(widget.petId));

    return asyncEvents.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
      data: (allEvents) {
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        final yesterday = today.subtract(const Duration(days: 1));
        final monthLater = today.add(const Duration(days: 30));

        // Filtrowanie wydarzeń na podstawie wybranej kategorii
        final filteredEvents = allEvents.where((event) {
          if (isCurrentSelected) {
            return event.eventDate.isAtSameMomentAs(today) ||
                event.eventDate.isAfter(today) &&
                    event.eventDate.isBefore(monthLater);
          } else {
            return event.eventDate.isBefore(today) &&
                (event.eventDate.isAtSameMomentAs(yesterday) ||
                    event.eventDate.isBefore(yesterday));
          }
        }).toList();

        final eventsOnSelectedDate = allEvents
            .where((event) => isSameDay(event.eventDate, selectedDate))
            .toList();

        final eventsToDisplay = filteredEvents.take(itemsToLoad).toList();

        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          appBar: AppBar(
            iconTheme: IconThemeData(
              color: Theme.of(context).primaryColorDark,
              size: 20,
            ),
            title: Text(
              'E V E N T S',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: Theme.of(context).primaryColorDark,
              ),
            ),
            backgroundColor: Theme.of(context).colorScheme.primary,
            toolbarHeight: 50,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(64.0),
              child: _buildSwitch(context),
            ),
          ),
          body: isCalendarView
              ? Column(
                  children: [
                    // Widok kalendarza
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(25),
                          bottomRight: Radius.circular(25),
                        ),
                      ),
                      child: Column(
                        children: [
                          Divider(
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                          TableCalendar(
                            locale: 'en_US',
                            firstDay: DateTime.utc(2010, 10, 16),
                            lastDay: DateTime.utc(2050, 3, 14),
                            focusedDay: selectedDate,
                            calendarFormat: calendarFormat,
                            onFormatChanged: (format) {
                              setState(() {
                                calendarFormat = format;
                              });
                            },
                            selectedDayPredicate: (day) =>
                                isSameDay(selectedDate, day),
                            onDaySelected: (selectedDay, _) {
                              setState(() => selectedDate = selectedDay);
                            },
                            eventLoader: (day) {
                              // Zwracamy jedną wartość na dzień z wydarzeniami
                              return allEvents.any((event) =>
                                      isSameDay(event.eventDate, day))
                                  ? [true]
                                  : [];
                            },
                            headerStyle: HeaderStyle(
                              formatButtonVisible: true,
                              titleCentered: true,
                              formatButtonTextStyle: TextStyle(
                                color: Theme.of(context).primaryColorDark,
                              ),
                              formatButtonDecoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surface,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              titleTextStyle: TextStyle(
                                color: Theme.of(context).primaryColorDark,
                                fontWeight: FontWeight.bold,
                              ),
                              leftChevronIcon: Icon(
                                Icons.chevron_left,
                                color: Theme.of(context).primaryColorDark,
                              ),
                              rightChevronIcon: Icon(
                                Icons.chevron_right,
                                color: Theme.of(context).primaryColorDark,
                              ),
                            ),
                            calendarBuilders: CalendarBuilders(
                              markerBuilder: (context, date, events) {
                                // Wyświetlamy tylko jedną kropkę dla dni z wydarzeniami
                                if (events.isNotEmpty) {
                                  return Align(
                                    alignment: Alignment.bottomCenter,
                                    child: Container(
                                      width: 8.0,
                                      height: 8.0,
                                      decoration: BoxDecoration(
                                        color: Theme.of(context)
                                            .primaryColorDark
                                            .withOpacity(0.5),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  );
                                }
                                return null;
                              },
                            ),
                            calendarStyle: CalendarStyle(
                              todayDecoration: BoxDecoration(
                                color: Theme.of(context)
                                    .colorScheme
                                    .inversePrimary,
                                shape: BoxShape.circle,
                              ),
                              selectedDecoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.secondary,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 6,
                          )
                        ],
                      ),
                    ),
                    Expanded(
                      child: eventsOnSelectedDate.isEmpty
                          ? _buildNoEventsMessage(context)
                          : ListView.builder(
                              itemCount: eventsOnSelectedDate.length,
                              itemBuilder: (context, index) {
                                final event = eventsOnSelectedDate[index];
                                return EventTile(
                                  ref: ref,
                                  event: event,
                                  petId: widget.petId,
                                  isExpanded: true,
                                );
                              },
                            ),
                    ),
                  ],
                )
              : Column(
                  children: [
                    _buildToggleButtons(context),
                    Expanded(
                      child: filteredEvents.isEmpty
                          ? _buildNoEventsMessage(context)
                          : ListView.builder(
                              itemCount: eventsToDisplay.length,
                              itemBuilder: (context, index) {
                                final event = eventsToDisplay[index];
                                return EventTile(
                                  ref: ref,
                                  event: event,
                                  petId: widget.petId,
                                  isExpanded: true,
                                );
                              },
                            ),
                    ),
                  ],
                ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: Theme.of(context).colorScheme.primary,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      EventTypeSelectionScreen(petId: widget.petId),
                ),
              );
            },
            child: Icon(
              Icons.add,
              color: Theme.of(context).primaryColorDark,
            ),
          ),
        );
      },
    );
  }

  Widget _buildToggleButtons(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(25),
          bottomRight: Radius.circular(25),
        ),
      ),
      child: Column(
        children: [
          Divider(
            color: Theme.of(context).colorScheme.secondary,
          ),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildEventButton(context, 'Current Events', true),
                _buildEventButton(context, 'Event History', false),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventButton(
      BuildContext context, String label, bool isSelected) {
    return GestureDetector(
      onTap: () => setState(() => isCurrentSelected = isSelected),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 20.0),
        decoration: BoxDecoration(
          color: (isCurrentSelected == isSelected)
              ? Theme.of(context).colorScheme.secondary
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: (isCurrentSelected == isSelected)
                ? Theme.of(context).primaryColorDark
                : Theme.of(context).primaryColorDark.withOpacity(0.5),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildNoEventsMessage(BuildContext context) {
    return Center(
      child: Text(
        "No events scheduled for this date.",
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).primaryColorDark,
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
        children: ['Calendar', 'List'].map((label) {
          final isSelected =
              (label == 'Calendar') ? isCalendarView : !isCalendarView;
          return TextButton(
            onPressed: () =>
                setState(() => isCalendarView = (label == 'Calendar')),
            style: TextButton.styleFrom(
              backgroundColor:
                  isSelected ? const Color(0xff68a2b6).withOpacity(0.2) : null,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isSelected
                    ? Theme.of(context).primaryColorDark
                    : Theme.of(context).primaryColorDark.withOpacity(0.5),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
