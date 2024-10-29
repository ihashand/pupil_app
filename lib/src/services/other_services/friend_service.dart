import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
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

    return _firestore.collection('friend_requests').snapshots().map(
        (snapshot) => snapshot.docs
            .map((doc) => FriendRequest.fromDocument(doc))
            .toList());
  }

  Future<void> addFriend(Friend friend, String correctId) async {
    await _firestore.collection('friends').doc(friend.id).set(friend.toMap());
  }

  Future<void> removeFriend(String friendId) async {
    final currentUserFriendDocs = await _firestore
        .collection('friends')
        .where('friendId', isEqualTo: friendId)
        .get();

    for (var doc in currentUserFriendDocs.docs) {
      await doc.reference.delete();
    }

    final friendDocs = await _firestore
        .collection('friends')
        .where('friendId', isEqualTo: _currentUser!.uid)
        .get();

    for (var doc in friendDocs.docs) {
      await doc.reference.delete();
    }
  }

  Future<void> sendFriendRequest(String toUserId) async {
    final currentUserId = _currentUser!.uid;

    // Sprawdzenie, czy zaproszenie już istnieje (w obie strony)
    final existingRequest = await _firestore
        .collection('friend_requests')
        .where('fromUserId', isEqualTo: currentUserId)
        .get();

    if (existingRequest.docs.isNotEmpty) {
      if (kDebugMode) {
        print('Zaproszenie zostało już wysłane.');
      }
      return;
    }

    // Sprawdzenie, czy użytkownik jest już znajomym (w obie strony)
    final existingFriend = await _firestore
        .collection('friends')
        .where('friendId', isEqualTo: toUserId)
        .get();

    if (existingFriend.docs.isNotEmpty) {
      if (kDebugMode) {
        print('Użytkownik jest już Twoim znajomym.');
      }
      return;
    }

    // Sprawdzenie, czy toUserId wysłał już zaproszenie do currentUserId
    final reverseRequest = await _firestore
        .collection('friend_requests')
        .where('fromUserId', isEqualTo: toUserId)
        .get();

    if (reverseRequest.docs.isNotEmpty) {
      if (kDebugMode) {
        print(
            'Masz już zaproszenie od tego użytkownika, możesz je zaakceptować.');
      }
      return;
    }

    // Jeśli nie ma duplikatów, dodaj nowe zaproszenie
    final timestamp = Timestamp.now();
    await _firestore.collection('friend_requests').add({
      'fromUserId': currentUserId,
      'toUserId': toUserId,
      'timestamp': timestamp,
    });
  }

  Future<void> cancelFriendRequest(String fromUserId, String toUserId) async {
    final friendRequestDoc = await _firestore
        .collection('friend_requests')
        .where('fromUserId', isEqualTo: fromUserId)
        .get();

    for (var doc in friendRequestDoc.docs) {
      await doc.reference.delete();
    }
  }

  Future<void> acceptFriendRequest(String fromUserId, String toUserId) async {
    await cancelFriendRequest(fromUserId, toUserId);

    // Add friend 1st time (fromUserId -> toUserId)
    await addFriend(
        Friend(
          id: fromUserId,
          friendId: fromUserId,
          userId: toUserId,
        ),
        toUserId);

    // Add friend 2nd time (toUserId -> fromUserId)
    await addFriend(
        Friend(id: toUserId, friendId: toUserId, userId: fromUserId),
        fromUserId);
  }

  Future<bool> hasPendingRequest(String toUserId) async {
    final currentUserId = _currentUser!.uid;

    final existingRequest = await _firestore
        .collection('friend_requests')
        .where('fromUserId', isEqualTo: currentUserId)
        .get();

    return existingRequest.docs.isNotEmpty;
  }
}
