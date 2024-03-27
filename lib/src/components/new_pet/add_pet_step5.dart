import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pet_diary/src/components/new_pet/build_app_bar.dart';
import 'package:pet_diary/src/components/new_pet/segmented_progress_bar.dart';
import 'package:pet_diary/src/models/pet_model.dart';
import 'package:pet_diary/src/providers/pet_provider.dart';

class AddPetStep5 extends StatefulWidget {
  final WidgetRef ref;
  final String petName;
  final String petAge;
  final String petGender;
  final String petBreed;
  const AddPetStep5(
      {super.key,
      required this.ref,
      required this.petName,
      required this.petAge,
      required this.petGender,
      required this.petBreed});
  @override
  AddPetStep5State createState() => AddPetStep5State();
}

class AddPetStep5State extends State<AddPetStep5> {
  late String petSelectedAvatar;

  @override
  void initState() {
    super.initState();
    petSelectedAvatar = '';
  }

  Future<void> showAvatarSelectionDialog(BuildContext context) async {
    final picker = ImagePicker();

    await showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const ListTile(
                title: Text(
                  'Choose Default Avatar',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              ListView.builder(
                shrinkWrap: true,
                itemCount: 5, // Liczba domyślnych awatarów
                itemBuilder: (BuildContext context, int index) {
                  final avatarIndex = index + 1;
                  final avatarPath =
                      'assets/images/dog_avatar_${avatarIndex.toString().padLeft(2, '0')}.png';
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: AssetImage(avatarPath),
                    ),
                    title: Text('Avatar $avatarIndex'),
                    onTap: () {
                      Navigator.pop(context);
                      setState(() {
                        petSelectedAvatar = avatarPath;
                      });
                    },
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo),
                title: const Text('Choose from Gallery'),
                onTap: () async {
                  Navigator.pop(context);
                  final pickedFile = await picker.pickImage(
                    source: ImageSource.gallery,
                  );
                  if (pickedFile != null) {
                    final savedImage = File(pickedFile.path);
                    setState(() {
                      petSelectedAvatar = savedImage.path;
                    });
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take a Photo'),
                onTap: () async {
                  Navigator.pop(context);
                  final pickedFile = await picker.pickImage(
                    source: ImageSource.camera,
                  );
                  if (pickedFile != null) {
                    final directory = await getApplicationDocumentsDirectory();
                    final path = directory.path;

                    final fileName = basename(pickedFile.path);
                    final savedImage =
                        await File(pickedFile.path).copy('$path/$fileName');
                    setState(() {
                      petSelectedAvatar = savedImage.path;
                    });
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var currentUser = FirebaseAuth.instance.currentUser;
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
                        filledSegments: 5, // Ponieważ to trzeci krok
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        fillColor: Colors.blue,
                      ),
                      const SizedBox(
                        height: 150,
                      ),
                      const Text(
                        'Choose avatar',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const Text(
                        'You can use default or upload your own',
                      ),
                      const SizedBox(height: 40),
                      GestureDetector(
                        onTap: () => showAvatarSelectionDialog(context),
                        child: Padding(
                          padding: const EdgeInsets.only(
                            right: 12.0,
                          ),
                          child: CircleAvatar(
                            backgroundColor:
                                const Color.fromARGB(255, 172, 170, 172),
                            backgroundImage: petSelectedAvatar.isNotEmpty
                                ? AssetImage(
                                    petSelectedAvatar) // Zmiana FileImage na AssetImage
                                : null,
                            radius: 80,
                          ),
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (petSelectedAvatar.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Please select pet avatar.')),
                        );
                        return;
                      }

                      if (widget.petName.isNotEmpty &&
                          widget.petAge.isNotEmpty &&
                          widget.petGender.isNotEmpty) {
                        if (currentUser != null) {
                          String userId = currentUser.uid;

                          Pet newPet = Pet(
                            id: DateTime.now()
                                .millisecondsSinceEpoch
                                .toString(),
                            name: widget.petName,
                            image: petSelectedAvatar,
                            age: widget.petAge,
                            gender: widget.petGender,
                            userId: userId,
                            breed: widget.petBreed,
                          );

                          widget.ref
                              .watch(petRepositoryProvider)
                              .value
                              ?.addPet(newPet);
                        }
                      }
                      widget.ref
                          .refresh(petRepositoryProvider)
                          .value
                          ?.getPets();
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Theme.of(context).primaryColorDark,
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 130, vertical: 10),
                      textStyle: const TextStyle(fontSize: 20),
                    ),
                    child: const Text('Finish'),
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
