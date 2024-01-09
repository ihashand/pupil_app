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
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
        ),
        child: Column(
          children: [
            const SizedBox(height: 8),
            Stack(
              alignment: Alignment.bottomCenter,
              children: [
                Container(
                  width: 233,
                  height: 233,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color.fromARGB(255, 157, 222, 235)
                        .withOpacity(0.23),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(23.0),
                    child: ClipOval(
                      child: Image.asset(pet.image, fit: BoxFit.cover),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 15,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.edit,
                      size: 30,
                      color: Colors.blue,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              convertToUpperCase(pet.name),
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
          ],
        ),
      ),
    );
  }
}

String convertToUpperCase(String input) {
  return input.split('').map((char) => char.toUpperCase()).join(' ');
}
