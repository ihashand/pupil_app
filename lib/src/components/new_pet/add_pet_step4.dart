import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:pet_diary/src/components/new_pet/add_pet_step5.dart';
import 'package:pet_diary/src/components/new_pet/build_app_bar.dart';
import 'package:pet_diary/src/components/new_pet/dog_groups.dart';
import 'package:pet_diary/src/components/new_pet/segmented_progress_bar.dart';

class AddPetStep4 extends StatelessWidget {
  final WidgetRef ref;
  final String petName;
  final String petAge;
  final String petGender;

  const AddPetStep4({
    super.key,
    required this.ref,
    required this.petName,
    required this.petAge,
    required this.petGender,
  });

  @override
  Widget build(BuildContext context) {
    final TextEditingController petBreedController = TextEditingController();

    return Scaffold(
      appBar: buildAppBar(context, showCloseButton: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            SegmentedProgressBar(
              totalSegments: 5,
              filledSegments: 4, // Ponieważ to drugi krok
              backgroundColor: Theme.of(context).colorScheme.primary,
              fillColor: Colors.blue,
            ),
            const SizedBox(
              height: 150,
            ),
            const Text(
              'Choose your pet breed',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const Text(
              'You can change it leter.',
            ),
            const SizedBox(height: 40),
            SizedBox(
              height: 60,
              width: 250,
              child: TypeAheadFormField(
                textFieldConfiguration: TextFieldConfiguration(
                  controller: petBreedController,
                  decoration: const InputDecoration(
                    labelText: 'Search breed',
                    border: OutlineInputBorder(),
                  ),
                ),
                suggestionsCallback: (pattern) {
                  List<String> allBreeds = dogBreedGroups
                      .expand((group) => group.sections)
                      .expand((section) => section.breeds)
                      .map((breed) => breed.name)
                      .toList();

                  return allBreeds
                      .where((item) =>
                          item.toLowerCase().contains(pattern.toLowerCase()))
                      .toList();
                },
                itemBuilder: (context, suggestion) {
                  return ListTile(title: Text(suggestion.toString()));
                },
                onSuggestionSelected: (suggestion) {
                  petBreedController.text = suggestion.toString();
                },
              ),
            ),
            const SizedBox(
              height: 340,
            ),
            ElevatedButton(
              onPressed: () {
                if (petBreedController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please select pet breed.')),
                  );
                  return; // Przerywamy dalsze działanie przycisku
                }
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => AddPetStep5(
                    ref: ref,
                    petName: petName,
                    petAge: petAge,
                    petGender: petGender,
                    petBreed: petBreedController.text,
                  ),
                ));
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
