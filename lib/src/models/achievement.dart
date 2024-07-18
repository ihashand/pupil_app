import 'package:cloud_firestore/cloud_firestore.dart';

class Achievement {
  final String id;
  final String name;
  final String description;
  final String avatarUrl;
  final String category; // 'steps', 'nature', 'fantasy'
  final int stepsRequired;

  Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.avatarUrl,
    required this.category,
    required this.stepsRequired,
  });

  Achievement.fromDocument(DocumentSnapshot doc)
      : id = doc.id,
        name = doc.get('name') ?? '',
        description = doc.get('description') ?? '',
        avatarUrl = doc.get('avatarUrl') ?? '',
        category = doc.get('category') ?? '',
        stepsRequired = doc.get('stepsRequired') ?? 0;

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'avatarUrl': avatarUrl,
      'category': category,
      'stepsRequired': stepsRequired,
    };
  }
}
