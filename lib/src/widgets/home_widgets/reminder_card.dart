import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/models/events_models/event_reminder_model.dart';
import 'package:pet_diary/src/models/pet_model.dart';
import 'package:pet_diary/src/providers/event_provider.dart';
import 'package:pet_diary/src/providers/event_reminder_provider.dart';
import 'package:pet_diary/src/providers/pet_provider.dart';
import 'package:pet_diary/src/screens/add_reminder_screen.dart';
import 'package:pet_diary/src/screens/pet_details_screen.dart';
import 'dart:async';

class ReminderCard extends ConsumerStatefulWidget {
  const ReminderCard({super.key});

  @override
  createState() => _ReminderCardState();
}

class _ReminderCardState extends ConsumerState<ReminderCard> {
  int _currentPage = 0;
  final PageController _pageController = PageController();
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndRemovePastReminders();
    });
    _startTimer();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _checkAndRemovePastReminders();
    });
  }

  @override
  Widget build(BuildContext context) {
    final asyncReminders = ref.watch(eventRemindersProvider);
    final asyncPets = ref.watch(petsProvider);

    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(10.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            asyncReminders.when(
              loading: () => const CircularProgressIndicator(),
              error: (err, stack) => const Text('Error fetching reminders'),
              data: (reminders) {
                reminders.sort((a, b) => a.dateTime.compareTo(b.dateTime));
                final uniqueReminders = _removeDuplicateReminders(reminders);
                final paginatedReminders =
                    _paginateReminders(uniqueReminders, 5);

                return Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text(
                          reminders.isEmpty
                              ? 'No scheduled reminders'
                              : 'Your reminders',
                          style: TextStyle(
                            fontSize: 13,
                            color: Theme.of(context).primaryColorDark,
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                          height: 75,
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const AddReminderScreen(
                                  petId: 'samplePetId',
                                ),
                              ),
                            );
                          },
                          style: TextButton.styleFrom(
                            backgroundColor: const Color(0xff68a2b6),
                            minimumSize: const Size(120, 35),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            'R e m i n d e r',
                            style: TextStyle(
                              fontSize: 11,
                              color: Theme.of(context).primaryColorDark,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (reminders.isNotEmpty)
                      SizedBox(
                        height: reminders.length > 5 ? 300 : null,
                        child: reminders.length > 5
                            ? PageView.builder(
                                controller: _pageController,
                                onPageChanged: (index) {
                                  setState(() {
                                    _currentPage = index;
                                  });
                                },
                                itemCount: paginatedReminders.length,
                                itemBuilder: (context, pageIndex) {
                                  return Column(
                                    children: paginatedReminders[pageIndex]
                                        .map((reminder) {
                                      return asyncPets.when(
                                        loading: () =>
                                            const CircularProgressIndicator(),
                                        error: (err, stack) =>
                                            const Text('Error fetching pets'),
                                        data: (pets) {
                                          final petList = pets
                                              .where((pet) => reminder
                                                  .selectedPets
                                                  .contains(pet.id))
                                              .toList();
                                          return _buildReminderTile(
                                              context, reminder, petList);
                                        },
                                      );
                                    }).toList(),
                                  );
                                },
                              )
                            : ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: reminders.length,
                                itemBuilder: (context, index) {
                                  final reminder = reminders[index];
                                  return asyncPets.when(
                                    loading: () =>
                                        const CircularProgressIndicator(),
                                    error: (err, stack) =>
                                        const Text('Error fetching pets'),
                                    data: (pets) {
                                      final petList = pets
                                          .where((pet) => reminder.selectedPets
                                              .contains(pet.id))
                                          .toList();
                                      return _buildReminderTile(
                                          context, reminder, petList);
                                    },
                                  );
                                },
                              ),
                      ),
                    if (reminders.length > 5)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back),
                            onPressed: _currentPage > 0
                                ? () {
                                    _pageController.previousPage(
                                      duration:
                                          const Duration(milliseconds: 300),
                                      curve: Curves.easeInOut,
                                    );
                                  }
                                : null,
                          ),
                          IconButton(
                            icon: const Icon(Icons.arrow_forward),
                            onPressed:
                                _currentPage < paginatedReminders.length - 1
                                    ? () {
                                        _pageController.nextPage(
                                          duration:
                                              const Duration(milliseconds: 300),
                                          curve: Curves.easeInOut,
                                        );
                                      }
                                    : null,
                          ),
                        ],
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _checkAndRemovePastReminders() async {
    await ref.read(eventReminderServiceProvider).removeExpiredReminders();
  }

  List<List<EventReminderModel>> _paginateReminders(
      List<EventReminderModel> reminders, int itemsPerPage) {
    List<List<EventReminderModel>> paginatedReminders = [];
    for (var i = 0; i < reminders.length; i += itemsPerPage) {
      paginatedReminders.add(reminders.sublist(
        i,
        i + itemsPerPage > reminders.length
            ? reminders.length
            : i + itemsPerPage,
      ));
    }
    return paginatedReminders;
  }

  List<EventReminderModel> _removeDuplicateReminders(
      List<EventReminderModel> reminders) {
    final uniqueReminders = <String, EventReminderModel>{};
    for (var reminder in reminders) {
      if (uniqueReminders.containsKey(reminder.objectId)) {
        final existingReminder = uniqueReminders[reminder.objectId];
        existingReminder?.selectedPets.addAll(reminder.selectedPets
            .where((petId) => !existingReminder.selectedPets.contains(petId)));
      } else {
        uniqueReminders[reminder.objectId] = reminder;
      }
    }
    return uniqueReminders.values.toList();
  }

  Widget _buildReminderTile(
      BuildContext context, EventReminderModel reminder, List<Pet> pets) {
    return ExpansionTile(
      shape: const Border(),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                reminder.title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(reminder.time.format(context))
            ],
          ),
          if (reminder.description.isNotEmpty)
            Text(
              reminder.description,
              style: const TextStyle(fontSize: 11),
            ),
        ],
      ),
      children: [
        if (reminder.repeatOption != 'Once')
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Wrap(
                children: pets.map((pet) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PetDetailsScreen(petId: pet.id),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(
                          top: 3.0, left: 15, right: 15, bottom: 3),
                      child: Column(
                        children: [
                          CircleAvatar(
                            backgroundImage: AssetImage(pet.avatarImage),
                            radius: 27,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(3.0),
                            child: Text(pet.name),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 15, right: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                      '${reminder.dateTime.day}.${reminder.dateTime.month}.${reminder.dateTime.year}'),
                  if (!reminder.dateTime.isAfter(reminder.endDate))
                    const Text(
                      ' - ',
                      style: TextStyle(fontSize: 18),
                    ),
                  if (!reminder.dateTime.isAfter(reminder.endDate))
                    Text(
                        '${reminder.endDate.day}.${reminder.endDate.month}.${reminder.endDate.year}'),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () async {
                await _deleteReminder(reminder);
              },
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _deleteReminder(EventReminderModel reminder) async {
    await ref.read(eventReminderServiceProvider).deleteReminder(reminder.id);
    await ref.read(eventServiceProvider).deleteEvent(reminder.id);

    if (reminder.repeatOption != 'Once') {
      final reminders =
          await ref.read(eventReminderServiceProvider).getReminders();
      final relatedReminders = reminders
          .where((r) =>
              r.objectId == reminder.objectId &&
              r.dateTime.isAfter(reminder.dateTime))
          .toList();
      for (var relatedReminder in relatedReminders) {
        await ref
            .read(eventReminderServiceProvider)
            .deleteReminder(relatedReminder.id);
        await ref.read(eventServiceProvider).deleteEvent(relatedReminder.id);
      }
    }
  }
}
