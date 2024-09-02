import 'package:cloud_firestore/cloud_firestore.dart';

class Event {
  late String id;
  late String title;
  late DateTime eventDate;
  late DateTime dateWhenEventAdded;
  late String userId;
  late String petId;
  late String weightId;
  late String temperatureId;
  late String walkId;
  late String waterId;
  late String noteId;
  late String pillId;
  late String moodId;
  late String stomachId;
  late String psychicId;
  late String stoolId;
  late String urineId;
  late String serviceId;
  late String description;
  late String proffesionId;
  late String personId;
  late String careId;
  late String avatarImage;
  late String emoticon;
  late String vetVisitId;
  late String vaccineId;

  Event({
    required this.id,
    required this.title,
    required this.eventDate,
    required this.dateWhenEventAdded,
    required this.userId,
    required this.petId,
    required this.weightId,
    required this.temperatureId,
    required this.walkId,
    required this.waterId,
    required this.noteId,
    required this.pillId,
    required this.description,
    required this.proffesionId,
    required this.personId,
    required this.avatarImage,
    required this.emoticon,
    required this.moodId,
    required this.stomachId,
    required this.stoolId,
    required this.urineId,
    required this.serviceId,
    required this.careId,
    required this.psychicId,
    this.vetVisitId = '',
    this.vaccineId = '',
  });

  Event.fromDocument(DocumentSnapshot doc) {
    id = doc.id;
    title = doc.get('title') ?? '';
    eventDate =
        (doc.get('eventDate') as Timestamp?)?.toDate() ?? DateTime.now();
    dateWhenEventAdded =
        (doc.get('dateWhenEventAdded') as Timestamp?)?.toDate() ??
            DateTime.now();
    userId = doc.get('userId') ?? '';
    petId = doc.get('petId') ?? '';
    weightId = doc.get('weightId') ?? '';
    temperatureId = doc.get('temperatureId') ?? '';
    walkId = doc.get('walkId') ?? '';
    waterId = doc.get('waterId') ?? '';
    noteId = doc.get('noteId') ?? '';
    pillId = doc.get('pillId') ?? '';
    description = doc.get('description') ?? '';
    proffesionId = doc.get('proffesionId') ?? '';
    personId = doc.get('personId') ?? '';
    moodId = doc.get('moodId') ?? '';
    stomachId = doc.get('stomachId') ?? '';
    stoolId = doc.get('stoolId') ?? '';
    urineId = doc.get('urineId') ?? '';
    psychicId = doc.get('psychicId') ?? '';
    serviceId = doc.get('serviceId') ?? '';
    careId = doc.get('careId') ?? '';
    vaccineId = doc.get('vaccineId') ?? '';
    avatarImage = doc.get('avatarImage') ?? '';
    emoticon = doc.get('emoticon') ?? '';
    vetVisitId = doc.get('vetVisitId') ?? '';
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'eventDate': eventDate,
      'dateWhenEventAdded': dateWhenEventAdded,
      'userId': userId,
      'petId': petId,
      'weightId': weightId,
      'temperatureId': temperatureId,
      'walkId': walkId,
      'waterId': waterId,
      'noteId': noteId,
      'pillId': pillId,
      'description': description,
      'proffesionId': proffesionId,
      'personId': personId,
      'avatarImage': avatarImage,
      'emoticon': emoticon,
      'moodId': moodId,
      'psychicId': psychicId,
      'stoolId': stoolId,
      'urineId': urineId,
      'careId': careId,
      'serviceId': serviceId,
      'stomachId': stomachId,
      'vetVisitId': vetVisitId,
      'vaccineId': vaccineId,
    };
  }
}
