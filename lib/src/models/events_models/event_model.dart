import 'package:cloud_firestore/cloud_firestore.dart';

class Event {
  late String id;
  late String title;
  late DateTime eventDate;
  late DateTime dateWhenEventAdded;
  late String userId;
  late String petId;
  late String description;

  String weightId = '';
  String temperatureId = '';
  String walkId = '';
  String waterId = '';
  String noteId = '';
  String pillId = '';
  String moodId = '';
  String stomachId = '';
  String stoolId = '';
  String urineId = '';
  String serviceId = '';
  String proffesionId = '';
  String personId = '';
  String careId = '';
  String behavioristId = '';
  String groomingId = '';
  String avatarImage = '';
  String emoticon = '';
  String vetVisitId = '';
  String vaccineId = '';
  String issueId = '';
  String vetAppointmentId = '';

  Event({
    required this.id,
    required this.title,
    required this.eventDate,
    required this.dateWhenEventAdded,
    required this.userId,
    required this.petId,
    required this.description,
    this.weightId = '',
    this.temperatureId = '',
    this.walkId = '',
    this.waterId = '',
    this.noteId = '',
    this.pillId = '',
    this.proffesionId = '',
    this.personId = '',
    this.avatarImage = '',
    this.emoticon = '',
    this.moodId = '',
    this.stomachId = '',
    this.stoolId = '',
    this.urineId = '',
    this.serviceId = '',
    this.careId = '',
    this.behavioristId = '',
    this.groomingId = '',
    this.issueId = '',
    this.vetVisitId = '',
    this.vaccineId = '',
    this.vetAppointmentId = '',
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
    issueId = doc.get('psychicId') ?? '';
    serviceId = doc.get('serviceId') ?? '';
    careId = doc.get('careId') ?? '';
    behavioristId = doc.get('behavioristId') ?? '';
    vaccineId = doc.get('vaccineId') ?? '';
    avatarImage = doc.get('avatarImage') ?? '';
    emoticon = doc.get('emoticon') ?? '';
    vetVisitId = doc.get('vetVisitId') ?? '';
    groomingId = doc.get('groomingId') ?? '';
    vetAppointmentId = doc.get('vetAppointmentId') ?? '';
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
      'psychicId': issueId,
      'stoolId': stoolId,
      'urineId': urineId,
      'careId': careId,
      'serviceId': serviceId,
      'stomachId': stomachId,
      'vetVisitId': vetVisitId,
      'vaccineId': vaccineId,
      'behavioristId': behavioristId,
      'groomingId': groomingId,
      'vetAppointmentId': vetAppointmentId,
    };
  }
}
