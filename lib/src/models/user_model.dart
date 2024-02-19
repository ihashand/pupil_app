import 'package:hive_flutter/hive_flutter.dart';

part 'user_model.g.dart';

@HiveType(typeId: 6)
class LocalUser extends HiveObject {
  @HiveField(0)
  String image;

  @HiveField(1)
  String uid;

  @HiveField(2)
  String id;

  LocalUser(this.image, this.uid, this.id);
}
