import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:pet_diary/src/screens/home_page_screen.dart';
import 'my_animals_screen.dart';
import 'my_calendar_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  final List<Widget> _screens = [
    const HomePageScreen(),
    const MyAnimalsScreen(),
    MyCalendarScreen(),
    const SettingsScreen(),
  ];

  int _currentIndex = 0;

  String getAppBarTitle() {
    switch (_currentIndex) {
      case 0:
        return "Home";
      case 1:
        return "My Animals";
      case 2:
        return "Profile";
      case 3:
        return "Settings";
      default:
        return "My Pupils";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            icon: Icons.pets,
            text: "Pupils",
            iconColor: Color.fromARGB(255, 103, 146, 167),
            hoverColor: Color.fromARGB(255, 103, 146, 167),
            iconActiveColor: Color.fromARGB(255, 103, 146, 167),
          ),
          GButton(
            icon: Icons.calendar_month,
            text: "Callendar",
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
