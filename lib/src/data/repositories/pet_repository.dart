import 'package:hive_flutter/hive_flutter.dart';
import 'package:pet_diary/src/models/pet_model.dart';

class PetRepository {
  late Box<Pet> _hive;
  late List<Pet> _box;
  PetRepository();

  List<Pet> getPets() {
    _hive = Hive.box<Pet>('pets');
    _box = _hive.values.toList();
    return _box;
  }

  List<Pet> addPet(Pet pet) {
    _hive.add(pet);
    return _hive.values.toList();
  }

  List<Pet> updatePet(Pet pet) {
    _hive.put(pet.id, pet);
    return _hive.values.toList();
  }

  List<Pet> deletePet(String petId) {
    _hive.delete(petId);
    return _hive.values.toList();
  }

  Pet? getPetById(String petId) {
    return _hive.get(petId);
  }
}
