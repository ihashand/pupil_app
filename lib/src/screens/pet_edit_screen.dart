import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/components/add_pet_steps/dogs_breed_data.dart';
import 'package:pet_diary/src/components/events/delete_event.dart';
import 'package:pet_diary/src/models/pet_model.dart';
import 'package:pet_diary/src/providers/event_provider.dart';
import 'package:pet_diary/src/providers/pet_provider.dart';

class PetEditScreen extends ConsumerStatefulWidget {
  final String petId;

  const PetEditScreen({super.key, required this.petId});

  @override
  PetEditScreenState createState() => PetEditScreenState();
}

class PetEditScreenState extends ConsumerState<PetEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _birthDateController;
  late TextEditingController _breedController;
  late DateTime _selectedDate;
  String _gender = 'Male';
  String _selectedAvatar = '';

  @override
  void initState() {
    super.initState();
    _loadPetData();
  }

  Future<void> _loadPetData() async {
    var pet = ref.read(petRepositoryProvider).value?.getPetById(widget.petId);
    if (pet != null) {
      _nameController = TextEditingController(text: pet.name);
      _birthDateController = TextEditingController(text: pet.age);
      _breedController = TextEditingController(text: pet.breed);
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
        backgroundColor: Colors.transparent,
        title: const Text('Edit Pet'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _savePet,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 30,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
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
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
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
                              color:
                                  Theme.of(context).textTheme.bodyLarge!.color),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TypeAheadFormField(
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
                        .where((item) =>
                            item.toLowerCase().contains(pattern.toLowerCase()))
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
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: DropdownButtonFormField<String>(
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
              ),
              const SizedBox(
                height: 300,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 350,
                    child: SizedBox(
                      width: double.infinity,
                      child: MaterialButton(
                        onPressed: () {
                          _confirmDelete(context);
                        },
                        color: Colors.red,
                        textColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text('Delete Pet'),
                      ),
                    ),
                  ),
                ],
              ),
            ],
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

  void _deletePet(BuildContext context) {
    var currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      List<Pet>? pets = ref.read(petRepositoryProvider).value?.getPets();
      var allEvents = ref
          .read(eventRepositoryProvider)
          .value
          ?.getEvents()
          .where((element) => element.petId == widget.petId)
          .toList();

      final int indexToDeletePet =
          pets?.indexWhere((w) => w.id == widget.petId) ?? -1;
      if (allEvents != null) {
        for (var event in allEvents) {
          deleteEvents(
              ref, allEvents, (date, focusedDate) {}, event.id, widget.petId);
        }
      }

      ref.watch(petRepositoryProvider).value?.deletePet(indexToDeletePet);
      ref.invalidate(petRepositoryProvider);
      Navigator.of(context).popUntil(ModalRoute.withName('/'));
    }
  }

  void _savePet() {
    var currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      String userId = currentUser.uid;

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

      Pet updatedPet = Pet(
        id: widget.petId,
        name: _nameController.text,
        avatarImage: _selectedAvatar,
        age: DateFormat('dd/MM/yyyy').format(_selectedDate),
        gender: _gender,
        userId: userId,
        breed: _breedController.text,
        dateTime: DateTime.now(),
        backgroundImage: ref
            .read(petRepositoryProvider)
            .value!
            .getPetById(widget.petId)!
            .backgroundImage,
      );

      ref.watch(petRepositoryProvider).value?.updatePet(updatedPet);
      ref.invalidate(petRepositoryProvider);
      Navigator.of(context).pop();
    }
  }
}
