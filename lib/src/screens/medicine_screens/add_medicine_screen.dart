import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pet_diary/src/helpers/others/generate_unique_id.dart';
import 'package:pet_diary/src/helpers/others/show_styled_date_picker.dart';
import 'package:pet_diary/src/models/events_models/event_medicine_model.dart';
import 'package:pet_diary/src/models/events_models/event_model.dart';
import 'package:pet_diary/src/providers/events_providers/event_medicine_provider.dart';
import 'package:pet_diary/src/providers/events_providers/event_provider.dart';

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
  late TextEditingController _scheduleDetailsController;

  DateTime _selectedStartDate = DateTime.now();
  DateTime? _selectedEndDate;
  String _selectedEmoji = '💊';
  String _selectedUnit = 'mg';
  String _selectedType = 'Capsule';
  String _selectedSchedule = 'Daily';
  Map<String, bool> _daysOfWeek = {
    'Monday': false,
    'Tuesday': false,
    'Wednesday': false,
    'Thursday': false,
    'Friday': false,
    'Saturday': false,
    'Sunday': false,
  };
  final List<String> _emojis = [
    '💊',
    '💉',
    '🧴',
    '🩹',
    '💧',
    '🧪',
    '🧬',
    '💡',
    '🍎',
    '🥑',
    '🧃',
    '🌟',
    '❤️',
    '🌼',
    '🐾',
    '⚡️',
    '🌀',
    '💥',
    '☕️',
    '🌿'
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _startDateController = TextEditingController();
    _endDateController = TextEditingController();
    _frequencyController = TextEditingController();
    _scheduleDetailsController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    _frequencyController.dispose();
    _scheduleDetailsController.dispose();
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
      String eventId = generateUniqueId();
      String medicineId = generateUniqueId();

      final newMedicine = EventMedicineModel(
        id: medicineId,
        name: _nameController.text,
        petId: widget.petId,
        eventId: eventId,
        frequency: _frequencyController.text,
        dosage: '${_frequencyController.text} $_selectedUnit',
        emoji: _selectedEmoji,
        startDate: _selectedStartDate,
        endDate: _selectedEndDate!,
        remindersEnabled: false,
        scheduleDetails: _scheduleDetailsController.text,
        medicineType: _selectedType,
      );

      final newEvent = Event(
        id: eventId,
        title: 'Medicine',
        eventDate: _selectedStartDate,
        dateWhenEventAdded: DateTime.now(),
        userId: FirebaseAuth.instance.currentUser!.uid,
        petId: widget.petId,
        pillId: newMedicine.id,
        description: '${newMedicine.name}, ${newMedicine.scheduleDetails}',
        avatarImage: 'assets/images/pill_avatar.png',
        emoticon: _selectedEmoji,
      );

      await widget.ref
          .read(eventMedicineServiceProvider)
          .addMedicine(newMedicine);
      await widget.ref
          .read(eventServiceProvider)
          .addEvent(newEvent, widget.petId);

      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'N E W  M E D I C I N E',
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
                  if (_selectedSchedule == 'Selected Days of the Week')
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15.0),
                      child: Column(
                        children: _daysOfWeek.keys.map((String day) {
                          return CheckboxListTile(
                            title: Text(day),
                            value: _daysOfWeek[day],
                            onChanged: (bool? value) {
                              setState(() {
                                _daysOfWeek[day] = value!;
                              });
                            },
                            activeColor:
                                Theme.of(context).colorScheme.secondary,
                            checkColor: Theme.of(context).primaryColorDark,
                            side: BorderSide(
                              color: Theme.of(context).primaryColorDark,
                              width: 1.5,
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  if (_selectedSchedule == 'Every X Days' ||
                      _selectedSchedule == 'Every X Weeks' ||
                      _selectedSchedule == 'Every X Months')
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15.0),
                      child: _buildTextInput(_scheduleDetailsController,
                          'Interval (e.g., X = days/weeks/months)', '🔄'),
                    ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    child:
                        _buildTextInput(_frequencyController, 'Frequency', '⏰'),
                  ),
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
            padding: const EdgeInsets.all(15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            'Save Medicine',
            style: TextStyle(
              color: Theme.of(context).primaryColorDark,
              fontSize: 18,
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
                onTap: () => _selectEmoji(context),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 35,
                      child: Text(_selectedEmoji,
                          style: const TextStyle(fontSize: 35)),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Emoji',
                      style:
                          TextStyle(color: Theme.of(context).primaryColorDark),
                    ),
                    const SizedBox(height: 8),
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
                    Text(
                      _selectedUnit,
                      style: TextStyle(
                          fontSize: 30,
                          color: Theme.of(context).primaryColorDark),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Unit',
                      style:
                          TextStyle(color: Theme.of(context).primaryColorDark),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _selectEmoji(BuildContext context) async {
    String? selectedEmoji = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Emoji'),
          content: Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: _emojis.map((emoji) {
              return GestureDetector(
                onTap: () => Navigator.of(context).pop(emoji),
                child: CircleAvatar(
                  child: Text(emoji, style: const TextStyle(fontSize: 25)),
                ),
              );
            }).toList(),
          ),
        );
      },
    );

    if (selectedEmoji != null) {
      setState(() {
        _selectedEmoji = selectedEmoji;
      });
    }
  }

  Widget _buildTextInput(
      TextEditingController controller, String label, String emoji) {
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
    );
  }

  Widget _buildDateInput(BuildContext context, TextEditingController controller,
      String label, Function(DateTime) onDateSelected) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      onTap: () async {
        final DateTime? pickedDate = await showStyledDatePicker(
          context: context,
          initialDate: _selectedStartDate,
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
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
}
