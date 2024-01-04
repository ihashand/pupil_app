import 'package:flutter/material.dart';

class MyAnimalsScreen extends StatelessWidget {
  const MyAnimalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: const Text('M Y  A N I M A L S'),
            backgroundColor: Theme.of(context).colorScheme.inversePrimary),
        body: const Center(
          child: Text('A L L  O F  M Y  A N I M A L S'),
        ));
  }
}
