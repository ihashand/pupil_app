import 'package:flutter/material.dart';
import 'package:pet_diary/src/helper/calculate_age.dart';
import 'package:pet_diary/src/models/pet_model.dart';
import 'package:pet_diary/src/screens/events_screen.dart';

class PetDetailNameAgeButtonWidget extends StatelessWidget {
  const PetDetailNameAgeButtonWidget({
    super.key,
    required this.pet,
    required this.buttonColor,
    required this.petId,
  });

  final Pet? pet;
  final Color buttonColor;
  final String petId;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                pet!.name,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                calculateAge(pet!.age),
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).primaryColorDark,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(15, 0, 15, 5),
          child: SizedBox(
            height: 50,
            width: 120,
            child: FloatingActionButton(
              backgroundColor: buttonColor,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => EventsScreen(petId)),
                );
              },
              child: const Icon(
                Icons.add,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
