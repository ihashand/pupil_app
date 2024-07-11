import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/models/event_reminder_model.dart';
import 'package:pet_diary/src/providers/event_reminder_provider.dart';
import 'package:pet_diary/src/screens/add_reminder_screen.dart';

class ReminderCard extends ConsumerStatefulWidget {
  const ReminderCard({super.key});

  @override
  createState() => _ReminderCardState();
}

class _ReminderCardState extends ConsumerState<ReminderCard> {
  int _currentPage = 0;
  final PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    final asyncReminders = ref.watch(eventRemindersProvider);

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
                final paginatedReminders = _paginateReminders(reminders, 5);

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
                                  petId:
                                      'samplePetId', // Update with actual pet ID
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
                                      return _buildReminderTile(
                                          context, reminder);
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
                                  return _buildReminderTile(context, reminder);
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

  Widget _buildReminderTile(BuildContext context, EventReminderModel reminder) {
    return ExpansionTile(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(reminder.title),
          Text(reminder.time.format(context)),
        ],
      ),
      children: [
        ListTile(
          title: Text('Type: ${reminder.repeatOption}'),
          subtitle: Text(reminder.description),
          trailing: IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              await ref
                  .read(eventReminderServiceProvider)
                  .deleteReminder(reminder.id);
            },
          ),
        ),
      ],
    );
  }
}
