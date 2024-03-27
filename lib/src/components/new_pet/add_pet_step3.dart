import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/components/new_pet/add_pet_step4.dart';
import 'package:pet_diary/src/components/new_pet/build_app_bar.dart';
import 'package:pet_diary/src/components/new_pet/segmented_progress_bar.dart';

class AddPetStep3 extends StatelessWidget {
  final WidgetRef ref;
  final String petName;
  final String petAge;
  const AddPetStep3(
      {super.key,
      required this.ref,
      required this.petName,
      required this.petAge});

  @override
  Widget build(BuildContext context) {
    TextEditingController petGenderController = TextEditingController();

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
                        filledSegments: 3, // Ponieważ to trzeci krok
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        fillColor: Colors.blue,
                      ),
                      const SizedBox(
                        height: 150,
                      ),
                      const Text(
                        'Please select gender',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const Text(
                        'You can change it leter.',
                      ),
                      const SizedBox(height: 40),
                      SizedBox(
                        height: 60,
                        width: 330,
                        child: DropdownButtonFormField<String>(
                          items: ['Male', 'Female'].map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value,
                                  style: TextStyle(
                                      color:
                                          Theme.of(context).primaryColorDark)),
                            );
                          }).toList(),
                          onChanged: (newValue) {
                            petGenderController.text = newValue!;
                          },
                          decoration: const InputDecoration(
                            labelText: 'Select Pet Gender',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (petGenderController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Please select pet gender.')),
                        );
                        return; // Przerywamy dalsze działanie przycisku
                      }
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => AddPetStep4(
                          ref: ref,
                          petName: petName,
                          petAge: petAge,
                          petGender: petGenderController.text,
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
