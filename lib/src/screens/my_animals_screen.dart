import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:pet_diary/src/models/pet_model.dart';

class MyAnimalsScreen extends StatefulWidget {
  const MyAnimalsScreen({super.key});

  @override
  MyAnimalsScreenState createState() => MyAnimalsScreenState();
}

class MyAnimalsScreenState extends State<MyAnimalsScreen> {
  Box<Pet>? _petBox;
  final TextEditingController _newPetController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  String _selectedAvatar =
      'assets/images/dog_avatar_01.png'; // Default avatar path

  @override
  void initState() {
    super.initState();
    _openPetBox();
  }

  Future<void> _openPetBox() async {
    _petBox = await Hive.openBox<Pet>('petBox');
  }

  Future<void> _addNewPet() async {
    String newName = _newPetController.text.trim();
    String petAge = _ageController.text.trim();

    if (newName.isNotEmpty && petAge.isNotEmpty) {
      Pet newPet = Pet(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: newName,
        image: _selectedAvatar, // Use the selected avatar path
        age: petAge,
      );

      await _petBox?.add(newPet);
      _newPetController.clear();
      _ageController.clear();
      await _openPetBox();
    }
  }

  Future<void> _deletePet(int index) async {
    await _petBox?.deleteAt(index);
    setState(() {});
  }

  Future<void> _selectAvatarImage() async {
    final List<String> avatarOptions = [
      'assets/images/dog_avatar_01.png',
      'assets/images/dog_avatar_02.png',
      'assets/images/dog_avatar_03.png',
      'assets/images/dog_avatar_04.png',
      'assets/images/dog_avatar_05.png',
      'assets/images/dog_avatar_06.png',
      'assets/images/dog_avatar_07.png',
      'assets/images/dog_avatar_09.png',
      'assets/images/dog_avatar_010.png',
      'assets/images/dog_avatar_011.png',
      'assets/images/dog_avatar_012.png',
      'assets/images/dog_avatar_013.png',
      'assets/images/dog_avatar_014.png',
      'assets/images/dog_avatar_015.png',

      // Add more image paths from assets as needed
    ];

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Avatar'),
          content: Container(
            width: double.maxFinite,
            child: ListView.builder(
              itemCount: avatarOptions.length,
              itemBuilder: (context, index) {
                final avatarPath = avatarOptions[index];
                return ListTile(
                  title: Image.asset(avatarPath),
                  onTap: () {
                    setState(() {
                      _selectedAvatar = avatarPath;
                    });
                    Navigator.of(context).pop();
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const SizedBox(height: 50),
          _buildAddPetField(),
          FutureBuilder(
            future: _buildPetTable(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Expanded(child: snapshot.data!);
              } else {
                return const CircularProgressIndicator();
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAddPetField() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _newPetController,
                  decoration: const InputDecoration(
                    hintText: 'Enter new pet name',
                  ),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: _addNewPet,
                child: const Text('Add Pet'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _ageController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    hintText: 'Enter pet age',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: _selectAvatarImage,
            child: const Text('Select Avatar'),
          ),
        ],
      ),
    );
  }

  Future<Widget> _buildPetTable() async {
    _petBox = await Hive.openBox<Pet>('petBox');

    if (_petBox == null || _petBox!.isEmpty) {
      return const Center(
        child: Text('No pets available.'),
      );
    }

    return ListView.builder(
      itemCount: _petBox!.length,
      itemBuilder: (context, index) {
        final pet = _petBox!.getAt(index);
        return ListTile(
          title: Text('${pet!.name} - Age: ${pet.age}'),
          trailing: IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _deletePet(index),
          ),
        );
      },
    );
  }
}
