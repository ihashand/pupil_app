import 'package:flutter/material.dart';
import 'package:pet_diary/src/models/pet_model.dart';
import 'package:pet_diary/src/screens/details_screen.dart';

class AnimalCard extends StatelessWidget {
  final Pet pet;

  const AnimalCard({
    Key? key,
    required this.pet,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
              left: 0,
              right: 0,
              top: 0,
              child: Container(
                height: 115,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30)),
                  image: DecorationImage(
                    image: ExactAssetImage('assets/images/background_05.jpg'),
                    fit: BoxFit.fill,
                  ),
                ),
              ),
            ),
            // 2. Avatar
            Positioned(
              width: 90,
              height: 90,
              top: 10,
              child: ClipOval(
                child: Image.asset(pet.image, fit: BoxFit.cover),
              ),
            ),
            // 3. Dane
            Positioned(
              left: 15,
              bottom: 0,
              top: 110,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    Text(
                      '${pet.age} years old',
                      style: const TextStyle(
                        fontSize: 12,
                        fontFamily: 'San Francisco',
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
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color.fromARGB(255, 201, 120, 197),
                        minimumSize: const Size(115, 40),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetailsScreen(pet: pet),
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
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
