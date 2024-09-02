import 'package:cloud_firestore/cloud_firestore.dart';

class VetVisitModel {
  late String id;
  late String petId;
  late String visitReason;
  late DateTime visitDate;
  late String additionalDetails;
  late List<String> selectedHealthIssues;
  late bool followUpRequired;
  late DateTime? followUpDate;
  late String notes;

  VetVisitModel({
    required this.id,
    required this.petId,
    required this.visitReason,
    required this.visitDate,
    this.additionalDetails = '',
    this.selectedHealthIssues = const [],
    this.followUpRequired = false,
    this.followUpDate,
    this.notes = '',
  });

  VetVisitModel.fromDocument(DocumentSnapshot doc) {
    id = doc.id;
    petId = doc.get('petId');
    visitReason = doc.get('visitReason');
    visitDate = (doc.get('visitDate') as Timestamp).toDate();
    additionalDetails = doc.get('additionalDetails') ?? '';
    selectedHealthIssues =
        List<String>.from(doc.get('selectedHealthIssues') ?? []);
    followUpRequired = doc.get('followUpRequired') ?? false;
    followUpDate = (doc.get('followUpDate') as Timestamp?)?.toDate();
    notes = doc.get('notes') ?? '';
  }

  Map<String, dynamic> toMap() {
    return {
      'petId': petId,
      'visitReason': visitReason,
      'visitDate': Timestamp.fromDate(visitDate),
      'additionalDetails': additionalDetails,
      'selectedHealthIssues': selectedHealthIssues,
      'followUpRequired': followUpRequired,
      'followUpDate':
          followUpDate != null ? Timestamp.fromDate(followUpDate!) : null,
      'notes': notes,
    };
  }
}
