import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pet_diary/src/models/others/achievement.dart';
import 'package:pet_diary/src/models/others/pet_model.dart';

class FriendsAchievementCard extends StatefulWidget {
  const FriendsAchievementCard({
    super.key,
    required this.context,
    required this.achievement,
    required this.petsWithAchievement,
  });

  final BuildContext context;
  final Achievement achievement;
  final List<Pet> petsWithAchievement;

  @override
  createState() => _FriendsAchievementCardState();
}

class _FriendsAchievementCardState extends State<FriendsAchievementCard> {
  String? _selectedPetName;
  int? _selectedPetIndex;
  Timer? _hideNameTimer;

  @override
  void dispose() {
    _hideNameTimer?.cancel();
    super.dispose();
  }

  void _togglePetNameDisplay(int index, String petName) {
    if (_selectedPetIndex == index) {
      // Jeśli to ten sam zwierzak, ukryj natychmiastowo
      setState(() {
        _selectedPetName = null;
        _selectedPetIndex = null;
      });
      _hideNameTimer?.cancel(); // Anuluj timer, jeśli jeszcze działa
    } else {
      // Jeśli to inny piesek, wyświetl imię
      setState(() {
        _selectedPetName = petName;
        _selectedPetIndex = index;
      });

      // Anuluj istniejący timer, jeśli jest uruchomiony
      _hideNameTimer?.cancel();

      // Ukryj imię po 5 sekundach
      _hideNameTimer = Timer(const Duration(seconds: 3), () {
        setState(() {
          _selectedPetName = null;
          _selectedPetIndex = null;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.primary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Container(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            CircleAvatar(
              backgroundImage: AssetImage(widget.achievement.avatarUrl),
              radius: 60,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 5.0, left: 15, right: 15),
              child: Text(
                widget.achievement.name,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColorDark,
                ),
              ),
            ),
            Text(
              widget.achievement.description,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                color: Theme.of(context).primaryColorDark,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children:
                    widget.petsWithAchievement.asMap().entries.map((entry) {
                  int index = entry.key;
                  Pet pet = entry.value;
                  return Stack(
                    clipBehavior: Clip.none,
                    children: [
                      GestureDetector(
                        onTap: () {
                          _togglePetNameDisplay(index, pet.name);
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5.0),
                          child: CircleAvatar(
                            backgroundImage: AssetImage(pet.avatarImage),
                            radius: 20,
                          ),
                        ),
                      ),
                      if (_selectedPetName != null &&
                          _selectedPetIndex == index)
                        Positioned(
                          top: -30,
                          left: 0,
                          right: 0,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  spreadRadius: 1,
                                  blurRadius: 5,
                                ),
                              ],
                            ),
                            child: Text(
                              _selectedPetName!,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).primaryColorDark,
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
