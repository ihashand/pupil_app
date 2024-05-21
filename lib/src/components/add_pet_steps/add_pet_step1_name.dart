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
        padding: const EdgeInsets.all(30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                AddPetSegmentProgressBar(
                  totalSegments: 5,
                  filledSegments: 1,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  fillColor: const Color(0xffdfd785).withOpacity(0.7),
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
                const SizedBox(height: 30),
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
            SizedBox(
              height: 40,
              width: 300,
              child: FloatingActionButton.extended(
                onPressed: () {
                  if (petNameController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please enter pet name.')),
                    );
                    return;
                  }
                  if (petNameController.text.length > 50) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Column(
                        children: [
                          Text(
                              'Your name is too long: ${petNameController.text.length}'),
                          const Text('Maximum length is 50 characters.')
                        ],
                      )),
                    );
                    return;
                  }
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => AddPetStep2Birthday(
                            ref: ref,
                            petName: petNameController.text,
                          )));
                },
                label: Text('Next',
                    style: TextStyle(
                        color: Theme.of(context).primaryColorDark,
                        fontSize: 16)),
                backgroundColor: const Color(0xff68a2b6).withOpacity(0.7),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
