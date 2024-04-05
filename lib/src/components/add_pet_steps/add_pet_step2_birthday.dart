import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pet_diary/src/components/add_pet_steps/add_pet_step3_gender.dart';
import 'package:pet_diary/src/components/add_pet_steps/add_pet_app_bar.dart';
import 'package:pet_diary/src/components/add_pet_steps/add_pet_segment_progress_bar.dart';

class AddPetStep2Birthday extends StatefulWidget {
  final WidgetRef ref;
  final String petName;
  const AddPetStep2Birthday(
      {super.key, required this.ref, required this.petName});

  @override
  // ignore: library_private_types_in_public_api
  _AddPetStep2BirthdayState createState() => _AddPetStep2BirthdayState();
}

class _AddPetStep2BirthdayState extends State<AddPetStep2Birthday> {
  late DateTime selectedDate;

  @override
  void initState() {
    super.initState();
    selectedDate = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: addPetAppBar(context, showCloseButton: true),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      AddPetSegmentProgressBar(
                        totalSegments: 5,
                        filledSegments: 2,
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        fillColor: Colors.blue,
                      ),
                      const SizedBox(
                        height: 150,
                      ),
                      const Text(
                        'Select your pet\'s birthdate',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const Text(
                        'You can change it later.',
                      ),
                      const SizedBox(height: 40),
                      ElevatedButton(
                        onPressed: () async {
                          final pickedDate = await showDatePicker(
                            context: context,
                            initialDate: selectedDate,
                            firstDate: DateTime(2000),
                            lastDate: DateTime.now(),
                            builder: (BuildContext context, Widget? child) {
                              return Theme(
                                data: ThemeData.light().copyWith(
                                  textButtonTheme: TextButtonThemeData(
                                    style: TextButton.styleFrom(
                                      foregroundColor: Colors.black,
                                    ),
                                  ),
                                ),
                                child: child!,
                              );
                            },
                          );

                          if (pickedDate != null) {
                            setState(() {
                              selectedDate = pickedDate;
                            });
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Theme.of(context).primaryColorDark,
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 40, vertical: 10),
                        ),
                        child: Text(
                          DateFormat('dd/MM/yyyy').format(selectedDate),
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => AddPetStep3Gender(
                          ref: widget.ref,
                          petName: widget.petName,
                          petAge: DateFormat('dd/MM/yyyy').format(selectedDate),
                        ),
                      ));
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Theme.of(context).primaryColorDark,
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 130, vertical: 10),
                      textStyle: const TextStyle(fontSize: 20),
                    ),
                    child: const Text('Next'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
