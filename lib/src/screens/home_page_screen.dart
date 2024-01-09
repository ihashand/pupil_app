import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:pet_diary/src/components/animal_card.dart';
import 'package:pet_diary/src/components/my_button_widget.dart';
import 'package:pet_diary/src/models/pet_model.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class HomePageScreen extends StatefulWidget {
  const HomePageScreen({
    super.key,
  });

  @override
  State<HomePageScreen> createState() => _HomePageScreenState();
}

class _HomePageScreenState extends State<HomePageScreen> {
  Box<Pet>? _petBox;
  int counter = 0;

  final _pageController = PageController();
  Future<void> _openPetBox() async {
    _petBox = await Hive.openBox<Pet>('petBox');
    setState(() {
      counter = _petBox!.length;
    });
  }

  @override
  void initState() {
    _openPetBox();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          const SizedBox(height: 25),
          SizedBox(
            height: 300,
            child: FutureBuilder(
              future: Hive.openBox<Pet>('petBox'),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done &&
                    _petBox != null &&
                    _petBox!.isNotEmpty) {
                  return PageView.builder(
                    controller: _pageController,
                    scrollDirection: Axis.horizontal,
                    itemCount: _petBox!.length,
                    itemBuilder: (context, index) {
                      final pet = _petBox!.getAt(index);
                      return AnimalCard(pet: pet!);
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
            controller: _pageController,
            count: counter,
            effect: ExpandingDotsEffect(
                activeDotColor: Colors.grey.shade800,
                dotHeight: 10,
                dotWidth: 10),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              MyButtonWidget(
                iconData: Icons.home, // przykładowa ikona
                label: 'C O S',
                onTap: () {},
                color: const Color.fromARGB(255, 145, 145, 145),
                opacity: 0.6,
                borderRadius: 20.0,
                iconSize: 30.0,
                fontSize: 12.0,
                fontFamily: 'Roboto',
              ),
              MyButtonWidget(
                iconData: Icons.add_home_outlined, // przykładowa ikona
                label: 'D O M',
                onTap: () {},
                color: const Color.fromARGB(255, 145, 145, 145),
                opacity: 0.6,
                borderRadius: 20.0,
                iconSize: 30.0,
                fontSize: 12.0,
                fontFamily: 'Roboto',
              ),
              MyButtonWidget(
                iconData: Icons.search, // przykładowa ikona
                label: 'S Z U K A J',
                onTap: () {},
                color: const Color.fromARGB(255, 145, 145, 145),
                opacity: 0.6,
                borderRadius: 20.0,
                iconSize: 30.0,
                fontSize: 12.0,
                fontFamily: 'Roboto',
              ),
              MyButtonWidget(
                iconData: Icons.person, // przykładowa ikona
                label: 'P R O F I L',
                onTap: () {},
                color: const Color.fromARGB(255, 145, 145, 145),
                opacity: 0.6,
                borderRadius: 20.0,
                iconSize: 30.0,
                fontSize: 12.0,
                fontFamily: 'Roboto',
              ),
            ],
          )
        ],
      ),
    );
  }
}
