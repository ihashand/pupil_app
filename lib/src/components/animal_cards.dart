import 'package:flutter/material.dart';

class AnimalCards extends StatelessWidget {
  const AnimalCards({super.key});

  @override
  Widget build(BuildContext context) {
    return // Cards
        Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: Container(
        width: 300,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
            color: Theme.of(context).cardColor.withOpacity(0.40),
            //todo dodac transparentnosc
            borderRadius: BorderRadius.circular(41)),
        child: Column(children: [
          Text(
            'L I L U ',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.inversePrimary),
          ),
          Text(
            '3 lata',
            style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.inversePrimary),
          ),
          const SizedBox(height: 8),
          const CircleAvatar(
            backgroundImage: AssetImage('assets/images/lilu.png'),
            radius: 50,
          ),
        ]),
      ),
    );
  }
}
