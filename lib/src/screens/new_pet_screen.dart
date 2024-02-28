import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/data/services/local_notification_service.dart';
import 'package:pet_diary/src/models/pet_model.dart';
import 'package:pet_diary/src/providers/pet_provider.dart';

class NewPetScreen extends ConsumerWidget {
  const NewPetScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var currentUser = FirebaseAuth.instance.currentUser;
    var pets = ref.watch(petRepositoryProvider).value?.getPets();
    final petNameController = ref.watch(petNameProvider);
    final petAgeController = ref.watch(petAgeProvider);
    final petGenderController = ref.watch(petGenderProvider);
    final petColorController = ref.watch(petColorProvider);
    final petSelectedAvatar = ref.watch(petImageProvider);
    final localNotificationService = LocalNotificationService();

    Future<void> addNewPet() async {
      String petName = petNameController.text.trim();
      String petAge = petAgeController.text.trim();
      String petColor = petColorController.text.trim();
      String petGender = petGenderController.text.trim();

      if (petName.isNotEmpty &&
          petAge.isNotEmpty &&
          petGender.isNotEmpty &&
          petColor.isNotEmpty) {
        if (currentUser != null) {
          String userId = currentUser.uid;

          Pet newPet = Pet(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            name: petName,
            image: petSelectedAvatar,
            age: petAge,
            gender: petGender,
            color: petColor,
            pills: [],
            events: [],
            userId: userId,
          );

          await ref.watch(petRepositoryProvider).value?.addPet(newPet);
          petNameController.clear();
          petAgeController.clear();
          petGenderController.clear();
          petColorController.clear();

          localNotificationService.showLocalNotification(
            'Yay you did it!',
            'Congrats on your first local notification',
          );

          DateTime now = DateTime.now().toLocal();
          DateTime(now.year, now.month, now.day + 1, 9, 0);

          // final Event event = Event(
          //   title: 'Spacer z $petName',
          //   description: 'Nie ma lipy, idziemy na spacer!',
          //   location: 'Dwór (chyba że jesteś w Krakowie to pole)',
          //   startDate: DateTime(now.year, now.month, now.day + 1, 9, 0),
          //   endDate: DateTime(now.year, now.month, now.day + 1, 9, 30),
          //   iosParams: const IOSParams(
          //     reminder: Duration(
          //       minutes: 15,
          //     ),
          //   ),
          //   recurrence: Recurrence(
          //     frequency: Frequency.daily,
          //     interval: 1,
          //     ocurrences: 30,
          //   ),
          // );

          // Add2Calendar.addEvent2Cal(event); //todo add to phone calendar
        }
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
                      ref.read(petImageProvider.notifier).state = avatarPath;
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

    void selectColor() {
      List<String> colorOptions = [
        'black',
        'brown',
        'chocolate',
        'white',
        'gray',
        'red',
        'fawn',
        'sable',
        'blue',
        'cream,',
        'brindle',
        'merle',
        'tan',
        'gold',
        'yellow',
        'orange',
        'green',
        'brown',
        'black',
      ];

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Select color'),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                itemCount: colorOptions.length,
                itemBuilder: (context, index) {
                  final color = colorOptions[index];
                  return ListTile(
                    title: Text(color),
                    onTap: () {
                      petColorController.text = color;
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

    void selectGender() {
      List<String> genders = [
        'male',
        'female',
      ];

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Select gender'),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                itemCount: genders.length,
                itemBuilder: (context, index) {
                  final petGender = genders[index];
                  return ListTile(
                    title: Text(petGender),
                    onTap: () {
                      petGenderController.text = petGender;
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
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: petNameController,
                    decoration: const InputDecoration(
                      hintText: 'Enter new pet name',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: petAgeController,
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
              child: Text(
                'Select Avatar',
                style: TextStyle(
                  color: Theme.of(context).primaryColorDark,
                ),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: selectColor,
              child: Text(
                'Select Color',
                style: TextStyle(
                  color: Theme.of(context).primaryColorDark,
                ),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: selectGender,
              child: Text(
                'Select gender',
                style: TextStyle(
                  color: Theme.of(context).primaryColorDark,
                ),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: addNewPet,
              child: Text(
                'Add Pet',
                style: TextStyle(
                  color: Theme.of(context).primaryColorDark,
                ),
              ),
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
          final pet = pets?[index];
          return ListTile(
            title: Text(
                '${pet?.name} - Age: ${pet?.age} - G: ${pet?.gender} - C: ${pet?.color}'),
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
        backgroundColor: Colors.transparent,
      ),
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
