import 'package:cloud_firestore/cloud_firestore.dart';

class ReminderModel {
  late String id;
  late String name;
  late String petId;
  late String userId;
  late DateTime scheduledDate;
  late String emoji;
  late String description;
  late String eventId;
  late bool isActive;
  late int notificationId;
  ReminderModel({
    required this.id,
    required this.name,
    required this.petId,
    required this.userId,
    required this.scheduledDate,
    required this.emoji,
    this.description = '',
    this.eventId = '',
    this.isActive = true,
    required this.notificationId,
  });

  ReminderModel.fromDocument(DocumentSnapshot doc) {
    id = doc.id;
    name = doc.get('name') ?? '';
    petId = doc.get('petId') ?? '';
    userId = doc.get('userId') ?? '';
    scheduledDate =
        (doc.get('scheduledDate') as Timestamp?)?.toDate() ?? DateTime.now();
    emoji = doc.get('emoji') ?? '🔔';
    description = doc.get('description') ?? '';
    eventId = doc.get('eventId') ?? '';
    isActive = doc.get('isActive') ?? true;
    notificationId = doc.get('notificationId') ?? 0;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'petId': petId,
      'userId': userId,
      'scheduledDate': Timestamp.fromDate(scheduledDate),
      'emoji': emoji,
      'description': description,
      'eventId': eventId,
      'isActive': isActive,
      'notificationId': notificationId,
    };
  }
}
