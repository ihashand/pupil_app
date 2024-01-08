import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pet_diary/src/providers/theme_provider.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
          Column(children: [
            Container(
              decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(12)),
              margin: const EdgeInsets.all(25),
              padding: const EdgeInsets.all(12),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Dark Mode"),
                    CupertinoSwitch(
                        value:
                            Provider.of<ThemeProvider>(context, listen: false)
                                .isDarkMode,
                        onChanged: ((value) =>
                            Provider.of<ThemeProvider>(context, listen: false)
                                .toggleTheme())),
                  ]),
            ),
          ]),
          Container(
            decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(25),
            padding: const EdgeInsets.all(12),
            child: ListTile(
              title: const Text("Sign out"),
              onTap: () {
                // Navigate to homescreen
                Navigator.pop(context);
                FirebaseAuth.instance.signOut();
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 25.0, bottom: 25),
            child: ListTile(
              title: const Text("L O G O U T"),
              onTap: () {
                // Navigate to homescreen
                Navigator.pop(context);
                FirebaseAuth.instance.signOut();
              },
            ),
          )
        ]));
  }
}
