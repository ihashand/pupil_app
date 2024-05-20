// ignore_for_file: use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/components/add_pet_steps/add_pet_app_bar.dart';
import 'package:pet_diary/src/components/add_pet_steps/add_pet_segment_progress_bar.dart';
import 'package:pet_diary/src/data/services/pet_services.dart';
import 'package:pet_diary/src/helper/helper_show_avatar_selection.dart';
import 'package:pet_diary/src/models/pet_model.dart';

class AddPetStep5Avatar extends StatefulWidget {
  final WidgetRef ref;
  final String petName;
  final String petAge;
  final String petGender;
  final String petBreed;
  const AddPetStep5Avatar(
      {super.key,
      required this.ref,
      required this.petName,
      required this.petAge,
      required this.petGender,
      required this.petBreed});
  @override
  AddPetStep5AvatarState createState() => AddPetStep5AvatarState();
}

class AddPetStep5AvatarState extends State<AddPetStep5Avatar> {
  late String petSelectedAvatar;

  @override
  void initState() {
    super.initState();
    petSelectedAvatar = '';
  }

  @override
  Widget build(BuildContext context) {
    User? currentUser = FirebaseAuth.instance.currentUser;
    String backgroundImage = '';

    if (widget.petGender == 'Male') {
      backgroundImage = 'assets/images/dog_details_background_04.png';
    } else if (widget.petGender == 'Female') {
      backgroundImage = 'assets/images/dog_details_background_06.png';
    }

    return Scaffold(
      appBar: addPetAppBar(context, showCloseButton: true),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(30.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      AddPetSegmentProgressBar(
                        totalSegments: 5,
                        filledSegments: 5,
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        fillColor: const Color(0xffdfd785).withOpacity(0.7),
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
                        onTap: () => showAvatarSelectionDialog(
                          context: context,
                          onAvatarSelected: (String path) {
                            setState(() {
                              petSelectedAvatar = path;
                            });
                          },
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(
                            right: 12.0,
                          ),
                          child: CircleAvatar(
                            backgroundColor:
                                const Color(0xffdfd785).withOpacity(0.3),
                            backgroundImage: petSelectedAvatar.isNotEmpty
                                ? AssetImage(petSelectedAvatar)
                                : null,
                            radius: 80,
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
                        if (petSelectedAvatar.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please select pet avatar.'),
                            ),
                          );
                          return;
                        }

                        if (widget.petName.isNotEmpty &&
                            widget.petAge.isNotEmpty &&
                            widget.petGender.isNotEmpty) {
                          if (currentUser != null) {
                            String userId = currentUser.uid;

                            final newPet = Pet(
                                id: UniqueKey().toString(),
                                name: widget.petName,
                                avatarImage: petSelectedAvatar,
                                age: widget.petAge,
                                gender: widget.petGender,
                                userId: userId,
                                breed: widget.petBreed,
                                dateTime: DateTime.now(),
                                backgroundImage: backgroundImage);

                            // Get the PetService instance (assuming you have one)
                            final petService = PetService();

                            // Add the pet to Firestore using the service
                            petService.addPet(newPet);
                          }
                        }

                        Navigator.of(context)
                            .popUntil((route) => route.isFirst);
                      },
                      label: Text('Save',
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
          ),
        ],
      ),
    );
  }
}
