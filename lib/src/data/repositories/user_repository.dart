import 'package:hive_flutter/hive_flutter.dart';
import 'package:pet_diary/src/models/user_model.dart';

class UserRepository {
  late Box<LocalUser> _hive;
  late List<LocalUser> _box;
  UserRepository._create();

  static Future<UserRepository> create() async {
    final component = UserRepository._create();
    await component._init();
    return component;
  }

  _init() async {
    _hive = await Hive.openBox<LocalUser>('localUserBox');
    _box = _hive.values.toList();
  }

  List<LocalUser> getEvents() {
    return _box;
  }

  Future<void> addEvent(LocalUser localUser) async {
    await _hive.put(localUser.id, localUser);
    await _init();
  }

  Future<void> updateEvent(LocalUser localUser) async {
    await _hive.put(localUser.id, localUser);
  }

  Future<void> deleteEvent(int index) async {
    await _hive.deleteAt(index);
  }

  Future<LocalUser?> getEventById(String userId) async {
    return _hive.get(userId);
  }
}
