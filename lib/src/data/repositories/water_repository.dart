import 'package:hive_flutter/hive_flutter.dart';
import 'package:pet_diary/src/models/water_model.dart';

class WaterRepository {
  late Box<Water> _hive;
  late List<Water> _box;

  WaterRepository._create();

  static Future<WaterRepository> create() async {
    final component = WaterRepository._create();
    await component._init();
    return component;
  }

  _init() async {
    _hive = await Hive.openBox<Water>('waterBox');
    _box = _hive.values.toList();
  }

  List<Water> getWater() {
    return _box;
  }

  Future<void> addWater(Water water) async {
    await _hive.put(water.id, water);
    await _init();
  }

  Future<void> updateWater(Water water) async {
    await _hive.put(water.id, water);
  }

  Future<void> deleteWater(int index) async {
    await _hive.deleteAt(index);
    await _init();
  }

  Water? getWaterById(String waterId) {
    return _hive.get(waterId);
  }
}
