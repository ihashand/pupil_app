import 'package:flutter/material.dart';
import 'package:pet_diary/src/helpers/extensions/string_extension.dart';
import 'package:pet_diary/src/models/others/pet_model.dart';

class PetProfileScreen extends StatelessWidget {
  final Pet pet;

  const PetProfileScreen({required this.pet, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(pet.name.capitalizeWord()),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPetInfo(context),
              const SizedBox(height: 20),
              _buildPetStatistics(context),
              const SizedBox(height: 20),
              _buildPetAchievements(context),
              const SizedBox(height: 20),
              _buildPetRoutes(context), // Miejsce na przyszłe "routes"
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPetInfo(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: CircleAvatar(
            backgroundImage: AssetImage(pet.avatarImage),
            radius: 60,
          ),
        ),
        const SizedBox(height: 20),
        Text('Name: ${pet.name}', style: _infoTextStyle(context)),
        Text('Gender: ${pet.gender}', style: _infoTextStyle(context)),
        Text('Age: ${pet.age} years', style: _infoTextStyle(context)),
        Text('Breed: ${pet.breed}', style: _infoTextStyle(context)),
      ],
    );
  }

  Widget _buildPetStatistics(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Statistics', style: _sectionTitleStyle(context)),
        const SizedBox(height: 10),
        Text('Steps: 5000', style: _infoTextStyle(context)),
        Text('Distance: 10 km', style: _infoTextStyle(context)),
      ],
    );
  }

  Widget _buildPetAchievements(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Achievements', style: _sectionTitleStyle(context)),
        const SizedBox(height: 10),
        Text('Achievement 1: First Walk', style: _infoTextStyle(context)),
        Text('Achievement 2: 1000 Steps', style: _infoTextStyle(context)),
      ],
    );
  }

  Widget _buildPetRoutes(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Routes', style: _sectionTitleStyle(context)),
        const SizedBox(height: 10),
        Text('No routes available yet.', style: _infoTextStyle(context)),
      ],
    );
  }

  TextStyle _infoTextStyle(BuildContext context) {
    return TextStyle(
      fontSize: 16,
      color: Theme.of(context).primaryColorDark,
    );
  }

  TextStyle _sectionTitleStyle(BuildContext context) {
    return TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: Theme.of(context).primaryColorDark,
    );
  }
}
