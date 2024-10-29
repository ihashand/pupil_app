import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pet_diary/src/components/breed_data/dogs_breed_data.dart';
import 'package:pet_diary/src/helpers/others/helper_show_avatar_selection.dart';
import 'package:pet_diary/src/helpers/others/helper_show_bacground_selection.dart';
import 'package:pet_diary/src/helpers/others/generate_unique_id.dart';
import 'package:pet_diary/src/models/events_models/event_model.dart';
import 'package:pet_diary/src/models/events_models/event_weight_model.dart';
import 'package:pet_diary/src/models/others/pet_model.dart';
import 'package:pet_diary/src/screens/pet_screens/pet_dog_breed_selection_screen.dart';
import 'package:pet_diary/src/services/other_services/pet_services.dart';
import '../../providers/events_providers/event_provider.dart';
import '../../providers/events_providers/event_weight_provider.dart';

class PetEditScreen extends StatefulWidget {
  final WidgetRef ref;
  final String petId;

  const PetEditScreen({super.key, required this.ref, required this.petId});

  @override
  createState() => _PetEditScreenState();
}

class _PetEditScreenState extends State<PetEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _birthDateController;
  late TextEditingController _breedController;
  late TextEditingController _weightController;

  DateTime _selectedDate = DateTime.now();
  String _gender = 'Male';
  String _selectedAvatar = '';
  String _backgroundImage = '';
  double _initialWeight = 0.0;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _birthDateController = TextEditingController();
    _breedController = TextEditingController();
    _weightController = TextEditingController();
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
      _gender = pet.gender;

      var lastKnownWeight = await widget.ref
          .read(eventWeightServiceProvider)
          .getLastKnownWeight();

      _weightController.text =
          lastKnownWeight != null ? lastKnownWeight.weight.toString() : '';

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
    _weightController.dispose();
    super.dispose();
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

  Future<DateTime?> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).colorScheme.secondary,
              onPrimary: Theme.of(context).primaryColorDark,
              onSurface: Theme.of(context).primaryColorDark,
            ),
          ),
          child: child!,
        );
      },
    );
    return picked;
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Empty Fields',
            style: TextStyle(color: Theme.of(context).primaryColorDark),
          ),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'OK',
                style: TextStyle(color: Theme.of(context).primaryColorDark),
              ),
            ),
          ],
        );
      },
    );
  }

  void _saveWeight(double weight, String petId) {
    final String weightId = generateUniqueId();
    final String eventId = generateUniqueId();
    final DateTime currentDate = DateTime.now();

    final newWeight = EventWeightModel(
      id: weightId,
      eventId: eventId,
      petId: petId,
      weight: weight,
      dateTime: currentDate,
    );

    final newEvent = Event(
      id: eventId,
      eventDate: currentDate,
      dateWhenEventAdded: DateTime.now(),
      title: 'Weight',
      userId: FirebaseAuth.instance.currentUser!.uid,
      petId: petId,
      weightId: weightId,
      description: '$weight kg',
      avatarImage: _selectedAvatar,
      emoticon: '⚖️',
    );

    widget.ref.read(eventServiceProvider).addEvent(newEvent, petId);
    widget.ref.read(eventWeightServiceProvider).addWeight(newWeight);
  }

  void _savePet() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (_selectedAvatar.isEmpty ||
          _backgroundImage.isEmpty ||
          _weightController.text.isEmpty) {
        _showErrorDialog('Please complete all fields before saving.');
        return;
      }

      final User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        final petService = PetService();
        final updatedPet = Pet(
          id: widget.petId,
          name: _nameController.text,
          avatarImage: _selectedAvatar,
          age: DateFormat('dd/MM/yyyy').format(_selectedDate),
          gender: _gender,
          breed: _breedController.text,
          userId: currentUser.uid,
          dateTime: DateTime.now(),
          backgroundImage: _backgroundImage,
        );
        await petService.updatePet(updatedPet);
        _saveWeight(_initialWeight, updatedPet.id);

        // ignore: use_build_context_synchronously
        Navigator.of(context).pop(updatedPet);
      }
    }
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Delete Pet',
            style: TextStyle(color: Theme.of(context).primaryColorDark),
          ),
          content: const Text(
              'Are you sure you want to delete this pet? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: TextStyle(color: Theme.of(context).primaryColorDark),
              ),
            ),
            TextButton(
              onPressed: () {
                _deletePet();
                Navigator.pop(context);
              },
              child: Text(
                'Confirm',
                style: TextStyle(color: Theme.of(context).primaryColorDark),
              ),
            ),
          ],
        );
      },
    );
  }

  void _deletePet() async {
    await PetService().deletePet(widget.petId);
    // ignore: use_build_context_synchronously
    Navigator.of(context).popUntil(ModalRoute.withName('/'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        iconTheme: IconThemeData(color: Theme.of(context).primaryColorDark),
        title: Text(
          'E D I T  P E T',
          style: TextStyle(
              color: Theme.of(context).primaryColorDark,
              fontSize: 13,
              fontWeight: FontWeight.bold),
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
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildAvatarAndBackground(),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: _buildContainer([
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    child: _buildTextInput(_nameController, 'Name', '🐾'),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    child: _buildDateInput(context),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    child: _buildBreedInput(context),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    child: _buildWeightInput(),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    child: _buildGenderDropdown(),
                  ),
                  const SizedBox(height: 20),
                ]),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: MaterialButton(
            onPressed: () => _confirmDelete(context),
            color: Colors.red.withOpacity(0.85),
            textColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Text(
              'Delete Pet',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContainer(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildAvatarAndBackground() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(22),
          bottomRight: Radius.circular(22),
        ),
      ),
      child: Column(children: [
        Divider(color: Theme.of(context).colorScheme.secondary),
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
                        : const AssetImage(
                            'assets/images/dog_avatars/beagle.png'),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Avatar',
                    style: TextStyle(color: Theme.of(context).primaryColorDark),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => _selectBackground(context),
              child: Column(
                children: [
                  Container(
                    width: 100,
                    height: 70,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(
                        image: _backgroundImage.isNotEmpty
                            ? AssetImage(_backgroundImage)
                            : const AssetImage(
                                'assets/images/dog_backgrounds/dog_details_background_05.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Background',
                    style: TextStyle(color: Theme.of(context).primaryColorDark),
                  ),
                ],
              ),
            ),
          ],
        ),
      ]),
    );
  }

  Widget _buildTextInput(
      TextEditingController controller, String label, String emoji) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 12, right: 20),
          child: Text(emoji, style: const TextStyle(fontSize: 35)),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Theme.of(context).primaryColorDark),
        ),
      ),
      validator: (value) =>
          value == null || value.isEmpty ? 'Please enter $label' : null,
    );
  }

  Widget _buildDateInput(BuildContext context) {
    return TextFormField(
      controller: _birthDateController,
      readOnly: true,
      onTap: () async {
        final DateTime? picked = await _selectDate(context);
        if (picked != null) {
          setState(() {
            _selectedDate = picked;
            _birthDateController.text = DateFormat('dd/MM/yyyy').format(picked);
          });
        }
      },
      decoration: InputDecoration(
        labelText: 'Date of Birth',
        prefixIcon: const Padding(
          padding: EdgeInsets.only(left: 12, right: 20),
          child: Text('🎂', style: TextStyle(fontSize: 35)),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Theme.of(context).primaryColorDark),
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
            prefixIcon: const Padding(
              padding: EdgeInsets.only(left: 12, right: 20),
              child: Text('🐶', style: TextStyle(fontSize: 35)),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(color: Theme.of(context).primaryColorDark),
            ),
          ),
          readOnly: true,
        ),
      ),
    );
  }

  Widget _buildWeightInput() {
    return TextFormField(
      controller: _weightController,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      onChanged: (value) {
        _initialWeight = double.tryParse(value) ?? 0.0;
      },
      decoration: InputDecoration(
        labelText: 'Weight',
        prefixIcon: const Padding(
          padding: EdgeInsets.only(left: 12, right: 20),
          child: Text('⚖️', style: TextStyle(fontSize: 35)),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Theme.of(context).primaryColorDark),
        ),
      ),
      validator: (value) =>
          value == null || value.isEmpty ? 'Please enter Weight' : null,
    );
  }

  Widget _buildGenderDropdown() {
    return DropdownButtonFormField<String>(
      value: _gender,
      decoration: InputDecoration(
        labelText: 'Gender',
        prefixIcon: const Padding(
          padding: EdgeInsets.only(left: 12, right: 20),
          child: Text('♂️/♀️', style: TextStyle(fontSize: 25)),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Theme.of(context).primaryColorDark),
        ),
      ),
      onChanged: (value) => setState(() => _gender = value!),
      items: ['Male', 'Female'].map((value) {
        return DropdownMenuItem(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }
}
