import 'package:flutter/material.dart';
import 'package:pet_diary/bottom_app_bar.dart';

AppBar addPetAppBar(BuildContext context, {required bool showCloseButton}) {
  return AppBar(
    actions: [
      if (showCloseButton)
        IconButton(
          icon: const Icon(
            Icons.close,
          ),
          onPressed: () => Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const BotomAppBar()),
            (Route<dynamic> route) => false,
          ),
        ),
    ],
    backgroundColor: Theme.of(context).colorScheme.primary,
    elevation: 0,
    title: const Icon(
      Icons.pets,
      color: Color(0xff68a2b6),
      size: 35,
    ),
  );
}
