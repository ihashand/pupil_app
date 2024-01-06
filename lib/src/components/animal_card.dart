import 'package:flutter/material.dart';
import 'package:pet_diary/src/models/pet_model.dart';

class AnimalCard extends StatelessWidget {
  final Pet pet;

  const AnimalCard({super.key, required this.pet});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: Container(
        width: 300,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor.withOpacity(0.40),
          //todo dodac transparentnosc
          borderRadius: BorderRadius.circular(41),
        ),
        child: Column(
          children: [
            Text(
              pet.name,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.inversePrimary,
              ),
            ),
            Text(
              '${pet.age} years',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.inversePrimary,
              ),
            ),
            const SizedBox(height: 8),
            CircleAvatar(
              backgroundImage: AssetImage(pet.image),
              radius: 50,
            ),
          ],
        ),
      ),
    );
  }
}
