import 'package:flutter/material.dart';
import 'package:pet_diary/src/screens/pet_setting_screen.dart';

AppBar foodScreenAppBar(BuildContext context, String petId) {
  return AppBar(
    backgroundColor: Theme.of(context).colorScheme.primary,
    elevation: 0,
    leading: IconButton(
      icon: Icon(Icons.close, color: Theme.of(context).primaryColorDark),
      onPressed: () => Navigator.of(context).pop(),
    ),
    title: Text(
      'F O O D',
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).primaryColorDark,
      ),
    ),
    centerTitle: true,
    actions: [
      IconButton(
        icon: Icon(Icons.settings, color: Theme.of(context).primaryColorDark),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PetSettingsScreen(
                petId: petId,
              ),
            ),
          );
        },
      ),
    ],
    bottom: PreferredSize(
      preferredSize: const Size.fromHeight(1.0),
      child: Divider(
        color: Theme.of(context).colorScheme.surface,
        height: 1.0,
      ),
    ),
  );
}
