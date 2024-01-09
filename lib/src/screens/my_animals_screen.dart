import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/models/pet_model.dart';
import 'package:pet_diary/src/providers/pet_provider.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class MyAnimalsScreen extends StatefulHookConsumerWidget {
  const MyAnimalsScreen({super.key});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _MyAnimalsScreenState();
}

class _MyAnimalsScreenState extends ConsumerState<MyAnimalsScreen> {
  @override
  Widget build(BuildContext context) {
    final pets = ref.watch(petHiveData);
    final petsRepository = ref.watch(petRepositoryProvider);
    final namePetController = ref.watch(petNameControllerProvider);
    final ageController = ref.watch(ageControllerProvider);
    final selectedAvatar = ref.watch(selectedAvatarProvider);

    print("<<<<<1");
    print(pets);
    print("<<<<<2");
    print(petsRepository.getPets());

    void addNewPet() {
      String newName = namePetController.text.trim();
      String petAge = ageController.text.trim();

      if (newName.isNotEmpty && petAge.isNotEmpty) {
        Pet newPet = Pet(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: newName,
          image: selectedAvatar, // Use the selected avatar path
          age: petAge,
        );
        petsRepository.addPet(newPet);
        namePetController.clear();
        ageController.clear();
      }
    }

    void deletePet(int index) {
      petsRepository.deletePet(index.toString());
    }

    void selectAvatarImage() {
      List<String> avatarOptions = [
        'assets/images/dog_avatar_01.png',
        'assets/images/dog_avatar_02.png',
        'assets/images/dog_avatar_03.png',
        'assets/images/dog_avatar_04.png',
        'assets/images/dog_avatar_05.png',
        'assets/images/dog_avatar_06.png',
        'assets/images/dog_avatar_07.png',
        'assets/images/dog_avatar_09.png',
        'assets/images/dog_avatar_010.png',
        'assets/images/dog_avatar_011.png',
        'assets/images/dog_avatar_012.png',
        'assets/images/dog_avatar_013.png',
        'assets/images/dog_avatar_014.png',
        'assets/images/dog_avatar_015.png',

        // Add more image paths from assets as needed
      ];

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Select Avatar'),
            content: Container(
              width: double.maxFinite,
              child: ListView.builder(
                itemCount: avatarOptions.length,
                itemBuilder: (context, index) {
                  final avatarPath = avatarOptions[index];
                  return ListTile(
                    title: Image.asset(avatarPath),
                    onTap: () {
                      ref.read(selectedAvatarProvider.notifier).state =
                          avatarPath;
                      Navigator.of(context).pop();
                    },
                  );
                },
              ),
            ),
          );
        },
      );
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
                    controller: namePetController,
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
                    controller: ageController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      hintText: 'Enter pet age',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: selectAvatarImage,
              child: const Text('Select Avatar'),
            ),
          ],
        ),
      );
    }

    Widget buildPetTable() {
      if (pets == null || pets.isEmpty) {
        return const Center(
          child: Text('No pets available.'),
        );
      }

      return const Center(
        child: Text('No pets available.'),
      );

      return ListView.builder(
        itemCount: pets.length,
        itemBuilder: (context, index) {
          final pet = pets[index];
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
      body: Column(
        children: [
          const SizedBox(height: 50),
          buildAddPetField(),
          buildPetTable(),
        ],
      ),
    );
  }
}
