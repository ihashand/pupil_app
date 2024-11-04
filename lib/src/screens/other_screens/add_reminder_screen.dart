import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pet_diary/src/helpers/others/generate_unique_id.dart';
import 'package:pet_diary/src/models/events_models/event_reminder_model.dart';
import 'package:pet_diary/src/models/others/pet_model.dart';
import 'package:pet_diary/src/providers/events_providers/event_reminder_provider.dart';
import 'package:pet_diary/src/models/events_models/event_model.dart';
import 'package:pet_diary/src/providers/events_providers/event_provider.dart';
import 'package:pet_diary/src/providers/others_providers/pet_provider.dart';

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
          color: Theme.of(context).primaryColorDark,
          size: 20,
        ),
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
                _buildTextFieldReminder('Name', nameController,
                    isRequired: true, maxLenght: 27),
                Divider(
                    color: Theme.of(context).colorScheme.secondary,
                    thickness: 1,
                    height: 20),
                _buildTimePickerReminders(context),
                Divider(
                    color: Theme.of(context).colorScheme.secondary,
                    thickness: 1,
                    height: 20),
                _buildDatePickerReminders(
                    context, 'Date', selectedDate, _selectDate),
                Divider(
                    color: Theme.of(context).colorScheme.secondary,
                    thickness: 1,
                    height: 20),
                _buildPetsSelection(asyncPets),
                Divider(
                    color: Theme.of(context).colorScheme.secondary,
                    thickness: 1,
                    height: 20),
                const Text(
                  'Repeat',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Turn on repeats"),
                    Switch(
                      activeTrackColor: Theme.of(context).colorScheme.secondary,
                      value: repeatOption != 'Once',
                      onChanged: (bool value) {
                        setState(() {
                          repeatOption = value ? 'Daily' : 'Once';
                        });
                      },
                    ),
                  ],
                ),
                if (repeatOption != 'Once')
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DropdownButton<String>(
                        value: repeatOption,
                        onChanged: (String? newValue) {
                          setState(() {
                            repeatOption = newValue!;
                          });
                        },
                        isExpanded: true,
                        items: <String>[
                          'Daily',
                          'Weekly',
                          'Every x days',
                          'Every x months',
                          'Every x years'
                        ].map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 5.0),
                              child: Text(value),
                            ),
                          );
                        }).toList(),
                      ),
                      if (repeatOption == 'Every x days' ||
                          repeatOption == 'Every x months' ||
                          repeatOption == 'Every x years')
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: _buildTextFieldReminder(
                              'Interval (x)', intervalController,
                              isRequired: true),
                        ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: _buildDatePickerReminders(context, 'End Date',
                            endDate ?? DateTime.now(), _selectEndDate),
                      ),
                    ],
                  ),
                Divider(
                    color: Theme.of(context).colorScheme.secondary,
                    thickness: 1,
                    height: 20),
                _buildTextFieldReminder('Description', descriptionController,
                    maxLenght: 200),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextFieldReminder(String label, TextEditingController controller,
      {bool isRequired = false, int? maxLenght}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 5),
        SizedBox(
          height: 60,
          width: double.infinity,
          child: TextFormField(
            controller: controller,
            maxLength: maxLenght,
            decoration: InputDecoration(
              counterText: '',
              labelText: controller.text.isNotEmpty
                  ? null
                  : isRequired
                      ? 'Required'
                      : 'Optional',
              labelStyle: const TextStyle(fontSize: 10),
              focusedBorder: OutlineInputBorder(
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

  Widget _buildTimePickerReminders(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Time',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
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

  Widget _buildDatePickerReminders(BuildContext context, String label,
      DateTime date, Function(BuildContext) selectDate) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
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
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 16.0,
              runSpacing: 16.0,
              children: pets.map((pet) {
                final isSelected = selectedPets.contains(pet.id);
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        selectedPets.remove(pet.id);
                      } else {
                        selectedPets.add(pet.id);
                      }
                    });
                  },
                  child: Container(
                    width: 90,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Theme.of(context).colorScheme.secondary
                          : Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(10),
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
                        Padding(
                          padding: const EdgeInsets.only(top: 5.0),
                          child: CircleAvatar(
                            backgroundImage: AssetImage(pet.avatarImage),
                            radius: 25,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            pet.name,
                            style: const TextStyle(
                                fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        );
      },
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
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(
                    foregroundColor: Theme.of(context).primaryColorDark),
              ),
              colorScheme: ColorScheme.light(
                primary: const Color(0xff68a2b6),
                onPrimary: Theme.of(context).primaryColorDark,
                surface: Theme.of(context).colorScheme.primary,
                onSurface: Theme.of(context).primaryColorDark,
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
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData(
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).primaryColorDark),
            ),
            colorScheme: ColorScheme.light(
              primary: const Color(0xff68a2b6),
              onPrimary: Theme.of(context).primaryColorDark,
              surface: Theme.of(context).colorScheme.primary,
              onSurface: Theme.of(context).primaryColorDark,
            ),
          ),
          child: child!,
        );
      },
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
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData(
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).primaryColorDark),
            ),
            colorScheme: ColorScheme.light(
              primary: const Color(0xff68a2b6),
              onPrimary: Theme.of(context).primaryColorDark,
              surface: Theme.of(context).colorScheme.primary,
              onSurface: Theme.of(context).primaryColorDark,
            ),
          ),
          child: child!,
        );
      },
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
        SnackBar(
          content: const Text('Please fill in all required fields.'),
          backgroundColor: Theme.of(context).primaryColorDark,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    final String title = nameController.text;
    final String description = descriptionController.text;
    final String userId = FirebaseAuth.instance.currentUser!.uid;
    final String objectId = generateUniqueId();

    final DateTime now = DateTime.now();
    final DateTime scheduledDate = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      selectedTime.hour,
      selectedTime.minute,
    );

    if (scheduledDate.isBefore(now.add(const Duration(minutes: 5))) &&
        selectedDate.day == now.day) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              const Text('Reminder time must be at least 5 minutes from now.'),
          backgroundColor: Theme.of(context).primaryColorDark,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    List<String> selectedPetIdList = [];
    for (var petId in selectedPets) {
      selectedPetIdList.add(petId);
      final String eventId = generateUniqueId();
      final Event newEvent = Event(
        id: eventId,
        title: title,
        eventDate: scheduledDate,
        dateWhenEventAdded: DateTime.now(),
        userId: userId,
        petId: petId,
        description: description,
        emoticon: '🔔',
      );
      await ref.read(eventServiceProvider).addEvent(newEvent, petId);
    }

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
        endDate: endDate ?? DateTime.now(),
        selectedPets: selectedPetIdList);

    await ref.read(eventReminderServiceProvider).addReminder(newReminder);

    Navigator.of(context).pop();
  }
}
