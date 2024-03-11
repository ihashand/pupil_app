import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pet_diary/src/models/pill_model.dart';

class PillRepository {
  late Box<Pill> _hive;
  late List<Pill> _box;

  PillRepository._create();

  static Future<PillRepository> create() async {
    final component = PillRepository._create();
    await component._init();
    return component;
  }

  _init() async {
    _hive = await Hive.openBox<Pill>('pillBox');
    _box = _hive.values.toList();
  }

  List<Pill> getPills() {
    return _box;
  }

  Future<void> addPill(Pill pill) async {
    await _hive.put(pill.id, pill);
    exportHiveDataToJson(_hive);
  }

  Future<void> updatePill(Pill pill) async {
    await _hive.put(pill.id, pill);
    exportHiveDataToJson(_hive);
  }

  Future<void> deletePill(String pillId) async {
    await _hive.delete(pillId);
    await _init();
  }

  Pill? getPillById(String pillId) {
    return _hive.get(pillId);
  }
}

Future<void> exportHiveDataToJson(Box<dynamic> hive) async {
  // Pobranie ścieżki katalogu dokumentów
  final directory = await getApplicationDocumentsDirectory();
  final path = directory.path;

  // Konwertowanie danych na JSON
  List<dynamic> jsonData = hive.values.map((item) => item.toJson()).toList();
  String jsonString = jsonEncode(jsonData);

  // Zapis danych do pliku
  File file = File('$path/hive_data_export.json');
  await file.writeAsString(jsonString, flush: true);

  if (kDebugMode) {
    print('Dane zostały zapisane w pliku: $path/hive_data_export.json');
  }
}
