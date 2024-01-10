import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:pet_diary/src/components/animal_card.dart';
import 'package:pet_diary/src/components/my_button_widget.dart';
import 'package:pet_diary/src/models/pet_model.dart';
import 'package:pet_diary/src/providers/pet_provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class HomePageScreen extends ConsumerWidget {
  const HomePageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pets = ref.watch(petRepositoryProvider).value?.getPets();
    const int counter = 0;
    final String formattedDate =
        DateFormat('EEEE, d MMMM', 'en_US').format(DateTime.now());
    final pageController = PageController();

    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: Text(
                formattedDate,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 5),
            SizedBox(
              height: 212,
              child: FutureBuilder(
                future: Hive.openBox<Pet>('petBox'),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done &&
                      pets != null &&
                      pets.isNotEmpty) {
                    return PageView.builder(
                      controller: pageController,
                      scrollDirection: Axis.horizontal,
                      itemCount: pets.length,
                      itemBuilder: (context, index) {
                        final pet = pets[index];
                        return AnimalCard(pet: pet);
                      },
                    );
                  } else {
                    return const Center(
                      child: Text('No pets available.'),
                    );
                  }
                },
              ),
            ),
            const SizedBox(height: 10),
            SmoothPageIndicator(
              controller: pageController,
              count: counter,
              effect: ExpandingDotsEffect(
                  activeDotColor: Colors.grey.shade800,
                  dotHeight: 7,
                  dotWidth: 7),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                MyButtonWidget(
                  iconData: Icons.nordic_walking_sharp,
                  label: 'W A L K',
                  onTap: () {},
                  color: const Color.fromARGB(255, 103, 146, 167),
                  opacity: 0.6,
                  borderRadius: 20.0,
                  iconSize: 30.0,
                  fontSize: 12.0,
                  fontFamily: 'San Francisco',
                ),
                MyButtonWidget(
                  iconData: Icons.edit_calendar,
                  label: 'J U R N A L',
                  onTap: () {},
                  color: const Color.fromARGB(255, 103, 146, 167),
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
                  color: const Color.fromARGB(255, 103, 146, 167),
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
                  color: const Color.fromARGB(255, 103, 146, 167),
                  opacity: 0.6,
                  borderRadius: 20.0,
                  iconSize: 30.0,
                  fontSize: 12.0,
                  fontFamily: 'San Francisco',
                ),
              ],
            ),
            const SizedBox(height: 30),
            MyRectangleWidget(
              onTap: () {
                print('Widget tapped');
              },
              color: Color.fromARGB(255, 103, 146, 167),
              borderRadius: 20.0,
              width: 360.0,
              height: 100.0,
              fontSize: 14.0,
              fontFamily: 'San Francisco',
              text: 'Przypomnienie',
              opacity: 0.6,
            ),
            MyRectangleWidget(
              onTap: () {
                print('Widget tapped');
              },
              color: Color.fromARGB(255, 103, 146, 167),
              borderRadius: 20.0,
              width: 360.0,
              height: 250.0,
              fontSize: 14.0,
              fontFamily: 'San Francisco',
              text: 'Cos innego',
              opacity: 0.6,
            ),
            MyRectangleWidget(
              onTap: () {
                print('Widget tapped');
              },
              color: Color.fromARGB(255, 103, 146, 167),
              borderRadius: 20.0,
              width: 360.0,
              height: 200.0,
              fontSize: 14.0,
              fontFamily: 'San Francisco',
              text: 'Jeszcze cos inniejszego',
              opacity: 0.6,
            ),
          ],
        ),
      ),
    );
  }
}
