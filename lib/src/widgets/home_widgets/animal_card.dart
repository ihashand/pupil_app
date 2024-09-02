import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/models/others/pet_model.dart';
import 'package:flutter/material.dart';
import 'package:pet_diary/src/helper/calculate_age.dart';
import 'package:pet_diary/src/screens/pet_details_screen.dart';

class AnimalCard extends ConsumerStatefulWidget {
  final Pet pet;

  const AnimalCard({
    super.key,
    required this.pet,
  });

  @override
  ConsumerState<AnimalCard> createState() => _AnimalCardState();
}

class _AnimalCardState extends ConsumerState<AnimalCard> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var pet = widget.pet;
    var buttonColor = Colors.black;
    var maleColor = const Color(0xff68a2b6).withOpacity(0.6);
    var femaleColor = const Color(0xffff8a70).withOpacity(0.8);
    if (pet.gender == 'Male') {
      buttonColor = maleColor;
    } else if (pet.gender == 'Female') {
      buttonColor = femaleColor;
    }

    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Container(
        width: 155,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(20.0),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.surface,
              spreadRadius: 2,
              blurRadius: 4,
              offset: const Offset(3, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 110,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                image: DecorationImage(
                  image: ExactAssetImage(pet.backgroundImage),
                  fit: BoxFit.cover,
                ),
              ),
              child: Center(
                child: ClipOval(
                  child: Image.asset(
                    pet.avatarImage,
                    fit: BoxFit.cover,
                    width: 85,
                    height: 85,
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 100,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                        top: 7.0, bottom: 10.0, left: 10.0, right: 10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          calculateAge(pet.age),
                          style: TextStyle(
                            color: Theme.of(context).primaryColorDark,
                            fontSize: 10,
                          ),
                        ),
                        Text(
                          pet.name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'San Francisco',
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10, left: 15),
                    child: TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: buttonColor,
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(120, 30),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                PetDetailsScreen(petId: pet.id),
                          ),
                        );
                      },
                      child: Text(
                        'D e t a i l s',
                        style: TextStyle(
                          fontSize: 11,
                          color: Theme.of(context).primaryColorDark,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
