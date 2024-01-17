import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/components/animal_card.dart';
import 'package:pet_diary/src/components/events/weight_event.dart';
import 'package:pet_diary/src/components/my_button_widget.dart';
import 'package:pet_diary/src/components/events/walk_event.dart';
import 'package:pet_diary/src/providers/pet_provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../providers/event_provider.dart';

class HomePageScreen extends ConsumerWidget {
  const HomePageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final petState = ref.watch(petRepositoryProvider);
    final pets = petState.value?.getPets();
    var allEvents = ref.watch(eventRepositoryProvider).value?.getEvents();
    var dateController = ref.watch(eventDateControllerProvider);
    var nameController = ref.watch(eventNameControllerProvider);
    var descriptionController = ref.watch(eventDescriptionControllerProvider);
    User? user = FirebaseAuth.instance.currentUser;
    String? displayName = user?.email;

    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Welcome back,',
                            style: TextStyle(
                              fontSize: 15,
                              fontFamily: 'San Francisco',
                            ),
                          ),
                          Text(
                            displayName ??
                                'Brak dostępnych informacji o użytkowniku',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'San Francisco',
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (user != null)
                      const Padding(
                        padding: EdgeInsets.only(
                          right: 12.0,
                        ),
                        child: CircleAvatar(
                          backgroundColor: Color.fromARGB(255, 201, 120, 197),
                          backgroundImage: ExactAssetImage(
                              'assets/images/dog_avatar_07.png'),
                          radius: 40,
                        ),
                      ),
                  ]),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 220,
              // Ustaw konkretną wysokość dla ListView
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: pets?.length ?? 0,
                itemBuilder: (context, index) {
                  final currentPet = pets![index];
                  return SizedBox(
                    height: 200,
                    width: 165,
                    child: AnimalCard(pet: currentPet),
                  );
                },
              ),
            ),
            const SizedBox(height: 30),
            Column(
              children: [
                SizedBox(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Invitation for a walk                ', //todo tu musze cos wymyslic, ale nie wiem jak to ogarnac nie chce zadzialac normalniej.
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'San Francisco',
                        ),
                      ),
                      TextButton(
                          onPressed: () {},
                          child: const Text(
                            "Create",
                            style: TextStyle(
                                color: Color.fromARGB(255, 201, 120, 197),
                                fontSize: 18,
                                fontFamily: 'San Francisco',
                                fontWeight: FontWeight.bold),
                          ))
                    ],
                  ),
                ),
                MyRectangleWidget(
                  onTap: () {
                    if (kDebugMode) {
                      print('Widget tapped');
                    }
                  },
                  imageAsset: "assets/images/background_03.jpg",
                  borderRadius: 20.0,
                  width: 350.0,
                  fontSize: 14.0,
                  opacity: 0.6,
                  bottomColor: Colors.white,
                  topHeight: 130,
                  bottomHeight: 80,
                  bottomContent: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Sid and Lilu',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'San Francisco',
                              ),
                            ),
                            Text(
                              'Today 12:00',
                              style: TextStyle(
                                fontSize: 12,
                                fontFamily: 'San Francisco',
                              ),
                            ),
                          ],
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromARGB(255, 201, 120, 197),
                            minimumSize: const Size(20, 35),
                          ),
                          onPressed: () {
                            // Obsługa przycisku "Details"
                          },
                          child: const Text(
                            'Route',
                            style: TextStyle(
                              fontSize: 16,
                              fontFamily: 'San Francisco',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                MyButtonWidget(
                  iconData: Icons.nordic_walking_sharp,
                  label: 'W A L K',
                  onTap: () {
                    walkEvent(
                        isHomeEvent: true,
                        context,
                        nameController,
                        descriptionController,
                        dateController,
                        ref,
                        allEvents,
                        (date, focusedDate) {},
                        0,
                        0);
                  },
                  color: const Color.fromARGB(255, 201, 120, 197),
                  opacity: 0.6,
                  borderRadius: 20.0,
                  iconSize: 30.0,
                  fontSize: 12.0,
                  fontFamily: 'San Francisco',
                ),
                MyButtonWidget(
                  iconData: FontAwesomeIcons.weightScale,
                  label: 'W E I G H T',
                  onTap: () {
                    weightEvent(
                        context,
                        nameController,
                        descriptionController,
                        dateController,
                        ref,
                        allEvents,
                        isHomeEvent: true,
                        (date, focusedDate) {},
                        0,
                        0);
                  },
                  color: const Color.fromARGB(255, 201, 120, 197),
                  opacity: 0.6,
                  borderRadius: 20.0,
                  iconSize: 30.0,
                  fontSize: 12.0,
                  fontFamily: 'San Francisco',
                ),
                MyButtonWidget(
                  iconData: Icons.check,
                  label: 'R E M I N D E R',
                  onTap: () {},
                  color: const Color.fromARGB(255, 201, 120, 197),
                  opacity: 0.6,
                  borderRadius: 20.0,
                  iconSize: 30.0,
                  fontSize: 12.0,
                  fontFamily: 'San Francisco',
                ),
                MyButtonWidget(
                  iconData: Icons.person,
                  label: 'V E T',
                  onTap: () {},
                  color: const Color.fromARGB(255, 201, 120, 197),
                  opacity: 0.6,
                  borderRadius: 20.0,
                  iconSize: 30.0,
                  fontSize: 12.0,
                  fontFamily: 'San Francisco',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
