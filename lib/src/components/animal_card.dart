import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/helper/calculate_age.dart';
import 'package:pet_diary/src/models/pet_model.dart';
import 'package:pet_diary/src/screens/details_screen.dart';

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
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(30.0),
        ),
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            Positioned(
              child: Container(
                height: 115,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30)),
                  image: DecorationImage(
                    image: ExactAssetImage(pet.backgroundImage),
                    fit: BoxFit.fill,
                  ),
                ),
              ),
            ),
            Positioned(
              width: 90,
              height: 90,
              top: 12,
              child: ClipOval(
                child: Image.asset(pet.avatarImage, fit: BoxFit.cover),
              ),
            ),
            Positioned(
              left: 20,
              bottom: 0,
              top: 100,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 19,
                  ),
                  Text(
                    calculateAge(pet.age),
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 11,
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
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 0, 0, 0),
                    child: SizedBox(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: buttonColor,
                          minimumSize: const Size(30, 30),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  DetailsScreen(petId: pet.id),
                            ),
                          );
                        },
                        child: Text(
                          'Details',
                          style: TextStyle(
                            fontSize: 16,
                            fontFamily: 'San Francisco',
                            color: Theme.of(context).primaryColorDark,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
