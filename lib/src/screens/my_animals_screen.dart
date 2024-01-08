import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/models/pet_model.dart';
import 'package:pet_diary/src/providers/pet_provider.dart';

class MyAnimalsScreen extends ConsumerWidget {
  const MyAnimalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final petRepo = ref.watch(petRepositoryProvider);
    final name = ref.watch(petNameControllerProvider);
    final age = ref.watch(ageControllerProvider);

    void addNewPet() {
      String newName = name.text.trim();
      String petAge = age.text.trim();

      if (newName.isNotEmpty && petAge.isNotEmpty) {
        Pet newPet = Pet(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: newName,
          image:
              'assets/images/lilu.png', // TODO replace with adding image function
          age: petAge,
        );

        petRepo.addPet(newPet);
        name.clear();
        age.clear();
      }
    }

    void deletePet(int index) {
      petRepo.deletePet(index.toString());
    }

    Widget buildAddPetField() {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: name,
                    decoration: const InputDecoration(
                      hintText: 'Enter new pet name',
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: addNewPet,
                  child: const Text('Add Pet'),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: age,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      hintText: 'Enter pet age',
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    Future<Widget> buildPetTable() async {
      List<Pet> petBox = petRepo.getPets();

      if (petBox.isEmpty) {
        return const Center(
          child: Text('No pets available.'),
        );
      }

      return ListView.builder(
        itemCount: petBox.length,
        itemBuilder: (context, index) {
          final pet = petBox[index];
          return ListTile(
            title: Text('${pet.name} - Age: ${pet.age}'),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => deletePet(index),
            ),
          );
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('MY ANIMALS'),
        backgroundColor: Theme.of(context).colorScheme.secondary,
      ),
      body: Column(
        children: [
          buildAddPetField(),
          FutureBuilder(
            future: buildPetTable(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Expanded(child: snapshot.data!);
              } else {
                return const CircularProgressIndicator();
              }
            },
          ),
        ],
      ),
    );
  }
}
