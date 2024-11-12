import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/helpers/others/generate_unique_id.dart';
import 'package:pet_diary/src/helpers/others/show_styled_date_picker.dart';
import 'package:pet_diary/src/helpers/others/show_styled_time_picker.dart';
import 'package:pet_diary/src/models/events_models/event_medicine_model.dart';
import 'package:pet_diary/src/models/events_models/event_model.dart';
import 'package:pet_diary/src/models/reminder_models/reminder_model.dart';
import 'package:pet_diary/src/providers/events_providers/event_medicine_provider.dart';
import 'package:pet_diary/src/providers/events_providers/event_provider.dart';
import 'package:pet_diary/src/providers/others_providers/user_provider.dart';
import 'package:pet_diary/src/providers/reminder_providers/reminder_providers.dart';
import 'package:pet_diary/src/services/other_services/notification_services.dart';

/// A screen that allows users to add a new medicine.
///
/// This screen is a stateful widget that provides a form for users to input
/// details about a new medicine they want to add to their list.
///
/// The form includes fields for the medicine name, dosage, frequency, and
/// other relevant information. Once the form is filled out, users can submit
/// it to save the new medicine.
class AddMedicineScreen extends StatefulWidget {
  final WidgetRef ref;
  final String petId;

  const AddMedicineScreen({super.key, required this.ref, required this.petId});

  @override
  createState() => _AddMedicineScreenState();
}

class _AddMedicineScreenState extends State<AddMedicineScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _dosageController;
  late TextEditingController _startDateController;
  late TextEditingController _endDateController;
  late TextEditingController _intervalController;

  DateTime _selectedStartDate = DateTime.now();
  DateTime _selectedEndDate = DateTime.now();
  String _selectedTypeEmoji = '💊';
  String _selectedTypeName = 'Tablet';
  String _selectedUnit = 'mg';
  String _selectedSchedule = 'Daily';
  int _frequency = 0;

  final Map<String, bool> _daysOfWeek = {
    'Monday': false,
    'Tuesday': false,
    'Wednesday': false,
    'Thursday': false,
    'Friday': false,
    'Saturday': false,
    'Sunday': false,
  };

  final List<TimeOfDay> _selectedTimes = [];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _dosageController = TextEditingController();
    _startDateController = TextEditingController();
    _endDateController = TextEditingController();
    _intervalController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    _intervalController.dispose();
    super.dispose();
  }

  void _incrementFrequency() {
    setState(() {
      _frequency++;
      _updateDoses();
    });
  }

  void _decrementFrequency() {
    if (_frequency > 0) {
      setState(() {
        _frequency--;
        _updateDoses();
      });
    }
  }

  void _updateDoses() {
    setState(() {
      while (_selectedTimes.length < _frequency) {
        _selectedTimes.add(const TimeOfDay(hour: 8, minute: 0));
      }
      while (_selectedTimes.length > _frequency) {
        _selectedTimes.removeLast();
      }
    });
  }

  void _cycleType() {
    const List<Map<String, String>> typeOptions = [
      {'emoji': '💊', 'name': 'Tablet'},
      {'emoji': '💉', 'name': 'Injection'},
      {'emoji': '🧴', 'name': 'Cream'},
      {'emoji': '🩹', 'name': 'Patch'},
      {'emoji': '🧪', 'name': 'Liquid'},
      {'emoji': '💧', 'name': 'Drops'},
    ];

    final currentIndex =
        typeOptions.indexWhere((type) => type['emoji'] == _selectedTypeEmoji);
    final nextIndex = (currentIndex + 1) % typeOptions.length;

    setState(() {
      _selectedTypeEmoji = typeOptions[nextIndex]['emoji']!;
      _selectedTypeName = typeOptions[nextIndex]['name']!;
    });
  }

  void _saveMedicine() async {
    // Anulowanie wszystkich powiadomień przed stworzeniem nowych
    await NotificationService().cancelAllNotifications();

    if (_formKey.currentState?.validate() ?? false) {
      String scheduleDetails;
      if (_selectedSchedule == 'Every X Days' ||
          _selectedSchedule == 'Every X Weeks' ||
          _selectedSchedule == 'Every X Months') {
        scheduleDetails = '${_intervalController.text} $_selectedSchedule';
      } else if (_selectedSchedule == 'Selected Days of the Week') {
        scheduleDetails = _daysOfWeek.entries
            .where((entry) => entry.value)
            .map((entry) => entry.key)
            .join(', ');
      } else {
        scheduleDetails = _selectedSchedule;
      }

      List<TimeOfDay> times = List.from(_selectedTimes);
      String medicineId = generateUniqueId();
      final newMedicine = EventMedicineModel(
        id: medicineId,
        name: _nameController.text,
        petId: widget.petId,
        eventId: generateUniqueId(),
        frequency: _frequency.toString(),
        dosage: _dosageController.text.isNotEmpty
            ? '${_dosageController.text} $_selectedUnit'
            : null,
        emoji: _selectedTypeEmoji,
        startDate: _selectedStartDate,
        endDate: _selectedEndDate,
        remindersEnabled: true,
        scheduleDetails: scheduleDetails,
        medicineType: _selectedTypeName,
        times: times,
      );

      List<Event> events = [];
      Set<int> uniqueNotificationIds = {};
      List<ReminderModel> reminders = [];
      final totalDays =
          _selectedEndDate.difference(_selectedStartDate).inDays + 1;

      if (kDebugMode) {
        print(
            'Starting reminder creation for medicine: ${newMedicine.name} with $totalDays days');
      }

      for (int dayOffset = 0; dayOffset < totalDays; dayOffset++) {
        final day = _selectedStartDate.add(Duration(days: dayOffset));
        int daysLeft = _selectedEndDate.difference(day).inDays + 1;

        if (_shouldScheduleOnDay(day)) {
          for (var time in _selectedTimes) {
            DateTime eventDateTime =
                DateTime(day.year, day.month, day.day, time.hour, time.minute);

            if (kDebugMode) {
              print(
                  'Creating event on ${DateFormat('yyyy-MM-dd HH:mm').format(eventDateTime)} for ${newMedicine.name}, days left: $daysLeft');
            }

            events.add(Event(
              id: generateUniqueId(),
              title: 'Medicine: ${newMedicine.name}',
              eventDate: eventDateTime,
              dateWhenEventAdded: DateTime.now(),
              userId: widget.ref.read(userIdProvider)!,
              petId: widget.petId,
              pillId: newMedicine.id,
              description:
                  '${newMedicine.name} - ${eventDateTime.hour}:${eventDateTime.minute}',
              avatarImage: 'assets/images/pill_avatar.png',
              emoticon: _selectedTypeEmoji,
            ));

            // Używamy dayOffset, aby zapewnić unikalność ID
            int notificationId =
                ('${medicineId.hashCode}${eventDateTime.millisecondsSinceEpoch % 1000000}$dayOffset')
                    .hashCode;

            if (!uniqueNotificationIds.contains(notificationId)) {
              uniqueNotificationIds.add(notificationId);

              String title = 'Reminder: ${newMedicine.name}';
              String body = _dosageController.text.isNotEmpty
                  ? 'It’s time to take ${_dosageController.text} $_selectedUnit of ${newMedicine.name}. $daysLeft days left.'
                  : 'It’s time to take your medication: ${newMedicine.name}. $daysLeft days left.';

              if (kDebugMode) {
                print(
                    'Creating notification with ID $notificationId on ${DateFormat('yyyy-MM-dd HH:mm').format(eventDateTime)}, days left: $daysLeft');
              }

              await NotificationService().createNotification(
                id: notificationId,
                title: title,
                body: body,
                scheduledDate: eventDateTime,
              );

              final reminder = ReminderModel(
                id: generateUniqueId(),
                name: newMedicine.name,
                petId: widget.petId,
                userId: widget.ref.read(userIdProvider)!,
                scheduledDate: eventDateTime,
                emoji: _selectedTypeEmoji,
                description: body,
                eventId: newMedicine.id,
                isActive: true,
                notificationId: notificationId,
              );
              reminders.add(reminder);
            } else {
              if (kDebugMode) {
                print(
                    'Skipped duplicate notification for time ${DateFormat('yyyy-MM-dd HH:mm').format(eventDateTime)}');
              }
            }
          }
        }
      }

      await widget.ref
          .read(eventMedicineServiceProvider)
          .addMedicine(newMedicine);
      for (var event in events) {
        await widget.ref
            .read(eventServiceProvider)
            .addEvent(event, widget.petId);
      }

      for (var reminder in reminders) {
        await widget.ref.read(reminderServiceProvider).addReminder(reminder);
      }

      if (kDebugMode) {
        print('Reminder creation completed.');
      }

      // ignore: use_build_context_synchronously
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'A D D  M E D I C I N E',
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
              _buildEmojiAndType(),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: _buildContainer([
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    child: _buildTextInput(
                        _nameController, 'Medicine Name', '🏷️'),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildDateInput(
                            context,
                            _startDateController,
                            'Start Date',
                            '📆',
                            (DateTime date) {
                              setState(() {
                                _selectedStartDate = date;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildDateInput(
                            context,
                            _endDateController,
                            'End Date',
                            '📅',
                            (DateTime date) {
                              setState(() {
                                _selectedEndDate = date;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    child: _buildTextInput(_dosageController, 'Dosage', '⚖️'),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    child: _buildDropdownInput(
                        label: 'Unit',
                        items: ['mg', 'ml', 'g', 'mcg', 'Unit'],
                        selectedValue: _selectedUnit,
                        onChanged: (value) {
                          setState(() {
                            _selectedUnit = value!;
                          });
                        },
                        emoji: '🔢'),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    child: _buildDropdownInput(
                        label: 'Schedule',
                        items: [
                          'Daily',
                          'Every X Days',
                          'Every X Weeks',
                          'Every X Months',
                          'Selected Days of the Week'
                        ],
                        selectedValue: _selectedSchedule,
                        onChanged: (value) {
                          setState(() {
                            _selectedSchedule = value!;
                          });
                        },
                        emoji: '🗓️'),
                  ),
                  const SizedBox(height: 10),
                  if (_selectedSchedule == 'Every X Days' ||
                      _selectedSchedule == 'Every X Weeks' ||
                      _selectedSchedule == 'Every X Months')
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15.0, vertical: 10.0),
                      child: _buildTextInput(
                          _intervalController, 'Interval', '🕒'),
                    ),
                  if (_selectedSchedule == 'Selected Days of the Week')
                    Padding(
                      padding: const EdgeInsets.only(bottom: 15.0),
                      child: _buildDaysOfWeekSelector(),
                    ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    child: _buildFrequencyInput(),
                  ),
                  const SizedBox(height: 10),
                  ..._buildTimeSelectors(),
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
          onPressed: _saveMedicine,
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
            padding: const EdgeInsets.all(12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            'S A V E  M E D I C I N E',
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

  Widget _buildEmojiAndType() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(22),
          bottomRight: Radius.circular(22),
        ),
      ),
      child: Column(
        children: [
          Divider(
            color: Theme.of(context).colorScheme.surface,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 40.0),
                  child: GestureDetector(
                    onTap: _cycleType,
                    child: CircleAvatar(
                      radius: 35,
                      child: Text(_selectedTypeEmoji,
                          style: const TextStyle(fontSize: 35)),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 40.0),
                  child: GestureDetector(
                    onTap: _cycleType,
                    child: Text(
                      _selectedTypeName,
                      style: TextStyle(
                        fontSize: 18,
                        color: Theme.of(context).primaryColorDark,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFrequencyInput() {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: 'Frequency (optional)',
        labelStyle: TextStyle(color: Theme.of(context).primaryColorDark),
        prefixIcon: const Padding(
          padding: EdgeInsets.only(left: 12, top: 2),
          child: Text('⏰', style: TextStyle(fontSize: 30)),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Theme.of(context).primaryColorDark),
        ),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          GestureDetector(
            onTap: _decrementFrequency,
            child: Icon(
              Icons.remove,
              size: 25,
              color: Theme.of(context).primaryColorDark,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18.0),
            child: Text(
              '$_frequency',
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).primaryColorDark,
              ),
            ),
          ),
          GestureDetector(
            onTap: _incrementFrequency,
            child: Icon(
              Icons.add,
              size: 25,
              color: Theme.of(context).primaryColorDark,
            ),
          ),
        ],
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
            final TimeOfDay? picked = await showStyledTimePicker(
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
              labelText: 'Dose ${index + 1} Time',
              labelStyle: TextStyle(color: Theme.of(context).primaryColorDark),
              prefixIcon: const Padding(
                padding: EdgeInsets.all(15),
                child: Text('🔔', style: TextStyle(fontSize: 30)),
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
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
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
    TextEditingController controller,
    String label,
    String emoji, {
    Function(String)? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Theme.of(context).primaryColorDark),
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 12, right: 20),
          child: Text(emoji, style: const TextStyle(fontSize: 30)),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Theme.of(context).primaryColorDark),
        ),
      ),
      style: TextStyle(fontSize: 14, color: Theme.of(context).primaryColorDark),
      validator: (value) =>
          value == null || value.isEmpty ? 'Please enter $label' : null,
      onChanged: onChanged,
    );
  }

  Widget _buildDateInput(
    BuildContext context,
    TextEditingController controller,
    String label,
    String emoji,
    Function(DateTime) onDateSelected,
  ) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      onTap: () async {
        final DateTime? pickedDate = await showStyledDatePicker(
          context: context,
          initialDate: _selectedStartDate,
          lastDate: DateTime(2100),
          firstDate: DateTime(2000),
        );
        if (pickedDate != null) {
          setState(() {
            controller.text = DateFormat('dd/MM/yyyy').format(pickedDate);
            onDateSelected(pickedDate);
          });
        }
      },
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Theme.of(context).primaryColorDark),
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 12, right: 20, top: 2),
          child: Text(emoji, style: const TextStyle(fontSize: 30)),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Theme.of(context).primaryColorDark),
        ),
      ),
      style: TextStyle(fontSize: 14, color: Theme.of(context).primaryColorDark),
    );
  }

  Widget _buildDropdownInput({
    required String label,
    required List<String> items,
    required String selectedValue,
    required ValueChanged<String?> onChanged,
    required String emoji,
  }) {
    return DropdownButtonFormField<String>(
      value: selectedValue,
      items: items
          .map((item) => DropdownMenuItem(value: item, child: Text(item)))
          .toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Theme.of(context).primaryColorDark),
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 12, right: 20, top: 4),
          child: Text(emoji, style: const TextStyle(fontSize: 30)),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Theme.of(context).primaryColorDark),
        ),
      ),
      style: TextStyle(fontSize: 14, color: Theme.of(context).primaryColorDark),
    );
  }

  Widget _buildDaysOfWeekSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      child: Wrap(
        spacing: 8.0,
        runSpacing: 4.0,
        children: _daysOfWeek.keys.map((String day) {
          final isSelected = _daysOfWeek[day] ?? false;
          return ChoiceChip(
            label: Text(
              day,
              style: TextStyle(
                color: isSelected
                    ? Theme.of(context).primaryColorDark
                    : Theme.of(context).primaryColorLight,
              ),
            ),
            selected: isSelected,
            selectedColor: Theme.of(context).colorScheme.secondary,
            backgroundColor: Theme.of(context).colorScheme.surface,
            onSelected: (bool selected) {
              setState(() {
                _daysOfWeek[day] = selected;
              });
            },
          );
        }).toList(),
      ),
    );
  }

  bool _shouldScheduleOnDay(DateTime day) {
    if (_selectedSchedule == 'Daily') return true;
    if (_selectedSchedule == 'Every X Days') {
      final interval = int.tryParse(_intervalController.text) ?? 1;
      return day.difference(_selectedStartDate).inDays % interval == 0;
    } else if (_selectedSchedule == 'Every X Weeks') {
      final interval = int.tryParse(_intervalController.text) ?? 1;
      return day.difference(_selectedStartDate).inDays ~/ 7 % interval == 0;
    } else if (_selectedSchedule == 'Every X Months') {
      final interval = int.tryParse(_intervalController.text) ?? 1;
      return (day.month -
                  _selectedStartDate.month +
                  (day.year - _selectedStartDate.year) * 12) %
              interval ==
          0;
    } else if (_selectedSchedule == 'Selected Days of the Week') {
      final dayName = DateFormat('EEEE').format(day);
      return _daysOfWeek[dayName] ?? false;
    }
    return false;
  }
}
