import 'package:hive_flutter/hive_flutter.dart';
part 'weight_model.g.dart';

@HiveType(typeId: 5)
class Weight extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late double weight;
}
