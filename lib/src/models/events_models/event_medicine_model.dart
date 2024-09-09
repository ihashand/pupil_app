import 'package:cloud_firestore/cloud_firestore.dart';

class EventMedicineModel {
  late String id = '';
  late String name;
  DateTime? addDate;
  String? note;
  String? frequency;
  String? dosage;
  String? icon;
  late String eventId;
  late String petId;
  DateTime? endDate;
  DateTime? startDate;
  bool remindersEnabled = false;
  String emoji = '';
  String scheduleDetails = '';
  String medicineType = '';

  EventMedicineModel({
    required this.id,
    required this.name,
    required this.eventId,
    required this.petId,
    this.addDate,
    this.note,
    this.frequency,
    this.dosage,
    this.icon,
    this.endDate,
    this.startDate,
    this.remindersEnabled = false,
    this.emoji = '',
    this.scheduleDetails = '',
    this.medicineType = '',
  });
  bool get isCurrent {
    final now = DateTime.now();
    return startDate != null &&
        endDate != null &&
        now.isAfter(startDate!) &&
        now.isBefore(endDate!);
  }

  EventMedicineModel.fromDocument(DocumentSnapshot doc) {
    id = doc.id;
    name = doc.get('name') ?? '';
    eventId = doc.get('eventId') ?? '';
    petId = doc.get('petId') ?? '';
    addDate = (doc.get('addDate') as Timestamp?)?.toDate() ?? DateTime.now();
    note = doc.get('note') ?? '';
    frequency = doc.get('frequency') ?? '';
    dosage = doc.get('dosage') ?? '';
    icon = doc.get('icon') ?? '';
    endDate = (doc.get('endDate') as Timestamp?)?.toDate() ?? DateTime.now();
    startDate =
        (doc.get('startDate') as Timestamp?)?.toDate() ?? DateTime.now();
    remindersEnabled = doc.get('remindersEnabled') ?? false;
    emoji = doc.get('emoji') ?? '';
    scheduleDetails = doc.get('scheduleDetails') ?? '';
    medicineType = doc.get('medicineType') ?? '';
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'eventId': eventId,
      'petId': petId,
      'addDate': addDate,
      'note': note,
      'frequency': frequency,
      'dosage': dosage,
      'icon': icon,
      'endDate': endDate,
      'startDate': startDate,
      'remindersEnabled': remindersEnabled,
      'emoji': emoji,
      'scheduleDetails': scheduleDetails,
      'medicineType': medicineType,
    };
  }
}
