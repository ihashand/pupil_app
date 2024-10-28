import 'package:cloud_firestore/cloud_firestore.dart';

class Pet {
  late String id;
  late String name;
  late String avatarImage;
  late String age;
  late String gender;
  late String userId;
  late String breed;
  late DateTime dateTime;
  late String backgroundImage;
  List<String>? achievementIds;
  List<String>? sharedWithIds;

  Pet({
    required this.id,
    required this.name,
    required this.avatarImage,
    required this.age,
    required this.gender,
    required this.userId,
    required this.breed,
    required this.dateTime,
    required this.backgroundImage,
    this.achievementIds,
    this.sharedWithIds,
  });

  Pet.fromDocument(DocumentSnapshot doc) {
    id = doc.id;
    name = doc.get('name') ?? '';
    avatarImage = doc.get('avatarImage') ?? '';
    age = doc.get('age') ?? '';
    gender = doc.get('gender') ?? '';
    userId = doc.get('userId') ?? '';
    breed = doc.get('breed') ?? '';
    dateTime = (doc.get('dateTime') as Timestamp?)?.toDate() ?? DateTime.now();
    backgroundImage = doc.get('backgroundImage') ?? '';
    achievementIds = doc.data().toString().contains('achievementIds')
        ? List<String>.from(doc.get('achievementIds'))
        : [];
    sharedWithIds = doc.data().toString().contains('sharedWithIds')
        ? List<String>.from(doc.get('sharedWithIds'))
        : [];
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'avatarImage': avatarImage,
      'age': age,
      'gender': gender,
      'userId': userId,
      'breed': breed,
      'dateTime': dateTime,
      'backgroundImage': backgroundImage,
      'achievementIds': achievementIds ?? [],
      'sharedWith': sharedWithIds ?? [],
    };
  }
}
