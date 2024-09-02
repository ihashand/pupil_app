import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/components/add_pet_steps/dogs_breed_data.dart';
import 'package:pet_diary/src/helper/helper_show_bacground_selection.dart';
import 'package:pet_diary/src/tests/unit/services/other_services/pet_services.dart';
import 'package:pet_diary/src/models/others/pet_model.dart';
import 'package:pet_diary/src/providers/others_providers/pet_provider.dart';
import 'package:pet_diary/src/helper/helper_show_avatar_selection.dart';

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
  List<String> suggestions = [];
  OverlayEntry? overlayEntry;
  final LayerLink _layerLink = LayerLink();

  @override
  void initState() {
    super.initState();
    _loadPetData();
    _breedController.addListener(() {
      _updateSuggestions(_breedController.text);
      _showOverlay();
    });
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

  void _updateSuggestions(String query) {
    List<String> allBreeds = dogBreedGroups
        .expand((group) => group.sections)
        .expand((section) => section.breeds)
        .map((breed) => breed.name)
        .toList();

    setState(() {
      suggestions = allBreeds
          .where((item) => item.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });

    if (overlayEntry != null) {
      overlayEntry!.markNeedsBuild();
    }
  }

  void _showOverlay() {
    if (overlayEntry == null) {
      overlayEntry = _createOverlayEntry();
      Overlay.of(context).insert(overlayEntry!);
    } else {
      overlayEntry!.markNeedsBuild();
    }
  }

  void _removeOverlay() {
    overlayEntry?.remove();
    overlayEntry = null;
  }

  OverlayEntry _createOverlayEntry() {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    var size = renderBox.size;
    return OverlayEntry(
      builder: (context) => Positioned(
        width: size.width,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0.0, size.height + 5.0),
          child: Material(
            elevation: 4.0,
            child: ListView(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              children: suggestions.map((suggestion) {
                return ListTile(
                  title: Text(suggestion),
                  onTap: () {
                    _breedController.text = suggestion;
                    _removeOverlay();
                  },
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _birthDateController.dispose();
    _breedController.dispose();
    _removeOverlay();
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
            colorScheme: ColorScheme.light(
              primary: const Color(0xffdfd785).withOpacity(0.7),
              onPrimary: Colors.black,
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
        iconTheme:
            IconThemeData(color: Theme.of(context).primaryColorDark, size: 20),
        title: Text(
          'E D I T',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
            color: Theme.of(context).primaryColorDark,
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
              color: Theme.of(context).primaryColorDark,
              size: 20,
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(15, 20, 15, 0),
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () => _selectAvatar(context),
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: 'Avatar',
                            border: const OutlineInputBorder(),
                            prefixIcon: const Icon(Icons.account_circle),
                            labelStyle: TextStyle(
                              fontSize: 16,
                              color: Theme.of(context).primaryColorDark,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide(
                                color: Theme.of(context).primaryColorDark,
                              ),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(right: 35.0),
                                child: CircleAvatar(
                                  radius: 30,
                                  backgroundColor: Colors.transparent,
                                  backgroundImage: _selectedAvatar.isNotEmpty
                                      ? AssetImage(_selectedAvatar)
                                      : null,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Name',
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.pets),
                          labelStyle: TextStyle(
                            fontSize: 16,
                            color: Theme.of(context).primaryColorDark,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide(
                              color: Theme.of(context).primaryColorDark,
                            ),
                          ),
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
                          decoration: InputDecoration(
                            labelText: 'Date',
                            border: const OutlineInputBorder(),
                            labelStyle: TextStyle(
                              fontSize: 16,
                              color: Theme.of(context).primaryColorDark,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide(
                                color: Theme.of(context).primaryColorDark,
                              ),
                            ),
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
                      CompositedTransformTarget(
                        link: _layerLink,
                        child: TextField(
                          controller: _breedController,
                          decoration: InputDecoration(
                            labelText: 'Breed',
                            border: const OutlineInputBorder(),
                            prefixIcon: const Icon(Icons.category),
                            labelStyle: TextStyle(
                              fontSize: 16,
                              color: Theme.of(context).primaryColorDark,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide(
                                color: Theme.of(context).primaryColorDark,
                              ),
                            ),
                          ),
                          onChanged: (query) {
                            _updateSuggestions(query);
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _gender,
                        decoration: InputDecoration(
                          labelText: 'Gender',
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.transgender),
                          labelStyle: TextStyle(
                            fontSize: 16,
                            color: Theme.of(context).primaryColorDark,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide(
                              color: Theme.of(context).primaryColorDark,
                            ),
                          ),
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
                      const SizedBox(height: 16),
                      GestureDetector(
                        onTap: () => _selectBackground(context),
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: 'Background',
                            border: const OutlineInputBorder(),
                            prefixIcon: const Icon(Icons.wallpaper),
                            labelStyle: TextStyle(
                              fontSize: 16,
                              color: Theme.of(context).primaryColorDark,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide(
                                color: Theme.of(context).primaryColorDark,
                              ),
                            ),
                          ),
                          child: Container(
                            height: 80,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: _backgroundImage.isNotEmpty
                                    ? AssetImage(_backgroundImage)
                                    : const AssetImage(
                                        'assets/default_background.png'),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
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
              child: const Text('Delete your pet'),
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
            'Delete pupil',
            style: TextStyle(color: Theme.of(context).primaryColorDark),
          ),
          content: Text(
              'Are you sure you want to delete your pet? You cannot undo this operation.',
              style: TextStyle(
                  color: Theme.of(context).primaryColorDark, fontSize: 13)),
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
    // ignore: use_build_context_synchronously
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

    // ignore: use_build_context_synchronously
    Navigator.of(context).pop();
  }
}
