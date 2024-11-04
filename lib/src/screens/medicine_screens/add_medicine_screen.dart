import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/helpers/others/generate_unique_id.dart';
import 'package:pet_diary/src/helpers/others/show_styled_date_picker.dart';
import 'package:pet_diary/src/helpers/others/show_styled_time_picker.dart';
import 'package:pet_diary/src/models/events_models/event_medicine_model.dart';
import 'package:pet_diary/src/models/events_models/event_model.dart';
import 'package:pet_diary/src/providers/events_providers/event_medicine_provider.dart';
import 'package:pet_diary/src/providers/events_providers/event_provider.dart';
import 'package:pet_diary/src/services/other_services/notification_services.dart';

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
  late TextEditingController _startDateController;
  late TextEditingController _endDateController;
  late TextEditingController _frequencyController;
  late TextEditingController _intervalController;

  DateTime _selectedStartDate = DateTime.now();
  DateTime? _selectedEndDate;
  String _selectedEmoji = '💊';
  String _selectedUnit = 'mg';
  String _selectedType = 'Capsule';
  String _selectedSchedule = 'Daily';
  final Map<String, bool> _daysOfWeek = {
    'Monday': false,
    'Tuesday': false,
    'Wednesday': false,
    'Thursday': false,
    'Friday': false,
    'Saturday': false,
    'Sunday': false,
  };

  final List<TimeOfDay> _selectedTimes = [const TimeOfDay(hour: 8, minute: 0)];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _startDateController = TextEditingController();
    _endDateController = TextEditingController();
    _frequencyController = TextEditingController();
    _intervalController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    _frequencyController.dispose();
    _intervalController.dispose();
    super.dispose();
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Empty Fields',
            style: TextStyle(color: Theme.of(context).primaryColorDark),
          ),
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
        );
      },
    );
  }

  void _saveMedicine() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (_selectedEndDate == null) {
        _showErrorDialog('End date must be set before saving.');
        return;
      }

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
        frequency: _frequencyController.text,
        dosage: '${_frequencyController.text} $_selectedUnit',
        emoji: _selectedEmoji,
        startDate: _selectedStartDate,
        endDate: _selectedEndDate!,
        remindersEnabled: true,
        scheduleDetails: scheduleDetails,
        medicineType: _selectedType,
        times: times,
      );

      List<Event> events = [];
      Set<int> uniqueNotificationIds =
          {}; // Set do przechowywania unikalnych identyfikatorów powiadomień

      final totalDays =
          _selectedEndDate!.difference(_selectedStartDate).inDays + 1;

      // Iterujemy przez każdy dzień w okresie leczenia
      for (int dayOffset = 0; dayOffset < totalDays; dayOffset++) {
        final day = _selectedStartDate.add(Duration(days: dayOffset));

        if (_shouldScheduleOnDay(day)) {
          for (var time in _selectedTimes) {
            DateTime eventDateTime =
                DateTime(day.year, day.month, day.day, time.hour, time.minute);
            events.add(Event(
              id: generateUniqueId(),
              title: 'Medicine: ${newMedicine.name}',
              eventDate: eventDateTime,
              dateWhenEventAdded: DateTime.now(),
              userId: FirebaseAuth.instance.currentUser!.uid,
              petId: widget.petId,
              pillId: newMedicine.id,
              description:
                  '${newMedicine.name} - ${eventDateTime.hour}:${eventDateTime.minute}',
              avatarImage: 'assets/images/pill_avatar.png',
              emoticon: _selectedEmoji,
            ));

            // Generowanie ID na podstawie samej godziny
            int notificationId = time.hashCode;
            if (!uniqueNotificationIds.contains(notificationId)) {
              uniqueNotificationIds.add(notificationId);
              await NotificationService().createNotification(
                id: notificationId, // Używamy unikalnego ID na podstawie godziny
                title: 'Przypomnienie o leku',
                body: 'Czas na lek: ${newMedicine.name}',
                scheduledDate: eventDateTime,
              );
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

      // ignore: use_build_context_synchronously
      Navigator.of(context).pop();
    }
  }

  int generateUniqueIdForNotification(DateTime day, TimeOfDay time) {
    // Funkcja pomocnicza do tworzenia unikalnego ID powiadomienia na podstawie dnia i godziny
    return DateTime(day.year, day.month, day.day, time.hour, time.minute)
            .millisecondsSinceEpoch %
        2147483647;
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
              _buildEmojiAndUnit(),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: _buildContainer([
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    child:
                        _buildTextInput(_nameController, 'Medicine Name', '💊'),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    child: _buildDateInput(
                        context, _startDateController, 'Start Date',
                        (DateTime date) {
                      setState(() {
                        _selectedStartDate = date;
                      });
                    }),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    child:
                        _buildDateInput(context, _endDateController, 'End Date',
                            (DateTime date) {
                      setState(() {
                        _selectedEndDate = date;
                      });
                    }),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    child: _buildDropdownInput(
                      label: 'Type',
                      items: [
                        'Capsule',
                        'Tablet',
                        'Liquid',
                        'Aerosol',
                        'Suppository',
                        'Inhaler',
                        'Cream',
                        'Drops',
                        'Ointment',
                        'Foam',
                        'Injection',
                        'Other'
                      ],
                      selectedValue: _selectedType,
                      onChanged: (value) {
                        setState(() {
                          _selectedType = value!;
                        });
                      },
                    ),
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
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (_selectedSchedule == 'Every X Days' ||
                      _selectedSchedule == 'Every X Weeks' ||
                      _selectedSchedule == 'Every X Months')
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15.0, vertical: 10.0),
                      child:
                          _buildTextInput(_intervalController, 'Interval', '⏳'),
                    ),
                  if (_selectedSchedule == 'Selected Days of the Week')
                    _buildDaysOfWeekSelector(),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    child: _buildTextInput(
                      _frequencyController,
                      'Frequency',
                      '⏰',
                      onChanged: (value) {
                        int frequency = int.tryParse(value) ?? 1;
                        if (frequency > 12) {
                          _showErrorDialog('Maximum 12 doses allowed per day');
                          frequency = 12;
                        }
                        _updateDoses(frequency);
                      },
                    ),
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

  void _updateDoses(int frequency) {
    setState(() {
      while (_selectedTimes.length < frequency) {
        _selectedTimes.add(const TimeOfDay(hour: 8, minute: 0));
      }
      while (_selectedTimes.length > frequency) {
        _selectedTimes.removeLast();
      }
    });
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

  Widget _buildContainer(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildEmojiAndUnit() {
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
          Divider(color: Theme.of(context).colorScheme.secondary),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              GestureDetector(
                onTap: () {
                  const emojis = ['💊', '💉', '🩹', '🧴', '⚕️', '🧪'];
                  setState(() {
                    _selectedEmoji = emojis[
                        (emojis.indexOf(_selectedEmoji) + 1) % emojis.length];
                  });
                },
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 35,
                      child: Text(_selectedEmoji,
                          style: const TextStyle(fontSize: 35)),
                    ),
                    Text(
                      'Emoji',
                      style:
                          TextStyle(color: Theme.of(context).primaryColorDark),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedUnit = _selectedUnit == 'mg' ? 'ml' : 'mg';
                  });
                },
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: Text(
                        _selectedUnit,
                        style: TextStyle(
                            fontSize: 30,
                            color: Theme.of(context).primaryColorDark),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: Text(
                        'Unit',
                        style: TextStyle(
                            color: Theme.of(context).primaryColorDark),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
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

  Widget _buildDateInput(
    BuildContext context,
    TextEditingController controller,
    String label,
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
    );
  }

  Widget _buildDropdownInput({
    required String label,
    required List<String> items,
    required String selectedValue,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: selectedValue,
      items: items
          .map((item) => DropdownMenuItem(value: item, child: Text(item)))
          .toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Padding(
          padding: EdgeInsets.only(left: 12, right: 20),
          child: Text('📦', style: TextStyle(fontSize: 35)),
        ),
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
}
