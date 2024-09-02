import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pet_diary/src/models/others/friend_model.dart';
import 'package:pet_diary/src/models/others/friend_request_model.dart';

class FriendService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _currentUser = FirebaseAuth.instance.currentUser;

  Stream<List<Friend>> getFriendsStream() {
    if (_currentUser == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('friends')
        .where('userId', isEqualTo: _currentUser.uid)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Friend.fromDocument(doc)).toList());
  }

  Stream<List<FriendRequest>> getFriendRequestsStream() {
    if (_currentUser == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('app_users')
        .doc(_currentUser.uid)
        .collection('friend_requests')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => FriendRequest.fromDocument(doc))
            .toList());
  }

  Future<void> addFriend(Friend friend) async {
    await _firestore.collection('friends').add(friend.toMap());
  }

  Future<void> removeFriend(String friendId) async {
    final currentUserId = _currentUser!.uid;

    final currentUserFriendDocs = await _firestore
        .collection('friends')
        .where('userId', isEqualTo: currentUserId)
        .where('friendId', isEqualTo: friendId)
        .get();

    for (var doc in currentUserFriendDocs.docs) {
      await _firestore.collection('friends').doc(doc.id).delete();
    }

    final friendDocs = await _firestore
        .collection('friends')
        .where('userId', isEqualTo: friendId)
        .where('friendId', isEqualTo: currentUserId)
        .get();

    for (var doc in friendDocs.docs) {
      await _firestore.collection('friends').doc(doc.id).delete();
    }
  }

  Future<void> sendFriendRequest(String toUserId) async {
    final currentUserId = _currentUser!.uid;
    final timestamp = Timestamp.now();

    await _firestore
        .collection('app_users')
        .doc(toUserId)
        .collection('friend_requests')
        .add({
      'fromUserId': currentUserId,
      'toUserId': toUserId,
      'timestamp': timestamp,
    });
  }

  Future<void> cancelFriendRequest(String toUserId) async {
    final currentUserId = _currentUser!.uid;
    final querySnapshot = await _firestore
        .collection('app_users')
        .doc(toUserId)
        .collection('friend_requests')
        .where('fromUserId', isEqualTo: currentUserId)
        .get();

    for (var doc in querySnapshot.docs) {
      await doc.reference.delete();
    }
  }

  Future<void> acceptFriendRequest(String fromUserId, String toUserId) async {
    await addFriend(Friend(id: '', friendId: fromUserId, userId: toUserId));
    await addFriend(Friend(id: '', friendId: toUserId, userId: fromUserId));

    final friendRequestDoc = await _firestore
        .collection('app_users')
        .doc(toUserId)
        .collection('friend_requests')
        .where('fromUserId', isEqualTo: fromUserId)
        .get();

    for (var doc in friendRequestDoc.docs) {
      await doc.reference.delete();
    }
  }

  Future<void> declineFriendRequest(String fromUserId, String toUserId) async {
    final friendRequestDoc = await _firestore
        .collection('app_users')
        .doc(toUserId)
        .collection('friend_requests')
        .where('fromUserId', isEqualTo: fromUserId)
        .get();

    for (var doc in friendRequestDoc.docs) {
      await doc.reference.delete();
    }
  }
}
