import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/models/reminder_models/other_reminder_model.dart';
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
      TextEditingController(); // Reminder reason
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
                      await ref
                          .read(otherReminderServiceProvider)
                          .deleteOtherReminder(reminder.id);
                      setState(() {});
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
                      Divider(color: Theme.of(context).colorScheme.secondary),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: _buildRepeatSettings(setModalState),
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

  /// Widget for configuring repeat settings
  Widget _buildRepeatSettings(StateSetter setModalState) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.only(
            left: enableRepeat ? 2.0 : 15.0,
            right: enableRepeat ? 2.0 : 15.0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Enable Repeat',
                style: TextStyle(
                  color: Theme.of(context).primaryColorDark,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Switch(
                value: enableRepeat,
                activeColor: Theme.of(context).primaryColorDark,
                onChanged: (value) {
                  setModalState(() {
                    enableRepeat = value;
                    if (!value) {
                      repeatInterval = 1;
                      repeatUnit = 'day';
                      repeatEndDate = null;
                    } else {
                      // Domyślna data końcowa przy włączonym powtarzaniu
                      _setDefaultRepeatEndDate(setModalState);
                    }
                  });
                },
              ),
            ],
          ),
        ),
        if (enableRepeat)
          Column(
            children: [
              // Pole "Repeat Every" jak Reminder Name
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  decoration: InputDecoration(
                    labelText: 'Repeat Every',
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
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    setModalState(() {
                      repeatInterval = int.tryParse(value) ?? 1;
                    });
                  },
                ),
              ),

              // Dropdown "Repeat Unit"
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: DropdownButtonFormField<String>(
                  value: repeatUnit,
                  decoration: InputDecoration(
                    labelText: 'Repeat Unit',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  items: [
                    'day',
                    'week',
                    'month',
                    'year',
                  ]
                      .map(
                        (unit) => DropdownMenuItem(
                          value: unit,
                          child: Text(unit),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setModalState(() {
                      repeatUnit = value!;
                      _setDefaultRepeatEndDate(setModalState);
                    });
                  },
                ),
              ),

              // Repeat End Date z ikoną informacji
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          final pickedDate = await showStyledDatePicker(
                            context: context,
                            initialDate: repeatEndDate ?? DateTime.now(),
                          );
                          if (pickedDate != null) {
                            setModalState(() {
                              repeatEndDate = pickedDate;
                            });
                          }
                        },
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: 'Repeat End Date',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: Text(
                            repeatEndDate != null
                                ? DateFormat('dd-MM-yyyy')
                                    .format(repeatEndDate!)
                                : 'Select End Date',
                            style: TextStyle(
                                color: Theme.of(context).primaryColorDark),
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.info,
                          color: Theme.of(context).primaryColorDark),
                      onPressed: () {
                        _showRepeatEndDateInfo(context);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
      ],
    );
  }

  /// Ustawia domyślną datę końcową na podstawie repeatUnit
  void _setDefaultRepeatEndDate(StateSetter setModalState) {
    final DateTime startDate = _selectedDate ?? DateTime.now();
    setModalState(() {
      switch (repeatUnit) {
        case 'day':
          repeatEndDate = startDate.add(const Duration(days: 7));
          break;
        case 'week':
          repeatEndDate = startDate.add(const Duration(days: 14));
          break;
        case 'month':
          repeatEndDate =
              DateTime(startDate.year, startDate.month + 2, startDate.day);
          break;
        case 'year':
          repeatEndDate =
              DateTime(startDate.year + 2, startDate.month, startDate.day);
          break;
      }
    });
  }

  /// Wyświetla szczegóły dotyczące Repeat End Date
  void _showRepeatEndDateInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Repeat End Date Info',
            style: TextStyle(color: Theme.of(context).primaryColorDark),
          ),
          content: Text(
            'The "Repeat End Date" determines the last date for repeating reminders. '
            'If you select "Day," the default is 7 days from the start date. '
            'For "Month," it is 2 months forward, and for "Year," it is 2 years forward. '
            'You can adjust this manually.',
            style: TextStyle(color: Theme.of(context).primaryColorDark),
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

  /// Saves the reminder, handles repeat logic
  Future<void> _saveReminder(StateSetter setModalState) async {
    if (_nameController.text.isEmpty ||
        _selectedDate == null ||
        _selectedTime == null ||
        _reasonController.text.isEmpty) {
      await _showValidationError(context);
      return;
    }

    final userId = ref.read(userIdProvider)!;

    final reminder = OtherReminderModel(
      id: UniqueKey().toString(),
      userId: userId,
      reason: _reasonController.text,
      assignedPetIds: _selectedPets,
      date: _selectedDate!,
      time: _selectedTime!,
      earlyNotificationIds: [],
    );

    const int maxRepeats = 100; // Maksymalna liczba powtórzeń
    int repeatCount = 0;

    if (enableRepeat) {
      DateTime nextReminderDate = _selectedDate!;

      while (true) {
        // Zwiększ licznik powtórzeń
        repeatCount++;

        // Jeśli liczba powtórzeń przekracza limit, wyświetl komunikat i zakończ zapis
        if (repeatCount > maxRepeats) {
          await _showTooManyRepeatsError(context, repeatCount);
          return;
        }

        // Oblicz datę kolejnego przypomnienia
        switch (repeatUnit) {
          case 'day':
            nextReminderDate = nextReminderDate.add(const Duration(days: 1));
            break;
          case 'week':
            nextReminderDate = nextReminderDate.add(const Duration(days: 7));
            break;
          case 'month':
            nextReminderDate = DateTime(
              nextReminderDate.year,
              nextReminderDate.month + 1,
              nextReminderDate.day,
            );
            break;
          case 'year':
            nextReminderDate = DateTime(
              nextReminderDate.year + 1,
              nextReminderDate.month,
              nextReminderDate.day,
            );
            break;
        }

        // Jeśli osiągnięto datę końcową, przerwij pętlę
        if (repeatEndDate != null && nextReminderDate.isAfter(repeatEndDate!)) {
          break;
        }
      }
    }

    await ref.read(otherReminderServiceProvider).addOtherReminder(reminder);

    if (mounted) {
      Navigator.pop(context);
    }
  }

  /// Wyświetla komunikat o przekroczeniu limitu powtórzeń
  Future<void> _showTooManyRepeatsError(
      BuildContext context, int repeatCount) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Too Many Repeats',
            style: TextStyle(color: Theme.of(context).primaryColorDark),
          ),
          content: Text(
            'This reminder would generate $repeatCount notifications. '
            'This may cause slow performance and is not allowed. '
            'Please reduce the repeat frequency or end date.',
            style: TextStyle(color: Theme.of(context).primaryColorDark),
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
