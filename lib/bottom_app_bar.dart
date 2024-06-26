import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:pet_diary/src/screens/home_screen.dart';
import 'src/screens/settings_screen.dart';

class BotomAppBar extends StatefulWidget {
  const BotomAppBar({super.key});

  @override
  BotomAppBarState createState() => BotomAppBarState();
}

class BotomAppBarState extends State<BotomAppBar> {
  final List<Widget> _screens = [
    const HomeScreen(),
    const SettingsScreen(),
  ];

  int _currentIndex = 0;

  String getAppBarTitle() {
    switch (_currentIndex) {
      case 0:
        return "Home";
      case 1:
        return "Settings";

      default:
        return "My Pupils";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: _screens[_currentIndex],
      bottomNavigationBar: GNav(
        gap: 5,
        tabs: const [
          GButton(
            icon: Icons.home,
            text: "Home",
            iconColor: Color.fromARGB(255, 103, 146, 167),
            hoverColor: Color.fromARGB(255, 103, 146, 167),
            iconActiveColor: Color.fromARGB(255, 103, 146, 167),
          ),
          GButton(
            icon: Icons.settings,
            text: "Settings",
            iconColor: Color.fromARGB(255, 103, 146, 167),
            hoverColor: Color.fromARGB(255, 103, 146, 167),
            iconActiveColor: Color.fromARGB(255, 103, 146, 167),
          ),
        ],
        selectedIndex: _currentIndex,
        onTabChange: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
