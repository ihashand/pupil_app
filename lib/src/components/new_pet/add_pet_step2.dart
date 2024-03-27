import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart'; // Importuj pakiet intl
import 'package:pet_diary/src/components/new_pet/add_pet_step3.dart';
import 'package:pet_diary/src/components/new_pet/build_app_bar.dart';
import 'package:pet_diary/src/components/new_pet/segmented_progress_bar.dart';

class AddPetStep2 extends StatefulWidget {
  final WidgetRef ref;
  final String petName;
  const AddPetStep2({Key? key, required this.ref, required this.petName})
      : super(key: key);

  @override
  _AddPetStep2State createState() => _AddPetStep2State();
}

class _AddPetStep2State extends State<AddPetStep2> {
  late DateTime selectedDate;

  @override
  void initState() {
    super.initState();
    selectedDate = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context, showCloseButton: true),
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
                      SegmentedProgressBar(
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
                          // Wyświetlanie okna wyboru daty
                          final pickedDate = await showDatePicker(
                            context: context,
                            initialDate: selectedDate,
                            firstDate: DateTime(1900),
                            lastDate: DateTime.now(),
                            builder: (BuildContext context, Widget? child) {
                              return Theme(
                                data: ThemeData.light().copyWith(
                                  textButtonTheme: TextButtonThemeData(
                                    style: TextButton.styleFrom(
                                      foregroundColor: Colors
                                          .black, // Kolor tekstu przycisku 'OK'
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
                          DateFormat('dd/MM/yyyy')
                              .format(selectedDate), // Formatowanie daty
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => AddPetStep3(
                          ref: widget.ref,
                          petName: widget.petName,
                          petAge: DateFormat('dd/MM/yyyy')
                              .format(selectedDate), // Formatowanie daty
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
