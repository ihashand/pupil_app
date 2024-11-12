import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pet_diary/src/helpers/others/generate_unique_id.dart';
import 'package:pet_diary/src/helpers/others/show_styled_date_picker.dart';
import 'package:pet_diary/src/helpers/others/show_styled_time_picker.dart';
import 'package:pet_diary/src/models/events_models/event_reminder_model.dart';
import 'package:pet_diary/src/providers/events_providers/event_reminder_provider.dart';
import 'package:pet_diary/src/providers/others_providers/pet_provider.dart';
import 'package:pet_diary/src/services/other_services/notification_services.dart';

class AddReminderScreen extends ConsumerStatefulWidget {
  const AddReminderScreen({super.key});

  @override
  ConsumerState<AddReminderScreen> createState() => _AddReminderScreenState();
}

class _AddReminderScreenState extends ConsumerState<AddReminderScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _intervalController;

  DateTime _selectedStartDate = DateTime.now();
  DateTime? _selectedEndDate;
  final List<TimeOfDay> _selectedTimes = [TimeOfDay.now()];
  String _repeatOption = 'Daily';
  final List<String> _selectedPetIds = [];
  final Map<String, bool> _daysOfWeek = {
    'Monday': false,
    'Tuesday': false,
    'Wednesday': false,
    'Thursday': false,
    'Friday': false,
    'Saturday': false,
    'Sunday': false,
  };

  int _frequency = 0;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _descriptionController = TextEditingController();
    _intervalController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _intervalController.dispose();
    super.dispose();
  }

  void _saveReminder() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (_selectedPetIds.isEmpty) {
        _showErrorDialog('Please select at least one pet for the reminder.');
        return;
      }

      String reminderTitle = _selectedPetIds
          .map((id) {
            final pet =
                ref.read(petsProvider).value?.firstWhere((p) => p.id == id);
            return pet?.name ?? '';
          })
          .where((name) => name.isNotEmpty)
          .join(', ');

      String description = _descriptionController.text;

      DateTime currentDate = _selectedStartDate;
      DateTime endDate = _selectedEndDate ?? _selectedStartDate;

      while (currentDate.isBefore(endDate.add(const Duration(days: 1)))) {
        for (var petId in _selectedPetIds) {
          for (var time in _selectedTimes) {
            DateTime eventDateTime = DateTime(
              currentDate.year,
              currentDate.month,
              currentDate.day,
              time.hour,
              time.minute,
            );

            EventReminderModel reminder = EventReminderModel(
              id: generateUniqueId(),
              title: reminderTitle,
              description: description,
              userId: FirebaseAuth.instance.currentUser!.uid,
              selectedPets: _selectedPetIds,
              repeatOption: _repeatOption,
              dateTime: eventDateTime,
              endDate: endDate,
              time: time,
              objectId: petId,
              selectedDays: [],
            );

            await ref.read(eventReminderServiceProvider).addReminder(reminder);

            await NotificationService().createNotification(
              id: reminder.hashCode,
              title: 'Reminder: ${reminder.title}',
              body: reminder.description,
              scheduledDate: eventDateTime,
            );
          }
        }
        currentDate = currentDate.add(const Duration(days: 1));
      }

      // ignore: use_build_context_synchronously
      Navigator.of(context).pop();
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Invalid Input'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'OK',
              style: TextStyle(color: Theme.of(context).primaryColorDark),
            ),
          ),
        ],
      ),
    );
  }

  void _updateReminderTimes(int frequency) {
    setState(() {
      while (_selectedTimes.length < frequency) {
        _selectedTimes.add(TimeOfDay.now());
      }
      while (_selectedTimes.length > frequency) {
        _selectedTimes.removeLast();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'A D D  R E M I N D E R',
          style: TextStyle(
            color: Theme.of(context).primaryColorDark,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        iconTheme: IconThemeData(color: Theme.of(context).primaryColorDark),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildPetAvatarSelection(),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: _buildContainer([
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    child:
                        _buildTextInput(_nameController, 'Reminder Name', '🔔'),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    child: _buildTextInput(
                        _descriptionController, 'Description', '📝'),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15.0),
                          child: _buildDateInput(
                              context, 'Start Date', _selectedStartDate,
                              (pickedDate) {
                            setState(() {
                              _selectedStartDate = pickedDate;
                            });
                          }),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15.0),
                          child: _buildDateInput(context, 'End Date',
                              _selectedEndDate ?? DateTime.now(), (pickedDate) {
                            setState(() {
                              _selectedEndDate = pickedDate;
                            });
                          }),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    child: _buildRepeatOptions(),
                  ),
                  const SizedBox(height: 10),
                  if (_repeatOption == 'Every X Days' ||
                      _repeatOption == 'Every X Weeks' ||
                      _repeatOption == 'Every X Months')
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15.0, vertical: 10.0),
                      child: _buildTextInput(
                          _intervalController, 'Interval', '🔁'),
                    ),
                  if (_repeatOption == 'Selected Days of the Week')
                    _buildDaysOfWeekSelector(),
                  _buildFrequencySelector(),
                  if (_frequency > 0) ..._buildTimeSelectors(),
                  const SizedBox(height: 20),
                ]),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(30.0),
        child: ElevatedButton(
          onPressed: _saveReminder,
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
            padding: const EdgeInsets.all(12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            'S A V E  R E M I N D E R',
            style: TextStyle(
              color: Theme.of(context).primaryColorDark,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPetAvatarSelection() {
    final asyncPets = ref.watch(petsProvider);
    return asyncPets.when(
      data: (pets) {
        return Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(22),
              bottomRight: Radius.circular(22),
            ),
          ),
          child: Column(
            children: [
              Divider(color: Theme.of(context).colorScheme.secondary),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: pets.map((pet) {
                    final isSelected = _selectedPetIds.contains(pet.id);
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          isSelected
                              ? _selectedPetIds.remove(pet.id)
                              : _selectedPetIds.add(pet.id);
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Column(
                          children: [
                            CircleAvatar(
                              backgroundImage: AssetImage(pet.avatarImage),
                              radius: 30,
                              backgroundColor: isSelected
                                  ? Theme.of(context).colorScheme.secondary
                                  : Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(height: 5),
                            Text(
                              pet.name,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: isSelected
                                    ? Theme.of(context).primaryColorDark
                                    : Theme.of(context).primaryColorLight,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(child: Text(e.toString())),
    );
  }

  Widget _buildContainer(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildTextInput(
      TextEditingController controller, String label, String emoji,
      {Function(String)? onChanged}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 12, right: 20),
          child: Text(emoji, style: const TextStyle(fontSize: 35)),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Theme.of(context).primaryColorDark),
        ),
      ),
      validator: (value) =>
          value == null || value.isEmpty ? 'Please enter $label' : null,
      onChanged: onChanged,
    );
  }

  Widget _buildDateInput(BuildContext context, String label, DateTime date,
      Function(DateTime) onDateSelected) {
    return GestureDetector(
      onTap: () async {
        final pickedDate = await showStyledDatePicker(
          context: context,
          initialDate: date,
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (pickedDate != null) {
          onDateSelected(pickedDate);
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: const Padding(
            padding: EdgeInsets.only(left: 12, right: 20),
            child: Text('📅', style: TextStyle(fontSize: 35)),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Theme.of(context).primaryColorDark),
          ),
        ),
        child: Text(
          DateFormat('dd-MM-yyyy').format(date),
          style: TextStyle(color: Theme.of(context).primaryColorDark),
        ),
      ),
    );
  }

  Widget _buildRepeatOptions() {
    return DropdownButtonFormField<String>(
      value: _repeatOption,
      onChanged: (value) {
        setState(() {
          _repeatOption = value!;
        });
      },
      items: [
        'Daily',
        'Every X Days',
        'Every X Weeks',
        'Every X Months',
        'Selected Days of the Week'
      ]
          .map((label) => DropdownMenuItem(value: label, child: Text(label)))
          .toList(),
      decoration: InputDecoration(
        labelText: 'Repeat Option',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Theme.of(context).primaryColorDark),
        ),
      ),
    );
  }

  Widget _buildFrequencySelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).primaryColorDark),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Padding(
                  padding: EdgeInsets.only(right: 8.0),
                  child: Text('⏰', style: TextStyle(fontSize: 24)),
                ),
                Text(
                  'Frequency',
                  style: TextStyle(
                    color: Theme.of(context).primaryColorDark,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.remove_circle_outline,
                      color: Theme.of(context).primaryColorDark),
                  onPressed: () {
                    setState(() {
                      if (_frequency > 0) _frequency--;
                      _updateReminderTimes(_frequency);
                    });
                  },
                ),
                Text(
                  '$_frequency',
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).primaryColorDark,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.add_circle_outline,
                      color: Theme.of(context).primaryColorDark),
                  onPressed: () {
                    setState(() {
                      if (_frequency < 12) _frequency++;
                      _updateReminderTimes(_frequency);
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDaysOfWeekSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: _daysOfWeek.keys.map((day) {
          final isSelected = _daysOfWeek[day]!;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2.0),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _daysOfWeek[day] = !isSelected;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Theme.of(context).colorScheme.secondary
                        : Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(6),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: Theme.of(context)
                                  .colorScheme
                                  .secondary
                                  .withOpacity(0.3),
                              spreadRadius: 1,
                              blurRadius: 3,
                            ),
                          ]
                        : null,
                    border: Border.all(
                      color: isSelected
                          ? Theme.of(context).colorScheme.secondary
                          : Theme.of(context).primaryColorLight,
                      width: isSelected ? 1.5 : 1.0,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      day.substring(0, 3).toUpperCase(),
                      style: TextStyle(
                        color: isSelected
                            ? Theme.of(context).colorScheme.onSecondary
                            : Theme.of(context).primaryColorLight,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  List<Widget> _buildTimeSelectors() {
    return List.generate(
      _selectedTimes.length,
      (index) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8.0),
        child: GestureDetector(
          onTap: () async {
            final picked = await showStyledTimePicker(
              context: context,
              initialTime: _selectedTimes[index],
            );
            if (picked != null) {
              setState(() {
                _selectedTimes[index] = picked;
              });
            }
          },
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: 'Reminder ${index + 1} Time',
              prefixIcon: const Padding(
                padding: EdgeInsets.all(15),
                child: Text('⏱️', style: TextStyle(fontSize: 24)),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide:
                    BorderSide(color: Theme.of(context).primaryColorDark),
              ),
            ),
            child: Text(
              _selectedTimes[index].format(context),
              style: TextStyle(
                color: Theme.of(context).primaryColorDark,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
