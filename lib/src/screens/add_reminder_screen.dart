import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pet_diary/src/helper/generate_unique_id.dart';
import 'package:pet_diary/src/models/event_reminder_model.dart';
import 'package:pet_diary/src/models/pet_model.dart';
import 'package:pet_diary/src/providers/event_reminder_provider.dart';
import 'package:pet_diary/src/models/event_model.dart';
import 'package:pet_diary/src/providers/event_provider.dart';
import 'package:pet_diary/src/providers/pet_provider.dart';
import 'package:pet_diary/src/services/notification_services.dart';

class AddReminderScreen extends ConsumerStatefulWidget {
  final String petId;

  const AddReminderScreen({super.key, required this.petId});

  @override
  createState() => _AddReminderScreenState();
}

class _AddReminderScreenState extends ConsumerState<AddReminderScreen> {
  late TextEditingController nameController;
  late TextEditingController descriptionController;
  late TextEditingController intervalController;
  late TimeOfDay selectedTime;
  late DateTime selectedDate;
  String repeatOption = 'Once';
  List<int> selectedDays = [];
  DateTime? endDate;
  List<String> selectedPets = [];

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    descriptionController = TextEditingController();
    intervalController = TextEditingController();
    selectedTime = TimeOfDay.now();
    selectedDate = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    final asyncPets = ref.watch(petsProvider);

    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: AppBar(
          iconTheme: IconThemeData(
              color: Theme.of(context).primaryColorDark, size: 20),
          title: Text(
            'N E W  R E M I N D E R',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColorDark,
            ),
          ),
          backgroundColor: Theme.of(context).colorScheme.primary,
          toolbarHeight: 50,
          actions: [
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: () => _saveReminder(),
              color: Theme.of(context).primaryColorDark,
              iconSize: 20,
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTextField('Name', nameController, isRequired: true),
                  const Divider(color: Colors.grey, thickness: 1, height: 20),
                  _buildTimePicker(context),
                  const Divider(color: Colors.grey, thickness: 1, height: 20),
                  _buildDatePicker(context, 'Date', selectedDate, _selectDate),
                  const Divider(color: Colors.grey, thickness: 1, height: 20),
                  _buildPetsSelection(asyncPets),
                  const Divider(color: Colors.grey, thickness: 1, height: 20),
                  _buildRepeatOption(),
                  if (repeatOption == 'Every x days' ||
                      repeatOption == 'Every x months' ||
                      repeatOption == 'Every x years') ...[
                    const Divider(color: Colors.grey, thickness: 1, height: 20),
                    _buildTextField('Interval', intervalController),
                  ],
                  const Divider(color: Colors.grey, thickness: 1, height: 20),
                  _buildTextField('Description', descriptionController),
                ],
              ),
            ),
          ),
        ));
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {bool isRequired = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 5),
        SizedBox(
          height: 60,
          width: double.infinity,
          child: TextFormField(
            controller: controller,
            decoration: InputDecoration(
              labelText: controller.text.isNotEmpty
                  ? null
                  : isRequired
                      ? 'Required'
                      : 'Optional',
              labelStyle: const TextStyle(fontSize: 12),
              focusedBorder: OutlineInputBorder(
                borderSide:
                    const BorderSide(color: Color(0xffdfd785), width: 2.0),
                borderRadius: BorderRadius.circular(5.0),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.black, width: 1.0),
                borderRadius: BorderRadius.circular(5.0),
              ),
            ),
            onChanged: (value) {
              setState(() {});
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTimePicker(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Time',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 5),
        GestureDetector(
          onTap: () => _selectTime(context),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              children: [
                const Icon(Icons.access_time),
                const SizedBox(width: 10),
                Text(
                  '${selectedTime.hour}:${selectedTime.minute}',
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDatePicker(BuildContext context, String label, DateTime date,
      Function(BuildContext) selectDate) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 5),
        GestureDetector(
          onTap: () => selectDate(context),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today),
                const SizedBox(width: 10),
                Text(
                  '${date.day}-${date.month}-${date.year}',
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPetsSelection(AsyncValue<List<Pet>> asyncPets) {
    return asyncPets.when(
      loading: () => const CircularProgressIndicator(),
      error: (err, stack) => Text('Error: $err'),
      data: (pets) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Pets',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: pets.map((pet) {
                final isSelected = selectedPets.contains(pet.id);
                return ChoiceChip(
                  avatar: CircleAvatar(
                    backgroundImage: AssetImage(pet.avatarImage),
                  ),
                  label: Text(pet.name),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        selectedPets.add(pet.id);
                      } else {
                        selectedPets.remove(pet.id);
                      }
                    });
                  },
                );
              }).toList(),
            ),
          ],
        );
      },
    );
  }

  Widget _buildRepeatOption() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Repeat',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 5),
        SwitchListTile(
          title: const Text('Repeat Reminder'),
          value: repeatOption != 'Once',
          onChanged: (bool value) {
            setState(() {
              repeatOption = value ? 'Daily' : 'Once';
              if (repeatOption != 'Once') {
                _selectEndDate(context);
              } else {
                endDate = null;
              }
            });
          },
        ),
        if (repeatOption != 'Once')
          DropdownButton<String>(
            value: repeatOption,
            onChanged: (String? newValue) {
              setState(() {
                repeatOption = newValue!;
              });
            },
            items: <String>[
              'Daily',
              'Weekly',
              'Every x days',
              'Every x months',
              'Every x years'
            ].map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
      ],
    );
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: Theme(
            data: ThemeData(
              textTheme: const TextTheme(
                bodyLarge: TextStyle(color: Colors.black),
              ),
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.black,
                ),
              ),
              colorScheme: const ColorScheme.light(
                primary: Color(0xffdfd785),
                onPrimary: Colors.black,
              ),
            ),
            child: child!,
          ),
        );
      },
    );

    if (picked != null && picked != selectedTime) {
      setState(() {
        selectedTime = picked;
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: endDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );

    if (picked != null && picked != endDate) {
      setState(() {
        endDate = picked;
      });
    }
  }

  Future<void> _saveReminder() async {
    if (nameController.text.isEmpty || selectedPets.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields.')),
      );
      return;
    }

    final String title = nameController.text;
    final String description = descriptionController.text;
    final String userId = FirebaseAuth.instance.currentUser!.uid;
    final String objectId = generateUniqueId();

    final DateTime scheduledDate = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      selectedTime.hour,
      selectedTime.minute,
    );

    final EventReminderModel newReminder = EventReminderModel(
      id: generateUniqueId(),
      time: selectedTime,
      userId: userId,
      objectId: objectId,
      title: title,
      description: description,
      selectedDays: selectedDays,
      repeatOption: repeatOption,
      dateTime: scheduledDate,
      endDate: endDate ??
          DateTime.now()
              .add(Duration(days: 1)), // Default endDate if not provided
    );

    await ref.read(eventReminderServiceProvider).addReminder(newReminder);

    await NotificationService().scheduleNotification(
      id: int.parse(objectId.substring(0, 9)),
      title: title,
      body: description,
      scheduledDate: scheduledDate,
      repeatOption: repeatOption,
      endDate: endDate,
    );

    final String eventId = generateUniqueId();
    final Event newEvent = Event(
      id: eventId,
      title: title,
      eventDate: selectedDate,
      dateWhenEventAdded: DateTime.now(),
      userId: userId,
      petId: widget.petId,
      weightId: '',
      temperatureId: '',
      walkId: '',
      waterId: '',
      noteId: '',
      pillId: '',
      moodId: '',
      stomachId: '',
      description: description,
      proffesionId: 'BRAK',
      personId: 'BRAK',
      avatarImage: 'assets/images/dog_avatar_014.png',
      emoticon: '🔔',
      psychicId: '',
      stoolId: '',
      urineId: '',
      serviceId: '',
      careId: '',
    );

    await ref.read(eventServiceProvider).addEvent(newEvent);

    Navigator.of(context).pop();
  }
}
