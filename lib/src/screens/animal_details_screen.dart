import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/models/pet_model.dart';

class AnimalDetailsScreen extends ConsumerWidget {
  final Pet pet;

  const AnimalDetailsScreen({
    Key? key,
    required this.pet,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              height:
                  200, // Możesz dostosować wysokość obrazu do swoich potrzeb
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
                image: DecorationImage(
                  image: ExactAssetImage('assets/images/background_05.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Text(
                    '${pet.age} years old',
                    style: const TextStyle(
                      fontSize: 16,
                      fontFamily: 'San Francisco',
                    ),
                  ),
                  Text(
                    pet.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'San Francisco',
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Tutaj możesz dodać więcej informacji na temat zwierzaka
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
