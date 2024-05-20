// ignore_for_file: use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/components/add_pet_steps/dogs_breed_data.dart';
import 'package:pet_diary/src/data/services/pet_services.dart';
import 'package:pet_diary/src/models/pet_model.dart';
import 'package:pet_diary/src/providers/pet_provider.dart';

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
      try {
        _selectedDate = DateFormat('dd/MM/yyyy').parse(pet.age);
      } catch (e) {
        _selectedDate = DateTime.now();
      }
    }
    setState(() {});
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
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.black,
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    return picked;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Theme.of(context).primaryColorDark.withOpacity(0.7),
        ),
        title: Text(
          'E d i t',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Theme.of(context).primaryColorDark.withOpacity(0.7),
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        toolbarHeight: 50,
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _savePet();
              });
            },
            icon: Icon(
              Icons.check,
              color: Theme.of(context).primaryColorDark.withOpacity(0.7),
              size: 30,
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(15, 20, 15, 0),
            child: Container(
              height: 330,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Theme.of(context).colorScheme.primary,
              ),
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Name',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.pets),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter pet\'s name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 70,
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Data',
                        border: OutlineInputBorder(),
                        labelStyle: TextStyle(fontSize: 16),
                      ),
                      child: TextButton(
                        onPressed: () async {
                          final DateTime? picked =
                              await _selectDate(context, _selectedDate);
                          if (picked != null && picked != _selectedDate) {
                            setState(() {
                              _selectedDate = picked;
                              _birthDateController.text =
                                  DateFormat('yyyy-MM-dd').format(picked);
                            });
                          }
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                        ),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            DateFormat('dd/MM/yyyy').format(_selectedDate),
                            style: TextStyle(
                                color: Theme.of(context).primaryColorDark),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TypeAheadFormField(
                    textFieldConfiguration: TextFieldConfiguration(
                      controller: _breedController,
                      decoration: const InputDecoration(
                        labelText: 'Breed',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.category),
                      ),
                    ),
                    suggestionsCallback: (pattern) async {
                      List<String> allBreeds = dogBreedGroups
                          .expand((group) => group.sections)
                          .expand((section) => section.breeds)
                          .map((breed) => breed.name)
                          .toList();
                      return allBreeds
                          .where((item) => item
                              .toLowerCase()
                              .contains(pattern.toLowerCase()))
                          .toList();
                    },
                    itemBuilder: (context, suggestion) {
                      return ListTile(title: Text(suggestion.toString()));
                    },
                    onSuggestionSelected: (suggestion) {
                      _breedController.text = suggestion.toString();
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter pet\'s breed';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _gender,
                    decoration: const InputDecoration(
                      labelText: 'Gender',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.transgender),
                    ),
                    onChanged: (String? newValue) {
                      setState(() {
                        _gender = newValue!;
                      });
                    },
                    items: <String>['Male', 'Female']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
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
              onPressed: () {
                _confirmDelete(context);
              },
              color: Colors.red,
              textColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text('Delete Pet'),
            ),
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Confirm Delete',
            style: TextStyle(color: Theme.of(context).primaryColorDark),
          ),
          content: Text('Are you sure you want to delete your pet?',
              style: TextStyle(color: Theme.of(context).primaryColorDark)),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel',
                  style: TextStyle(color: Theme.of(context).primaryColorDark)),
            ),
            TextButton(
              onPressed: () {
                _deletePet(context);
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
    if (_nameController.text.isEmpty ||
        _breedController.text.isEmpty ||
        _selectedAvatar.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all fields.'),
        ),
      );
      return;
    }
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
