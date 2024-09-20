import 'package:cloud_firestore/cloud_firestore.dart';

class Achievement {
  final String id;
  final String name;
  final String description;
  final String avatarUrl;
  final String category;
  final int stepsRequired;
  final int? totalSteps;
  final int? month;

  Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.avatarUrl,
    required this.category,
    required this.stepsRequired,
    this.totalSteps,
    this.month,
  });

  Achievement.fromDocument(DocumentSnapshot doc)
      : id = doc.id,
        name = doc.get('name') ?? '',
        description = doc.get('description') ?? '',
        avatarUrl = doc.get('avatarUrl') ?? '',
        category = doc.get('category') ?? '',
        stepsRequired = doc.get('stepsRequired') ?? 0,
        totalSteps = doc.data().toString().contains('totalSteps')
            ? doc.get('totalSteps')
            : null,
        month =
            doc.data().toString().contains('month') ? doc.get('month') : null;

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'avatarUrl': avatarUrl,
      'category': category,
      'stepsRequired': stepsRequired,
      if (totalSteps != null) 'totalSteps': totalSteps,
      if (month != null) 'month': month,
    };
  }
}
