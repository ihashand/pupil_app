import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/components/add_pet_steps/add_pet_app_bar.dart';
import 'package:pet_diary/src/components/add_pet_steps/add_pet_segment_progress_bar.dart';
import 'package:pet_diary/src/services/pet_services.dart';
import 'package:pet_diary/src/helper/helper_show_avatar_selection.dart';
import 'package:pet_diary/src/models/pet_model.dart';

class AddPetStep5Avatar extends StatefulWidget {
  final WidgetRef ref;
  final String petName;
  final String petAge;
  final String petGender;
  final String petBreed;

  const AddPetStep5Avatar({
    super.key,
    required this.ref,
    required this.petName,
    required this.petAge,
    required this.petGender,
    required this.petBreed,
  });

  @override
  AddPetStep5AvatarState createState() => AddPetStep5AvatarState();
}

class AddPetStep5AvatarState extends State<AddPetStep5Avatar>
    with SingleTickerProviderStateMixin {
  late String petSelectedAvatar;
  bool _showTip = false;
  bool _hideTip = false;
  bool _showContainer = false;
  double _containerOffset = 20.0;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    petSelectedAvatar = '';

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _showContainer = true;
        });
      }

      Future.delayed(const Duration(seconds: 5), () {
        if (mounted) {
          setState(() {
            _showTip = true;
            _containerOffset = 35.0;
          });
        }

        Future.delayed(const Duration(seconds: 10), () {
          if (mounted) {
            setState(() {
              _hideTip = true;
              _containerOffset = 20.0;
            });
          }
        });
      });
    });

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
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
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: addPetAppBar(context, showCloseButton: true),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              Container(
                color: Theme.of(context).colorScheme.primary,
                child: Column(
                  children: [
                    Divider(
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    AddPetSegmentProgressBar(
                      totalSegments: 5,
                      filledSegments: 5,
                      backgroundColor: Theme.of(context).colorScheme.surface,
                      fillColor: const Color(0xffdfd785),
                    ),
                  ],
                ),
              ),
              AnimatedOpacity(
                opacity: _showTip && !_hideTip ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                  padding: const EdgeInsets.symmetric(horizontal: 20.0)
                      .copyWith(top: 35.0),
                  child: Container(
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: const Text(
                      'Tip: Choose an avatar that best represents your pet. You can also upload your own.',
                      style: TextStyle(fontSize: 14, color: Colors.black),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 1600),
                curve: Curves.easeOut,
                padding: EdgeInsets.only(
                    top: _showContainer ? _containerOffset : 0.0,
                    left: 20,
                    right: 20),
                child: AnimatedOpacity(
                  opacity: _showContainer ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 800),
                  child: Container(
                    padding: const EdgeInsets.all(20.0),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16.0),
                          child: Text(
                            'Choose avatar',
                            style: TextStyle(
                                fontSize: 22, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: 6.0, horizontal: 10),
                          child: Text(
                            'Press on the blue circle to select an avatar.',
                            textAlign: TextAlign.justify,
                            style: TextStyle(
                              fontSize: 11,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => showAvatarSelectionDialog(
                            context: context,
                            onAvatarSelected: (String path) {
                              if (mounted) {
                                setState(() {
                                  petSelectedAvatar = path;
                                });
                              }
                            },
                          ),
                          child: Padding(
                            padding:
                                const EdgeInsets.only(top: 30.0, bottom: 30),
                            child: CircleAvatar(
                              backgroundColor:
                                  const Color(0xff68a2b6).withOpacity(0.3),
                              backgroundImage: petSelectedAvatar.isNotEmpty
                                  ? AssetImage(petSelectedAvatar)
                                  : null,
                              radius: 80,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(40.0),
            child: SizedBox(
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
                        backgroundImage: backgroundImage,
                      );

                      final petService = PetService();

                      petService.addPet(newPet);
                    }
                  }

                  if (mounted) {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  }
                },
                label: Text('Save',
                    style: TextStyle(
                        color: Theme.of(context).primaryColorDark,
                        fontSize: 16)),
                backgroundColor: Theme.of(context).colorScheme.primary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
