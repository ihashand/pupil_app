import 'package:hive_flutter/hive_flutter.dart';
import 'package:pet_diary/src/models/temperature_model.dart';

class TemperatureRepository {
  late Box<Temperature> _hive;
  late List<Temperature> _box;

  TemperatureRepository._create();

  static Future<TemperatureRepository> create() async {
    final component = TemperatureRepository._create();
    await component._init();
    return component;
  }

  _init() async {
    _hive = await Hive.openBox<Temperature>('temperatureBox');
    _box = _hive.values.toList();
  }

  List<Temperature> getTemperature() {
    return _box;
  }

  Future<void> addTemperature(Temperature temperature) async {
    await _hive.put(temperature.id, temperature);
    await _init();
  }

  Future<void> updateTemperature(Temperature temperature) async {
    await _hive.put(temperature.id, temperature);
  }

  Future<void> deleteTemperature(int index) async {
    await _hive.deleteAt(index);
    await _init();
  }

  Temperature? getTemperatureById(String temperatureId) {
    return _hive.get(temperatureId);
  }
}
