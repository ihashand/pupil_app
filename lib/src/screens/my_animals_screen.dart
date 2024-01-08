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
        image:
            'assets/images/lilu.png', // TODO replace with adding image function
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
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
