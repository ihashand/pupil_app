import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/helper/calculate_age.dart';
import 'package:pet_diary/src/providers/pet_provider.dart';
import 'package:pet_diary/src/screens/details_screen.dart';

class AnimalCard extends ConsumerStatefulWidget {
  final String petId;

  const AnimalCard({
    super.key,
    required this.petId,
  });

  @override
  ConsumerState<AnimalCard> createState() => _AnimalCardState();
}

class _AnimalCardState extends ConsumerState<AnimalCard> {
  @override
  Widget build(BuildContext context) {
    var pet = ref.read(petRepositoryProvider).value?.getPetById(widget.petId);
    if (pet == null) {
      return const SizedBox.shrink();
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
              left: 0,
              right: 0,
              top: 0,
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
              top: 10,
              child: ClipOval(
                child: Image.asset(pet.avatarImage, fit: BoxFit.cover),
              ),
            ),
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
                    const SizedBox(
                      height: 5,
                    ),
                    Text(
                      calculateAge(pet.age),
                      style: const TextStyle(
                        color: Colors.grey,
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
                            builder: (context) => DetailsScreen(petId: pet.id),
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
