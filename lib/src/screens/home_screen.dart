import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:pet_diary/src/screens/home_page_screen.dart';
import 'my_animals_screen.dart';
import 'profile_screen.dart';
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
    const ProfileScreen(),
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
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    getAppBarTitle(),
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.inversePrimary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        backgroundColor: Colors.transparent,
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: GNav(
        gap: 8,
        tabs: const [
          GButton(icon: Icons.home, text: "Home"),
          GButton(icon: Icons.pets, text: "Pupils"),
          GButton(icon: Icons.person, text: "Profile"),
          GButton(icon: Icons.settings, text: "Settings"),
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
