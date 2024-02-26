import 'package:hive_flutter/hive_flutter.dart';
import 'package:pet_diary/src/models/weight_model.dart';

class WeightRepository {
  late Box<Weight> _hive;
  late List<Weight> _box;

  WeightRepository._create();

  static Future<WeightRepository> create() async {
    final component = WeightRepository._create();
    await component._init();
    return component;
  }

  _init() async {
    _hive = await Hive.openBox<Weight>('weightBox');
    _box = _hive.values.toList();
  }

  List<Weight> getWeights() {
    return _box;
  }

  Future<void> addWeight(Weight weight) async {
    await _hive.put(weight.id, weight);
    await _init();
  }

  Future<void> updateWeight(Weight weight) async {
    await _hive.put(weight.id, weight);
  }

  Future<void> deleteWeight(int index) async {
    await _hive.deleteAt(index);
    await _init();
  }

  Weight? getWeightById(String weightId) {
    return _hive.get(weightId);
  }
}
