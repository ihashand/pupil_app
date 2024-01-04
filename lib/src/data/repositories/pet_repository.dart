import 'package:hive_flutter/hive_flutter.dart';
import 'package:pet_diary/src/data/services/hive_service.dart';
import 'package:pet_diary/src/models/pet_model.dart';

class PetRepository {
  final HiveService hiveService = HiveService();

  Future<void> init() async {
    await hiveService.initHive();
  }

  Future<Box<Pet>> openPetBox() async {
    return Hive.openBox<Pet>('pets');
  }

  Future<void> addPet(Pet pet) async {
    final Box<Pet> petBox = await openPetBox();
    await petBox.put(pet.id, pet);
  }

  Future<void> updatePet(Pet pet) async {
    final Box<Pet> petBox = await openPetBox();
    await petBox.put(pet.id, pet);
  }

  Future<void> deletePet(String petId) async {
    final Box<Pet> petBox = await openPetBox();
    await petBox.delete(petId);
  }

  Future<List<Pet>> getAllPets() async {
    final Box<Pet> petBox = await openPetBox();
    return petBox.values.toList();
  }

  Future<Pet?> getPetById(String petId) async {
    final Box<Pet> petBox = await openPetBox();
    return petBox.get(petId);
  }
}
