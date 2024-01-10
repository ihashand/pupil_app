import 'package:hive_flutter/hive_flutter.dart';
import 'package:pet_diary/src/models/pet_model.dart';

class PetRepository {
  late Box<Pet> _hive;
  late List<Pet> _box;
  PetRepository._create();

  static Future<PetRepository> create() async {
    final component = PetRepository._create();
    await component._init();
    return component;
  }

  _init() async {
    _hive = await Hive.openBox<Pet>('petBox');
    _box = _hive.values.toList();
  }

  List<Pet> getPets() {
    return _box;
  }

  Future<void> addPet(Pet pet) async {
    await _hive.put(pet.id, pet);
    await _init();
  }

  Future<void> updatePet(Pet pet) async {
    await _hive.put(pet.id, pet);
  }

  Future<void> deletePet(int index) async {
    await _hive.deleteAt(index);
  }

  Future<Pet?> getPetById(String petId) async {
    return _hive.get(petId);
  }
}
