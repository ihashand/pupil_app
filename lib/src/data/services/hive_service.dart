import 'package:hive_flutter/hive_flutter.dart';
import 'package:pet_diary/src/models/pet_model.dart';

class HiveService {
  bool _isHiveInitialized = false;

  Future<void> initHive() async {
    if (!_isHiveInitialized) {
      await Hive.initFlutter();
      Hive.registerAdapter<Pet>(PetAdapter());
      await Hive.openBox<Pet>('pets');
      _isHiveInitialized = true;
    }
  }

  Future<Box<dynamic>> openBox(String boxName) async {
    await initHive();
    return await Hive.openBox(boxName);
  }
}
