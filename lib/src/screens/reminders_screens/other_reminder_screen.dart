import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/models/events_models/event_model.dart';
import 'package:pet_diary/src/models/reminder_models/other_reminder_model.dart';
import 'package:pet_diary/src/providers/events_providers/event_provider.dart';
import 'package:pet_diary/src/providers/others_providers/user_provider.dart';
import 'package:pet_diary/src/providers/others_providers/pet_provider.dart';
import 'package:pet_diary/src/helpers/others/show_styled_time_picker.dart';
import 'package:pet_diary/src/helpers/others/show_styled_date_picker.dart';
import 'package:pet_diary/src/providers/reminder_providers/other_service_provider.dart';
import 'package:pet_diary/src/services/notification_services/notification_services.dart';

/// Screen for managing other reminders with advanced options.
class OtherReminderScreen extends ConsumerStatefulWidget {
  const OtherReminderScreen({super.key});

  @override
  ConsumerState<OtherReminderScreen> createState() =>
      _OtherReminderScreenState();
}

class _OtherReminderScreenState extends ConsumerState<OtherReminderScreen> {
  bool isCurrentReminders = true; // Toggles between current and history
  final TextEditingController _nameController =
      TextEditingController(); // Reminder name
  final TextEditingController _reasonController =
      TextEditingController(); // Reminder reasonf
  final List<String> _selectedPets = [];
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  // Fields for early notifications
  List<Map<String, dynamic>> _additionalNotifications = [
    {'value': 1, 'unit': 'day'},
  ];
  bool enableAdditionalNotifications = false;

  // Fields for repeat functionality
  bool enableRepeat = false;
  String repeatUnit = 'week';
  int repeatInterval = 1;
  DateTime? repeatEndDate;

  @override
  Widget build(BuildContext context) {
    final userId = ref.read(userIdProvider)!;
    final now = DateTime.now();

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'O T H E R  R E M I N D E R S',
          style: TextStyle(
            color: Theme.of(context).primaryColorDark,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        iconTheme: IconThemeData(color: Theme.of(context).primaryColorDark),
        actions: [
          IconButton(
            icon: Icon(
              Icons.add,
              color: Theme.of(context).primaryColorDark,
              size: 30,
            ),
            onPressed: _showAddReminderModal,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildToggleButtons(),
          Expanded(
            child: StreamBuilder<List<OtherReminderModel>>(
              stream: ref
                  .read(otherReminderServiceProvider)
                  .getOtherReminders(userId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error: ${snapshot.error}',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                        fontSize: 14,
                      ),
                    ),
                  );
                }

                final reminders = snapshot.data ?? [];
                final filteredReminders = _filterReminders(reminders, now);

                if (filteredReminders.isEmpty) {
                  return Center(
                    child: Text(
                      isCurrentReminders
                          ? 'No upcoming other reminders.'
                          : 'No other reminder history.',
                      style: TextStyle(
                        color: Theme.of(context).primaryColorDark,
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: filteredReminders.length,
                  itemBuilder: (context, index) {
                    final reminder = filteredReminders[index];
                    return _buildReminderCard(reminder);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Toggle buttons for switching between current and history reminders
  Widget _buildToggleButtons() {
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
          Divider(color: Theme.of(context).colorScheme.surface),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildToggleButton('Current', true),
                _buildToggleButton('History', false),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Builds an individual toggle button
  Widget _buildToggleButton(String label, bool isSelected) {
    final isActive = isSelected == isCurrentReminders;
    return GestureDetector(
      onTap: () {
        setState(() {
          isCurrentReminders = isSelected;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 20.0),
        decoration: BoxDecoration(
          color: isActive
              ? Theme.of(context).colorScheme.secondary
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive
                ? Theme.of(context).primaryColorDark
                : Theme.of(context).primaryColorDark.withOpacity(0.4),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  /// Filters reminders into current or history
  List<OtherReminderModel> _filterReminders(
      List<OtherReminderModel> reminders, DateTime now) {
    final today = DateTime(now.year, now.month, now.day);

    return isCurrentReminders
        ? reminders
            .where((reminder) =>
                reminder.date.isAtSameMomentAs(today) ||
                reminder.date.isAfter(today))
            .toList()
        : reminders.where((reminder) => reminder.date.isBefore(today)).toList();
  }

  /// Builds the reminder card to display in the list
  Widget _buildReminderCard(OtherReminderModel reminder) {
    return Card(
      color: Theme.of(context).colorScheme.primary,
      margin: const EdgeInsets.all(10),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    reminder.reason,
                    style: TextStyle(
                      color: Theme.of(context).primaryColorDark,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${reminder.time.format(context)}  ${DateFormat('dd-MM-yyyy').format(reminder.date)} ',
                    style: TextStyle(
                      color: Theme.of(context).primaryColorDark,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text(
                reminder.reason,
                style: TextStyle(
                    color: Theme.of(context).primaryColorDark, fontSize: 14),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0, top: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: reminder.assignedPetIds.map((petId) {
                      final pet = ref.read(petsProvider).maybeWhen(
                            data: (pets) => pets.firstWhere(
                              (pet) => pet.id == petId,
                            ),
                            orElse: () => null,
                          );
                      return pet != null
                          ? Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: CircleAvatar(
                                backgroundImage: AssetImage(pet.avatarImage),
                                radius: 25,
                              ),
                            )
                          : Container();
                    }).toList(),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.delete,
                      color: Theme.of(context).primaryColorDark,
                    ),
                    onPressed: () async {
                      final eventService = ref.read(eventServiceProvider);
                      final otherReminderService =
                          ref.read(otherReminderServiceProvider);

                      // Usuń wszystkie powiązane wydarzenia
                      for (final eventId in reminder.eventIds) {
                        await eventService.deleteEvent(eventId);
                      }
                      // Cancel main notification
                      await NotificationService()
                          .cancelNotification(reminder.hashCode);

                      // Cancel early notifications
                      for (final notificationId
                          in reminder.earlyNotificationIds) {
                        await NotificationService()
                            .cancelNotification(notificationId);
                      }

                      // Usuń przypomnienie
                      await otherReminderService
                          .deleteOtherReminder(reminder.id);

                      setState(() {}); // Odśwież widok po usunięciu
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Displays the modal for adding a new reminder
  void _showAddReminderModal() {
    _nameController.clear();
    _reasonController.clear();
    _selectedDate = null;
    _selectedTime = null;
    enableAdditionalNotifications = false;
    enableRepeat = false;
    repeatInterval = 1;
    repeatUnit = 'week';
    repeatEndDate = null;
    _additionalNotifications = [
      {'value': 1, 'unit': 'day'},
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              color: Theme.of(context).colorScheme.primary,
              child: Padding(
                padding: MediaQuery.of(context).viewInsets,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Add Other Reminder',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Theme.of(context).primaryColorDark,
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () => _saveReminder(setModalState),
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    Theme.of(context).primaryColorDark,
                              ),
                              child: Text(
                                'Save',
                                style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                    fontSize: 16),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Divider(color: Theme.of(context).colorScheme.secondary),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: _buildPetSelection(setModalState),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: _buildReminderTitleInput(setModalState),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: _buildReasonInput(setModalState),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: _buildDatePicker(setModalState),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: _buildTimePicker(setModalState),
                      ),
                      Divider(color: Theme.of(context).colorScheme.secondary),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: _buildAdditionalNotifications(setModalState),
                      ),
                      const SizedBox(
                        height: 25,
                      )
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// Input for reminder name
  Widget _buildReminderTitleInput(StateSetter setModalState) {
    return TextField(
      controller: _nameController,
      decoration: InputDecoration(
        labelText: 'Title',
        labelStyle: TextStyle(
          color: Theme.of(context).primaryColorDark,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(
            color: Theme.of(context).primaryColorDark,
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(
            color: Theme.of(context).primaryColorDark,
            width: 1,
          ),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 10,
          horizontal: 15,
        ),
      ),
      style: TextStyle(
        color: Theme.of(context).primaryColorDark,
      ),
      cursorColor: Theme.of(context).primaryColorDark,
      onChanged: (value) {
        setModalState(() {});
      },
    );
  }

  Future<void> _saveReminder(StateSetter setModalState) async {
    if (_nameController.text.isEmpty ||
        _selectedDate == null ||
        _selectedTime == null ||
        _reasonController.text.isEmpty ||
        _selectedPets.isEmpty) {
      await _showValidationError(context);
      return;
    }

    final userId = ref.read(userIdProvider)!;
    final reminderId = UniqueKey().toString();

    final reminderDateTime = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );

    // Tworzenie powiązanych wydarzeń
    final List<String> eventIds = [];
    for (final petId in _selectedPets) {
      final eventId = UniqueKey().toString();
      final event = Event(
        id: eventId,
        title: _nameController.text,
        eventDate: reminderDateTime,
        dateWhenEventAdded: DateTime.now(),
        userId: userId,
        petId: petId,
        description: _reasonController.text,
        emoticon: '🔔',
        otherReminderId: reminderId,
      );

      await ref.read(eventServiceProvider).addEvent(event);
      eventIds.add(eventId);
    }

    // Tworzenie przypomnienia
    final reminder = OtherReminderModel(
      id: reminderId,
      userId: userId,
      reason: _reasonController.text,
      assignedPetIds: _selectedPets,
      date: _selectedDate!,
      time: _selectedTime!,
      earlyNotificationIds: [],
      eventIds: eventIds,
    );

    // Tworzenie wczesnych powiadomień
    final earlyNotificationIds = <int>[];
    for (var notification in _additionalNotifications) {
      final int value = notification['value'];
      final String unit = notification['unit'];

      DateTime earlyNotificationTime;
      if (unit == 'minute') {
        earlyNotificationTime =
            reminderDateTime.subtract(Duration(minutes: value));
      } else if (unit == 'hour') {
        earlyNotificationTime =
            reminderDateTime.subtract(Duration(hours: value));
      } else {
        earlyNotificationTime =
            reminderDateTime.subtract(Duration(days: value));
      }

      if (earlyNotificationTime.isAfter(DateTime.now())) {
        final earlyNotificationId = reminderId.hashCode + value;
        earlyNotificationIds.add(earlyNotificationId);
        await NotificationService().createSingleNotification(
          id: earlyNotificationId,
          title: 'Early Reminder',
          body: _generateNotificationBody(reminder),
          dateTime: earlyNotificationTime,
          payload: 'other_reminder_early',
        );
      }
    }

    // Tworzenie głównej notyfikacji
    final mainNotificationId = reminderId.hashCode;
    await NotificationService().createSingleNotification(
      id: mainNotificationId,
      title: 'Reminder: ${_nameController.text}',
      body: _generateNotificationBody(reminder),
      dateTime: reminderDateTime,
      payload: 'other_reminder',
    );

    // Aktualizacja przypomnienia z ID wczesnych notyfikacji
    final updatedReminder = reminder.copyWith(
      earlyNotificationIds: earlyNotificationIds,
    );

    await ref
        .read(otherReminderServiceProvider)
        .addOtherReminder(updatedReminder);

    if (mounted) {
      Navigator.pop(context);
    }
  }

  String _generateNotificationBody(OtherReminderModel reminder) {
    final selectedPets = _selectedPets.map((id) {
      return ref.read(petsProvider).maybeWhen(
          data: (pets) => pets.firstWhere((pet) => pet.id == id).name,
          orElse: () => '');
    }).join(', ');
    return 'Reminder for: $selectedPets - ${reminder.reason}';
  }

  Future<void> _showValidationError(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Empty fields',
            style: TextStyle(color: Theme.of(context).primaryColorDark),
          ),
          content: const Text(
            'Please fill in all required fields!',
            textAlign: TextAlign.left,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'OK',
                style: TextStyle(color: Theme.of(context).primaryColorDark),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Widget for selecting pets for the reminder
  Widget _buildPetSelection(StateSetter setModalState) {
    final asyncPets = ref.watch(petsProvider);
    return asyncPets.when(
      data: (pets) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: pets.map((pet) {
              final isSelected = _selectedPets.contains(pet.id);
              return Padding(
                padding: const EdgeInsets.all(6.0),
                child: GestureDetector(
                  onTap: () {
                    setModalState(() {
                      isSelected
                          ? _selectedPets.remove(pet.id)
                          : _selectedPets.add(pet.id);
                    });
                  },
                  child: CircleAvatar(
                    backgroundImage: AssetImage(pet.avatarImage),
                    radius: 30,
                    backgroundColor: isSelected
                        ? Theme.of(context).colorScheme.secondary
                        : Colors.transparent,
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
      loading: () => const CircularProgressIndicator(),
      error: (e, st) => Text(e.toString()),
    );
  }

  /// Input for entering the reason for the reminder
  Widget _buildReasonInput(StateSetter setModalState) {
    return TextField(
      controller: _reasonController,
      decoration: InputDecoration(
        labelText: 'Reason',
        labelStyle: TextStyle(
          color: Theme.of(context).primaryColorDark,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(
            color: Theme.of(context).primaryColorDark,
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(
            color: Theme.of(context).primaryColorDark,
            width: 1,
          ),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 10,
          horizontal: 15,
        ),
      ),
      style: TextStyle(
        color: Theme.of(context).primaryColorDark,
      ),
      cursorColor: Theme.of(context).primaryColorDark,
      onChanged: (value) {
        setModalState(() {});
      },
    );
  }

  /// Widget for selecting the date of the reminder
  Widget _buildDatePicker(StateSetter setModalState) {
    return GestureDetector(
      onTap: () async {
        final pickedDate = await showStyledDatePicker(
          context: context,
          initialDate: _selectedDate ?? DateTime.now(),
        );
        if (pickedDate != null) {
          setModalState(() {
            _selectedDate = pickedDate;
          });
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Date',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: Text(
          _selectedDate != null
              ? DateFormat('dd-MM-yyyy').format(_selectedDate!)
              : 'Select Date',
          style: TextStyle(color: Theme.of(context).primaryColorDark),
        ),
      ),
    );
  }

  /// Widget for selecting the time of the reminder
  Widget _buildTimePicker(StateSetter setModalState) {
    return GestureDetector(
      onTap: () async {
        final pickedTime = await showStyledTimePicker(
          context: context,
          initialTime: _selectedTime ?? TimeOfDay.now(),
        );
        if (pickedTime != null) {
          setModalState(() {
            _selectedTime = pickedTime;
          });
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Time',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: Text(
          _selectedTime != null
              ? _selectedTime!.format(context)
              : 'Select Time',
          style: TextStyle(color: Theme.of(context).primaryColorDark),
        ),
      ),
    );
  }

  /// Widget for configuring early notifications
  Widget _buildAdditionalNotifications(StateSetter setModalState) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.only(
            left: enableAdditionalNotifications ? 2.0 : 15.0,
            right: enableAdditionalNotifications ? 2.0 : 15.0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Early Notifications',
                style: TextStyle(
                  color: Theme.of(context).primaryColorDark,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Switch(
                value: enableAdditionalNotifications,
                activeColor: Theme.of(context).primaryColorDark,
                onChanged: (value) {
                  setModalState(() {
                    enableAdditionalNotifications = value;
                    if (!value) _additionalNotifications.clear();
                  });
                },
              ),
            ],
          ),
        ),
        if (enableAdditionalNotifications)
          Column(
            children: [
              for (int i = 0; i < _additionalNotifications.length; i++)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: 185,
                        child: TextField(
                          decoration: InputDecoration(
                            labelText: 'Value',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            setModalState(() {
                              _additionalNotifications[i]['value'] =
                                  int.tryParse(value) ?? 0;
                            });
                          },
                        ),
                      ),
                      Row(
                        children: [
                          DropdownButton<String>(
                            value: _additionalNotifications[i]['unit'],
                            items: ['minute', 'hour', 'day']
                                .map(
                                  (unit) => DropdownMenuItem(
                                    value: unit,
                                    child: Text(unit),
                                  ),
                                )
                                .toList(),
                            onChanged: (unit) {
                              setModalState(() {
                                _additionalNotifications[i]['unit'] = unit!;
                              });
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.black),
                            onPressed: () {
                              setModalState(() {
                                _additionalNotifications.removeAt(i);
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              if (_additionalNotifications.length < 3)
                TextButton(
                  onPressed: () {
                    setModalState(() {
                      if (_additionalNotifications.length < 3) {
                        _additionalNotifications.add({
                          'value': 1,
                          'unit': 'minute',
                        });
                      }
                    });
                  },
                  child: Text(
                    '+ Add Notification',
                    style: TextStyle(color: Theme.of(context).primaryColorDark),
                  ),
                ),
            ],
          ),
      ],
    );
  }
}
