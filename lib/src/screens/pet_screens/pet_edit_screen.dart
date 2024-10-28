// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/components/add_pet_steps/dogs_breed_data.dart';
import 'package:pet_diary/src/helpers/others/helper_show_bacground_selection.dart';
import 'package:pet_diary/src/screens/pet_screens/pet_dog_breed_selection_screen.dart';
import 'package:pet_diary/src/services/other_services/pet_services.dart';
import 'package:pet_diary/src/models/others/pet_model.dart';
import 'package:pet_diary/src/models/others/dog_breed_model.dart';
import 'package:pet_diary/src/providers/others_providers/pet_provider.dart';
import 'package:pet_diary/src/helpers/others/helper_show_avatar_selection.dart';

class PetEditScreen extends ConsumerStatefulWidget {
  final String petId;

  const PetEditScreen({super.key, required this.petId});

  @override
  createState() => PetEditScreenState();
}

class PetEditScreenState extends ConsumerState<PetEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController = TextEditingController();
  late final TextEditingController _birthDateController =
      TextEditingController();
  late final TextEditingController _breedController = TextEditingController();

  late DateTime _selectedDate = DateTime.now();
  String _gender = 'Male';
  String _selectedAvatar = '';
  String _backgroundImage = '';
  OverlayEntry? overlayEntry;

  @override
  void initState() {
    super.initState();
    _loadPetData();
  }

  Future<void> _loadPetData() async {
    var pet = await PetService().getPetById(widget.petId);
    if (pet != null) {
      _nameController.text = pet.name;
      _birthDateController.text = pet.age;
      _breedController.text = pet.breed;
      _selectedAvatar = pet.avatarImage;
      _backgroundImage = pet.backgroundImage;
      try {
        _selectedDate = DateFormat('dd/MM/yyyy').parse(pet.age);
      } catch (e) {
        _selectedDate = DateTime.now();
      }
      setState(() {});
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _birthDateController.dispose();
    _breedController.dispose();
    super.dispose();
  }

  Future<DateTime?> _selectDate(
      BuildContext context, DateTime initialDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).colorScheme.inversePrimary,
              onPrimary: Theme.of(context).primaryColorDark,
            ),
          ),
          child: child!,
        );
      },
    );
    return picked;
  }

  Future<void> _selectAvatar(BuildContext context) async {
    await showAvatarSelectionDialog(
      context: context,
      onAvatarSelected: (String path) {
        setState(() {
          _selectedAvatar = path;
        });
      },
    );
  }

  Future<void> _selectBackground(BuildContext context) async {
    await showBackgroundSelectionDialog(
      context: context,
      onBackgroundSelected: (String path) {
        setState(() {
          _backgroundImage = path;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        iconTheme: IconThemeData(color: Theme.of(context).primaryColorDark),
        title: Text(
          'E D I T',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
            color: Theme.of(context).primaryColorDark,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        actions: [
          IconButton(
            onPressed: _savePet,
            icon: Icon(
              Icons.check,
              color: Theme.of(context).primaryColorDark,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(15),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildAvatarAndBackground(),
              const SizedBox(height: 10),
              _buildContainer([
                _buildTextInput(_nameController, 'Name', Icons.pets),
                const SizedBox(height: 30),
                _buildDateInput(context),
              ]),
              const SizedBox(height: 10),
              _buildContainer([
                _buildBreedInput(context),
                const SizedBox(height: 30),
                _buildGenderDropdown(),
              ]),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SizedBox(
            width: double.infinity,
            child: MaterialButton(
              onPressed: () => _confirmDelete(context),
              color: Colors.red.withOpacity(0.85),
              textColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Text(
                'Delete your pet',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContainer(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildAvatarAndBackground() {
    return _buildContainer([
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          GestureDetector(
            onTap: () => _selectAvatar(context),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 35,
                  backgroundImage: _selectedAvatar.isNotEmpty
                      ? AssetImage(_selectedAvatar)
                      : const AssetImage('assets/default_avatar.png'),
                ),
                const SizedBox(height: 8),
                Text('Avatar',
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).primaryColorDark,
                    )),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => _selectBackground(context),
            child: Column(
              children: [
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    image: DecorationImage(
                      image: _backgroundImage.isNotEmpty
                          ? AssetImage(_backgroundImage)
                          : const AssetImage('assets/default_background.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text('Background',
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).primaryColorDark,
                    )),
              ],
            ),
          ),
        ],
      ),
    ]);
  }

  Widget _buildGenderDropdown() {
    return DropdownButtonFormField<String>(
      value: _gender,
      decoration: InputDecoration(
        labelText: 'Gender',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Theme.of(context).primaryColorDark),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Theme.of(context).primaryColorDark),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Theme.of(context).primaryColorDark),
        ),
        prefixIcon:
            Icon(Icons.transgender, color: Theme.of(context).primaryColorDark),
        labelStyle: TextStyle(color: Theme.of(context).primaryColorDark),
      ),
      onChanged: (newValue) => setState(() => _gender = newValue!),
      items: ['Male', 'Female'].map<DropdownMenuItem<String>>((value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }

  Widget _buildTextInput(
      TextEditingController controller, String label, IconData icon) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Theme.of(context).primaryColorDark),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Theme.of(context).primaryColorDark),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Theme.of(context).primaryColorDark),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Theme.of(context).primaryColorDark),
        ),
        labelStyle: TextStyle(color: Theme.of(context).primaryColorDark),
      ),
      validator: (value) =>
          value == null || value.isEmpty ? 'Please enter $label' : null,
    );
  }

  Widget _buildDateInput(BuildContext context) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: 'Date of Birth',
        prefixIcon: Icon(Icons.calendar_today,
            color: Theme.of(context).primaryColorDark),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Theme.of(context).primaryColorDark),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Theme.of(context).primaryColorDark),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Theme.of(context).primaryColorDark),
        ),
        labelStyle: TextStyle(color: Theme.of(context).primaryColorDark),
      ),
      child: TextButton(
        onPressed: () async {
          final DateTime? picked = await _selectDate(context, _selectedDate);
          if (picked != null) {
            setState(() {
              _selectedDate = picked;
              _birthDateController.text =
                  DateFormat('dd/MM/yyyy').format(picked);
            });
          }
        },
        style: TextButton.styleFrom(padding: EdgeInsets.zero),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            DateFormat('dd/MM/yyyy').format(_selectedDate),
            style: TextStyle(color: Theme.of(context).primaryColorDark),
          ),
        ),
      ),
    );
  }

  Widget _buildBreedInput(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final selectedBreed = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BreedSelectionScreen(
              dogBreedGroups: dogBreedGroups,
              onBreedSelected: (selectedBreed) {
                setState(() {
                  _breedController.text = selectedBreed;
                });
              },
            ),
          ),
        );

        if (selectedBreed != null && selectedBreed is String) {
          setState(() {
            _breedController.text = selectedBreed;
          });
        }
      },
      child: AbsorbPointer(
        child: TextFormField(
          controller: _breedController,
          decoration: InputDecoration(
            labelText: 'Breed',
            prefixIcon:
                Icon(Icons.category, color: Theme.of(context).primaryColorDark),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(color: Theme.of(context).primaryColorDark),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(color: Theme.of(context).primaryColorDark),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(color: Theme.of(context).primaryColorDark),
            ),
            labelStyle: TextStyle(color: Theme.of(context).primaryColorDark),
          ),
          readOnly: true,
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Delete pet',
            style: TextStyle(color: Theme.of(context).primaryColorDark),
          ),
          content: Text(
            'Are you sure you want to delete your pet? This operation cannot be undone.',
            style: TextStyle(color: Theme.of(context).primaryColorDark),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel',
                  style: TextStyle(color: Theme.of(context).primaryColorDark)),
            ),
            TextButton(
              onPressed: () {
                _deletePet(context);
                Navigator.pop(context);
              },
              child: Text('Confirm',
                  style: TextStyle(color: Theme.of(context).primaryColorDark)),
            ),
          ],
        );
      },
    );
  }

  void _deletePet(BuildContext context) async {
    await PetService().deletePet(widget.petId);
    Navigator.of(context).popUntil(ModalRoute.withName('/'));
  }

  void _savePet() async {
    if (_formKey.currentState?.validate() ?? false) {
      var pet = await ref.read(petServiceProvider).getPetById(widget.petId);
      Pet updatedPet = Pet(
        id: widget.petId,
        name: _nameController.text,
        avatarImage: _selectedAvatar,
        age: DateFormat('dd/MM/yyyy').format(_selectedDate),
        gender: _gender,
        breed: _breedController.text,
        userId: FirebaseAuth.instance.currentUser!.uid,
        dateTime: DateTime.now(),
        backgroundImage: pet!.backgroundImage,
      );
      await ref.read(petServiceProvider).updatePet(updatedPet);
      Navigator.of(context).pop();
    }
  }
}

class BreedSelectionMenu extends StatefulWidget {
  final Function(DogBreed) onBreedSelected;

  const BreedSelectionMenu({required this.onBreedSelected, super.key});

  @override
  State<BreedSelectionMenu> createState() => _BreedSelectionMenuState();
}

class _BreedSelectionMenuState extends State<BreedSelectionMenu> {
  String searchQuery = '';
  final TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildSearchBar(),
          Expanded(
            child: ListView.builder(
              itemCount: dogBreedGroups.length,
              itemBuilder: (context, groupIndex) {
                final group = dogBreedGroups[groupIndex];
                final filteredSections = group.sections
                    .map((section) {
                      final filteredBreeds = section.breeds
                          .where((breed) => breed.name
                              .toLowerCase()
                              .contains(searchQuery.toLowerCase()))
                          .toList();
                      return DogBreedSection(
                          sectionName: section.sectionName,
                          breeds: filteredBreeds);
                    })
                    .where((section) => section.breeds.isNotEmpty)
                    .toList();

                if (filteredSections.isEmpty) return Container();

                return ExpansionTile(
                  title: Text(
                    group.groupName,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColorDark),
                  ),
                  children: filteredSections.map((section) {
                    return ExpansionTile(
                      title: Text(section.sectionName,
                          style: TextStyle(
                              fontSize: 14,
                              color: Theme.of(context)
                                  .primaryColorDark
                                  .withOpacity(0.8))),
                      children: section.breeds.map((breed) {
                        return ListTile(
                          title: Text(
                            breed.name,
                            style: TextStyle(
                                color: Theme.of(context).primaryColorDark),
                          ),
                          onTap: () => widget.onBreedSelected(breed),
                        );
                      }).toList(),
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: TextField(
        controller: searchController,
        onChanged: (query) {
          setState(() {
            searchQuery = query;
          });
        },
        decoration: InputDecoration(
          hintText: 'Search breeds...',
          prefixIcon: Icon(Icons.search, color: Theme.of(context).primaryColor),
          filled: true,
          fillColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
