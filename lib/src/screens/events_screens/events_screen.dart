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
  bool isLoadingMore = false;
  int itemsToLoad = 5;
  late AnimationController _animationController;
  late Animation<Offset> _bounceAnimation;
  Map<String, bool> expandedEvents = {};
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );

    _bounceAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.bounceOut,
    ));
  }

  void _triggerNoEventsAnimation() {
    if (mounted) {
      _animationController.forward(from: 0.0);
    }
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
        final monthLater = now.add(const Duration(days: 30));

        final filteredEvents = allEvents.where((event) {
          return isCurrentSelected
              ? event.eventDate
                      .isAfter(now.subtract(const Duration(days: 1))) &&
                  event.eventDate.isBefore(monthLater)
              : event.eventDate.isBefore(now);
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
                            calendarFormat: CalendarFormat.month,
                            selectedDayPredicate: (day) =>
                                isSameDay(selectedDate, day),
                            onDaySelected: (selectedDay, _) {
                              setState(() => selectedDate = selectedDay);
                              if (allEvents
                                  .where((event) =>
                                      isSameDay(event.eventDate, selectedDay))
                                  .isEmpty) {
                                _triggerNoEventsAnimation();
                              }
                            },
                            eventLoader: (day) {
                              return allEvents
                                  .where((event) =>
                                      isSameDay(event.eventDate, day))
                                  .toList();
                            },
                            calendarBuilders: CalendarBuilders(
                              markerBuilder: (context, date, events) {
                                if (events.isNotEmpty) {
                                  return Align(
                                    alignment: Alignment.topRight,
                                    child: Container(
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.red,
                                      ),
                                      width: 5.0,
                                      height: 5.0,
                                      margin: const EdgeInsets.only(
                                          top: 7, right: 7),
                                    ),
                                  );
                                }
                                return null;
                              },
                            ),
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
                            calendarStyle: CalendarStyle(
                              todayDecoration: BoxDecoration(
                                color: Theme.of(context)
                                    .colorScheme
                                    .inversePrimary,
                                shape: BoxShape.circle,
                              ),
                              selectedDecoration: BoxDecoration(
                                color: Theme.of(context)
                                    .colorScheme
                                    .inversePrimary
                                    .withOpacity(0.9),
                                shape: BoxShape.circle,
                              ),
                            ),
                            daysOfWeekVisible: false,
                            startingDayOfWeek: StartingDayOfWeek.monday,
                          ),
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
                                return GestureDetector(
                                  onTap: () => setState(() {
                                    expandedEvents[event.id] =
                                        !(expandedEvents[event.id] ?? false);
                                  }),
                                  child: EventTile(
                                    ref: ref,
                                    event: event,
                                    isExpanded:
                                        expandedEvents[event.id] ?? false,
                                    petId: widget.petId,
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                )
              : Column(
                  children: [
                    _buildToggleButtons(context),
                    if (filteredEvents.isEmpty) _buildNoEventsMessage(context),
                    Expanded(
                      child: NotificationListener<ScrollNotification>(
                        onNotification: (scrollInfo) {
                          if (scrollInfo.metrics.pixels ==
                                  scrollInfo.metrics.maxScrollExtent &&
                              !isLoadingMore &&
                              scrollInfo.metrics.axisDirection ==
                                  AxisDirection.down) {
                            if (mounted) {
                              setState(() {
                                isLoadingMore = true;
                              });
                            }
                            Future.delayed(const Duration(seconds: 2), () {
                              if (mounted) {
                                setState(() {
                                  itemsToLoad += 5;
                                  isLoadingMore = false;
                                });
                              }
                            });
                          }
                          return false;
                        },
                        child: ListView.builder(
                          itemCount:
                              eventsToDisplay.length + (isLoadingMore ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index >= eventsToDisplay.length) {
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 20),
                                child: Center(
                                  child: CircularProgressIndicator(
                                    color: Theme.of(context).primaryColorDark,
                                  ),
                                ),
                              );
                            }
                            final event = eventsToDisplay[index];
                            return GestureDetector(
                              onTap: () => setState(() {
                                expandedEvents[event.id] =
                                    !(expandedEvents[event.id] ?? false);
                              }),
                              child: EventTile(
                                ref: ref,
                                event: event,
                                isExpanded: expandedEvents[event.id] ?? false,
                                petId: widget.petId,
                              ),
                            );
                          },
                        ),
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 100.0),
      child: Center(
        child: FadeTransition(
          opacity: _animationController.drive(
            Tween<double>(begin: 0.0, end: 1.0),
          ),
          child: SlideTransition(
            position: _bounceAnimation,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 40),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.event_busy,
                    size: 50,
                    color: Theme.of(context).primaryColorDark,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "No events scheduled for this date.\nCheck back later or add a new event!",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColorDark,
                    ),
                  ),
                ],
              ),
            ),
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
