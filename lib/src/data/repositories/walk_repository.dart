import 'package:hive_flutter/hive_flutter.dart';
import 'package:pet_diary/src/models/walk_model.dart';

class WalkRepository {
  late Box<Walk> _hive;
  late List<Walk> _box;

  WalkRepository._create();

  static Future<WalkRepository> create() async {
    final component = WalkRepository._create();
    await component._init();
    return component;
  }

  _init() async {
    _hive = await Hive.openBox<Walk>('walkBox');
    _box = _hive.values.toList();
  }

  List<Walk> getWalks() {
    return _box;
  }

  Future<void> addWalk(Walk walk) async {
    await _hive.put(walk.id, walk);
    await _init();
  }

  Future<void> updateWeight(Walk walk) async {
    await _hive.put(walk.id, walk);
  }

  Future<void> deleteWalk(int index) async {
    await _hive.deleteAt(index);
    await _init();
  }

  Walk? getWalkById(String weightId) {
    return _hive.get(weightId);
  }
}
