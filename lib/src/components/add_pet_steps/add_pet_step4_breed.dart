import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:pet_diary/src/components/add_pet_steps/add_pet_step5_avatar.dart';
import 'package:pet_diary/src/components/add_pet_steps/add_pet_app_bar.dart';
import 'package:pet_diary/src/components/add_pet_steps/dogs_breed_data.dart';
import 'package:pet_diary/src/components/add_pet_steps/add_pet_segment_progress_bar.dart';

class AddPetStep4Breed extends StatelessWidget {
  final WidgetRef ref;
  final String petName;
  final String petAge;
  final String petGender;

  const AddPetStep4Breed({
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
      appBar: addPetAppBar(context, showCloseButton: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            AddPetSegmentProgressBar(
              totalSegments: 5,
              filledSegments: 4, // Ponieważ to drugi krok
              backgroundColor: Theme.of(context).colorScheme.primary,
              fillColor: const Color(0xffdfd785).withOpacity(0.7),
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
              width: 200,
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
            SizedBox(
              height: 40,
              width: 300,
              child: FloatingActionButton.extended(
                onPressed: () {
                  if (petBreedController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please select pet breed.')),
                    );
                    return; // Przerywamy dalsze działanie przycisku
                  }
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => AddPetStep5Avatar(
                      ref: ref,
                      petName: petName,
                      petAge: petAge,
                      petGender: petGender,
                      petBreed: petBreedController.text,
                    ),
                  ));
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
