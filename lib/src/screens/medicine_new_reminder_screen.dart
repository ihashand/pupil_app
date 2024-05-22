import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/helper/generate_unique_id.dart';
import 'package:pet_diary/src/models/event_medicine_model.dart';
import 'package:pet_diary/src/models/event_reminder_model.dart';
import 'package:pet_diary/src/providers/event_medicine_provider.dart';
import 'package:pet_diary/src/providers/event_reminder_provider.dart';

class MedicineNewReminderScreen extends ConsumerStatefulWidget {
  final String petId;
  final String newPillId;
  final EventMedicineModel? pill;

  const MedicineNewReminderScreen({
    super.key,
    required this.petId,
    required this.newPillId,
    this.pill,
  });

  @override
  createState() => _MedicineNewReminderScreenState();
}

class _MedicineNewReminderScreenState
    extends ConsumerState<MedicineNewReminderScreen> {
  late List<bool> selectedDays = List.filled(7, false);
  late TextEditingController nameController;
  late TextEditingController descriptionController;
  late TimeOfDay selectedTime;
  String repeatOption = 'Daily';
  int? repeatInterval;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    descriptionController = TextEditingController();
    selectedTime = TimeOfDay.now();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Theme.of(context).primaryColorDark.withOpacity(0.7),
        ),
        title: Text(
          'N e w   r e m i n d e r',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColorDark.withOpacity(0.7),
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        toolbarHeight: 50,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.check,
            ),
            onPressed: () => _saveReminder(),
            color: Theme.of(context).primaryColorDark.withOpacity(0.7),
            iconSize: 35,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(35, 10, 35, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Repeat',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  DropdownButton<String>(
                    value: repeatOption,
                    onChanged: (String? newValue) {
                      setState(() {
                        repeatOption = newValue!;
                      });
                    },
                    items: <String>[
                      'Daily',
                      'Selected days',
                      'Weekly',
                      'Monthly',
                      'Every x days',
                    ].map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ],
              ),
              if (repeatOption == 'Selected days') ...[
                Row(
                  children: List.generate(7, (index) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedDays[index] = !selectedDays[index];
                        });
                      },
                      child: Container(
                        width: 36,
                        height: 40,
                        margin: const EdgeInsets.only(right: 10),
                        decoration: BoxDecoration(
                          border:
                              Border.all(color: Colors.grey.withOpacity(0.5)),
                          borderRadius: BorderRadius.circular(5),
                          color: selectedDays[index]
                              ? const Color(0xffdfd785)
                              : Colors.white,
                        ),
                        child: Center(
                          child: Text(
                            [
                              'Mon',
                              'Tue',
                              'Wed',
                              'Thu',
                              'Fri',
                              'Sat',
                              'Sun'
                            ][index],
                            style: TextStyle(
                              color: selectedDays[index]
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ],
              if (repeatOption == 'Weekly' ||
                  repeatOption == 'Every x days' ||
                  repeatOption == 'Monthly') ...[
                const SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Repeat Interval:',
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      height: 45,
                      width: 140,
                      child: TextFormField(
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          setState(() {
                            repeatInterval = int.tryParse(value);
                          });
                        },
                        decoration: const InputDecoration(
                          labelText: 'Interval',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            borderSide: BorderSide(
                              color: Colors.black,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            borderSide: BorderSide(
                              color: Colors.black,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            borderSide: BorderSide(color: Color(0xffdfd785)),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 10),
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
              const SizedBox(height: 5),
              const Text(
                'Name',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              SizedBox(
                height: 60,
                width: double.infinity,
                child: TextFormField(
                  controller: nameController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Default is Medicine name';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: nameController.text.isNotEmpty
                        ? null
                        : '''Optional: Enter title''',
                    labelStyle: const TextStyle(fontSize: 12),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                          color: Color(0xffdfd785), width: 2.0),
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide:
                          const BorderSide(color: Colors.black, width: 1.0),
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {});
                  },
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Description',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              SizedBox(
                height: 60,
                width: double.infinity,
                child: TextFormField(
                  controller: descriptionController,
                  decoration: InputDecoration(
                    labelText: descriptionController.text.isNotEmpty
                        ? null
                        : 'Optional: Enter description',
                    labelStyle: const TextStyle(fontSize: 12),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                          color: Color(0xffdfd785), width: 2.0),
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide:
                          const BorderSide(color: Colors.black, width: 1.0),
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {});
                  },
                ),
              ),
            ],
          ),
        ),
      ),
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

  void _saveReminder() {
    List<int> selectedDaysIndexes = [];
    for (int i = 0; i < selectedDays.length; i++) {
      if (selectedDays[i]) {
        selectedDaysIndexes.add(i);
      }
    }
    var repeatOptionText = '';
    if (repeatOption == 'Daily') {
      repeatOptionText = 'daily';
    } else if (repeatOption == 'Weekly') {
      repeatOptionText = 'every $repeatInterval week';
    } else if (repeatOption == 'Monthly') {
      repeatOptionText = 'every $repeatInterval month';
    } else if (repeatOption == 'Selected days') {
      List<String> selectedDayNames = selectedDaysIndexes.map((index) {
        return [
          'Monday',
          'Tuesday',
          'Wednesday',
          'Thursday',
          'Friday',
          'Saturday',
          'Sunday'
        ][index];
      }).toList();
      repeatOptionText = 'on ${selectedDayNames.join(', ')}';
    } else if (repeatOption == 'Every x days') {
      repeatOptionText = 'every $repeatInterval days';
    }

    final EventReminderModel newReminder = EventReminderModel(
      id: generateUniqueId(),
      title: nameController.text.isNotEmpty
          ? nameController.text
          : ref.read(eventMedicineNameControllerProvider).text,
      description: descriptionController.text.isNotEmpty
          ? descriptionController.text
          : 'Remember to use $repeatOptionText ',
      time: selectedTime,
      userId: FirebaseAuth.instance.currentUser!.uid,
      objectId: widget.newPillId,
      selectedDays: selectedDaysIndexes,
      repeatOption: repeatOption,
      repeatInterval: repeatInterval,
    );

    if (widget.pill != null) {
      newReminder.objectId = widget.pill!.id;
    }

    ref.read(eventReminderServiceProvider).addReminder(newReminder);
    ref.read(eventReminderTemporaryIds.notifier).state!.add(newReminder.id);

    nameController.clear();
    descriptionController.clear();

    Navigator.pop(context);
  }
}
