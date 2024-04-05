import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/components/add_pet_steps/add_pet_step2_birthday.dart';
import 'package:pet_diary/src/components/add_pet_steps/add_pet_app_bar.dart';
import 'package:pet_diary/src/components/add_pet_steps/add_pet_segment_progress_bar.dart';

class AddPetStep1Name extends StatelessWidget {
  final WidgetRef ref;
  const AddPetStep1Name({super.key, required this.ref});

  @override
  Widget build(BuildContext context) {
    TextEditingController petNameController = TextEditingController();

    return Scaffold(
      appBar: addPetAppBar(context, showCloseButton: true),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                AddPetSegmentProgressBar(
                  totalSegments: 5,
                  filledSegments: 1, // Ponieważ to drugi krok
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  fillColor: Colors.blue,
                ),
                const SizedBox(
                  height: 150,
                ),
                const Text(
                  'What is your pupil name?',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const Text(
                  'This input is required. You can change it leter.',
                ),
                const SizedBox(height: 40),
                SizedBox(
                  height: 60,
                  width: 330,
                  child: InputDecorator(
                    decoration: InputDecoration(
                      fillColor: Theme.of(context).primaryColorDark,
                      labelText: 'Name',
                      border: const OutlineInputBorder(),
                      labelStyle: const TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    child: TextFormField(
                      controller: petNameController,
                    ),
                  ),
                ),
              ],
            ),
            ElevatedButton(
              onPressed: () {
                if (petNameController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter pet name.')),
                  );
                  return; // Przerywamy dalsze działanie przycisku
                }
                if (petNameController.text.length > 50) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Column(
                      children: [
                        Text(
                            'Your name is to long: ${petNameController.text.length}'),
                        const Text('Maximum length is 50 characters.')
                      ],
                    )),
                  );
                  return; // Przerywamy dalsze działanie przycisku
                }
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => AddPetStep2Birthday(
                          ref: ref,
                          petName: petNameController.text,
                        )));
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Theme.of(context).primaryColorDark,
                backgroundColor: Colors.blue,
                padding:
                    const EdgeInsets.symmetric(horizontal: 130, vertical: 10),
                textStyle: const TextStyle(fontSize: 20),
              ),
              child: const Text('Next'),
            ),
          ],
        ),
      ),
    );
  }
}
