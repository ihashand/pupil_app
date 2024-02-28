import 'package:hive_flutter/hive_flutter.dart';
import 'package:pet_diary/src/models/event_model.dart';
import 'package:pet_diary/src/models/note_model.dart';
import 'package:pet_diary/src/models/temperature_model.dart';
import 'package:pet_diary/src/models/user_model.dart';
import 'package:pet_diary/src/models/pet_model.dart';
import 'package:pet_diary/src/models/walk_model.dart';
import 'package:pet_diary/src/models/water_model.dart';
import 'package:pet_diary/src/models/weight_model.dart';

class HiveService {
  bool _isHiveInitialized = false;

  Future<void> initHive() async {
    if (!_isHiveInitialized) {
      await Hive.initFlutter();

      Hive.registerAdapter<Pet>(PetAdapter());
      await Hive.openBox<Pet>('petBox');

      Hive.registerAdapter<Event>(EventAdapter());
      await Hive.openBox<Event>('eventBox');

      Hive.registerAdapter<LocalUser>(LocalUserAdapter());
      await Hive.openBox<LocalUser>('localUserBox');

      Hive.registerAdapter<Weight>(WeightAdapter());
      await Hive.openBox<Weight>('weightAdapter');

      Hive.registerAdapter<Temperature>(TemperatureAdapter());
      await Hive.openBox<Temperature>('temperatureBox');

      Hive.registerAdapter<Walk>(WalkAdapter());
      await Hive.openBox<Walk>('walkBox');

      Hive.registerAdapter<Water>(WaterAdapter());
      await Hive.openBox<Water>('waterBox');

      Hive.registerAdapter<Note>(NoteAdapter());
      await Hive.openBox<Note>('noteBox');

      _isHiveInitialized = true;
    }
  }

  Future<Box<dynamic>> openBox(String boxName) async {
    await initHive();
    return await Hive.openBox(boxName);
  }
}
