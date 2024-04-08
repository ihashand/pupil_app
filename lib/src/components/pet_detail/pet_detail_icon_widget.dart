import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/models/pet_model.dart';

class PetDetailIconWidget extends ConsumerWidget {
  const PetDetailIconWidget({
    super.key,
    required this.pet,
    required this.weight,
  });

  final Pet? pet;
  final String weight;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(15, 0, 15, 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (pet!.gender == 'Male')
                const Text(
                  '♂',
                  style: TextStyle(fontSize: 35),
                ),
              if (pet!.gender == 'Female')
                const Text(
                  '♀',
                  style: TextStyle(fontSize: 35),
                ),
              const Text(
                'Gender',
                style: TextStyle(fontSize: 10),
              ),
              Text(pet!.gender,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 13)),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                '🎂',
                style: TextStyle(fontSize: 35),
              ),
              const Text(
                'Birth date',
                style: TextStyle(fontSize: 10),
              ),
              Text(pet!.age,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 13)),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                '🐶',
                style: TextStyle(fontSize: 35),
              ),
              const Text(
                'Breed',
                style: TextStyle(fontSize: 10),
              ),
              Text(pet!.breed,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 13)),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                '⚖️',
                style: TextStyle(fontSize: 35),
              ),
              const Text(
                'Weight',
                style: TextStyle(fontSize: 10),
              ),
              Text(
                '$weight kg',
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
