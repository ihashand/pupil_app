import 'package:flutter/material.dart';
import 'package:pet_diary/bottom_app_bar.dart';

AppBar addPetAppBar(BuildContext context, {required bool showCloseButton}) {
  return AppBar(
    actions: [
      if (showCloseButton)
        IconButton(
          icon: Icon(
            Icons.close,
            color: Theme.of(context).primaryColorDark.withOpacity(0.5),
          ),
          onPressed: () => Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const BotomAppBar()),
            (Route<dynamic> route) => false,
          ),
        ),
    ],
    backgroundColor: Colors.transparent,
    foregroundColor: Theme.of(context).primaryColorDark.withOpacity(0.5),
    elevation: 0,
    title: Icon(
      Icons.pets,
      color: Theme.of(context).primaryColorDark.withOpacity(0.15),
      size: 55,
    ),
  );
}
