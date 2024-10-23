import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pet_diary/src/models/others/global_walk_model.dart';

class GlobalWalkService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  Future<void> addGlobalWalk(GlobalWalkModel globalWalk) async {
    if (_currentUser == null) return;

    await _firestore
        .collection('app_users')
        .doc(_currentUser.uid)
        .collection('global_walks')
        .doc(globalWalk.id)
        .set(globalWalk.toMap());
  }

  Future<GlobalWalkModel?> getGlobalWalkById(String walkId) async {
    if (_currentUser == null) return null;

    final docSnapshot = await _firestore
        .collection('app_users')
        .doc(_currentUser.uid)
        .collection('global_walks')
        .doc(walkId)
        .get();

    if (docSnapshot.exists) {
      return GlobalWalkModel.fromDocument(docSnapshot);
    }

    return null;
  }

  Future<void> updateGlobalWalk(GlobalWalkModel globalWalk) async {
    if (_currentUser == null) return;

    await _firestore
        .collection('app_users')
        .doc(_currentUser.uid)
        .collection('global_walks')
        .doc(globalWalk.id)
        .update(globalWalk.toMap());
  }

  Future<void> deleteGlobalWalk(String walkId) async {
    if (_currentUser == null) return;

    await _firestore
        .collection('app_users')
        .doc(_currentUser.uid)
        .collection('global_walks')
        .doc(walkId)
        .delete();
  }

  Stream<List<GlobalWalkModel>> getGlobalWalksStream() {
    if (_currentUser == null) return Stream.value([]);

    return _firestore
        .collection('app_users')
        .doc(_currentUser.uid)
        .collection('global_walks')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => GlobalWalkModel.fromDocument(doc))
            .toList());
  }
}
