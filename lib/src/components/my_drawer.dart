import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.background,
      child:
          Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Column(children: [
          // Drawer header
          DrawerHeader(
            child: Icon(
              Icons.pets_sharp,
              color: Theme.of(context).colorScheme.inversePrimary,
              size: 100,
            ),
          ),

          const SizedBox(height: 25),

          Padding(
            padding: const EdgeInsets.only(left: 25.0),
            child: ListTile(
              leading: Icon(
                Icons.home,
                color: Theme.of(context).colorScheme.inversePrimary,
              ),
              title: const Text(
                "H O M E",
              ),
              onTap: () {
                // Navigate to homescreen
                Navigator.pop(context);
              },
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(left: 25.0),
            child: ListTile(
              leading: Icon(
                Icons.person,
                color: Theme.of(context).colorScheme.inversePrimary,
              ),
              title: const Text("P R O F I L E"),
              onTap: () {
                // Navigate to homescreen
                Navigator.pop(context);

                Navigator.pushNamed(context, '/profile_screen');
              },
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(left: 25.0),
            child: ListTile(
              leading: Icon(
                Icons.group,
                color: Theme.of(context).colorScheme.inversePrimary,
              ),
              title: const Text("U S E R S"),
              onTap: () {
                // Navigate to homescreen
                Navigator.pop(context);
                Navigator.pushNamed(context, '/users_screen');
              },
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(left: 25.0),
            child: ListTile(
              leading: Icon(
                Icons.pets_outlined,
                color: Theme.of(context).colorScheme.inversePrimary,
              ),
              title: const Text("M Y  A N I M A L S"),
              onTap: () {
                // Navigate to homescreen
                Navigator.pop(context);
                Navigator.pushNamed(context, '/my_animals_screen');
              },
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(left: 25.0),
            child: ListTile(
              leading: Icon(
                Icons.settings,
                color: Theme.of(context).colorScheme.inversePrimary,
              ),
              title: const Text("S E T T I N G S"),
              onTap: () {
                // Navigate to homescreen
                Navigator.pop(context);
                Navigator.pushNamed(context, '/settings_screen');
              },
            ),
          ),
        ]),
        Padding(
          padding: const EdgeInsets.only(left: 25.0, bottom: 25),
          child: ListTile(
            leading: Icon(
              Icons.settings,
              color: Theme.of(context).colorScheme.inversePrimary,
            ),
            title: const Text("L O G O U T"),
            onTap: () {
              // Navigate to homescreen
              Navigator.pop(context);
              FirebaseAuth.instance.signOut();
            },
          ),
        )
      ]),
    );
  }
}
