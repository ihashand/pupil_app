import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pet_diary/src/models/others/vet_visit_model.dart';

class VetVisitService {
  final _firestore = FirebaseFirestore.instance;

  Future<void> addVetVisit(VetVisitModel visit) async {
    await _firestore.collection('vet_visits').doc(visit.id).set(visit.toMap());
  }

  Future<void> updateVetVisit(VetVisitModel visit) async {
    await _firestore
        .collection('vet_visits')
        .doc(visit.id)
        .update(visit.toMap());
  }

  Future<void> deleteVetVisit(String visitId) async {
    await _firestore.collection('vet_visits').doc(visitId).delete();
  }

  Future<VetVisitModel?> getVetVisitById(String visitId) async {
    final docSnapshot =
        await _firestore.collection('vet_visits').doc(visitId).get();

    return docSnapshot.exists ? VetVisitModel.fromDocument(docSnapshot) : null;
  }

  Future<List<VetVisitModel>> getVetVisits() async {
    final querySnapshot = await _firestore.collection('vet_visits').get();

    return querySnapshot.docs
        .map((doc) => VetVisitModel.fromDocument(doc))
        .toList();
  }
}
