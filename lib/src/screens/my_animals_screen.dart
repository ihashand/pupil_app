import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/data/services/local_notification_service.dart';
import 'package:pet_diary/src/models/pet_model.dart';
import 'package:pet_diary/src/providers/pet_provider.dart';

class MyAnimalsScreen extends ConsumerWidget {
  const MyAnimalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var pets = ref.watch(petRepositoryProvider).value?.getPets();
    final namePetController = ref.watch(petNameControllerProvider);
    final ageController = ref.watch(ageControllerProvider);
    final selectedAvatar = ref.watch(selectedAvatarProvider);
    final localNotificationService = LocalNotificationService();

    Future<void> addNewPet() async {
      String newName = namePetController.text.trim();
      String petAge = ageController.text.trim();

      if (newName.isNotEmpty && petAge.isNotEmpty) {
        Pet newPet = Pet(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: newName,
          image: selectedAvatar,
          age: petAge,
        );
        await ref.watch(petRepositoryProvider).value?.addPet(newPet);
        namePetController.clear();
        ageController.clear();
        localNotificationService.showLocalNotification(
          'Yay you did it!',
          'Congrats on your first local notification',
        );

        DateTime now = DateTime.now().toLocal();
        DateTime(now.year, now.month, now.day + 1, 9, 0);

        final Event event = Event(
          title: 'Spacer z $newName',
          description: 'Nie ma lipy, idziemy na spacer!',
          location: 'Dwór (chyba że jesteś w Krakowie to pole)',
          startDate: DateTime(now.year, now.month, now.day + 1, 9, 0),
          endDate: DateTime(now.year, now.month, now.day + 1, 9, 30),
          iosParams: const IOSParams(
            reminder: Duration(
              minutes: 15,
            ),
          ),
          recurrence: Recurrence(
            frequency: Frequency.daily,
            interval: 1,
            ocurrences: 30,
          ),
        );
        Add2Calendar.addEvent2Cal(event);
      }
      pets = ref.refresh(petRepositoryProvider).value?.getPets();
    }

    Future<void> deletePet(int index) async {
      await ref.watch(petRepositoryProvider).value?.deletePet(index);
      pets = ref.refresh(petRepositoryProvider).value?.getPets();
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
      ];

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Select Avatar'),
            content: SizedBox(
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

    Future<Widget> buildPetTable() async {
      if (pets == null || pets!.isEmpty) {
        return const Center(
          child: Text('No pets available.'),
        );
      }

      return ListView.builder(
        itemCount: pets!.length,
        itemBuilder: (context, index) {
          final pet = pets![index];
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
