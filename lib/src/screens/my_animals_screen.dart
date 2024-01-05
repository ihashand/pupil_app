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

  @override
  void initState() {
    _openPetBox();
    super.initState();
  }

  Future<void> _openPetBox() async {
    _petBox = await Hive.openBox<Pet>('pets');
    setState(() {});
  }

  Future<void> _addNewPet() async {
    String newName = _newPetController.text.trim();
    if (newName.isNotEmpty) {
      Pet newPet = Pet(
          id: DateTime.now().millisecondsSinceEpoch.toString(), name: newName);
      await _petBox?.add(newPet);
      _newPetController.clear();
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MY ANIMALS'),
        backgroundColor: Theme.of(context).colorScheme.secondary,
      ),
      body: Column(
        children: [
          _buildAddPetField(),
          Expanded(child: _buildPetTable()),
        ],
      ),
    );
  }

  Widget _buildAddPetField() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
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
    );
  }

  Widget _buildPetTable() {
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
          title: Text(pet!.name),
        );
      },
    );
  }
}
