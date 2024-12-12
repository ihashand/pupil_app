import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:pet_diary/src/models/others/friend_model.dart';
import 'package:pet_diary/src/models/others/friend_request_model.dart';

class FriendService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _friendsSubscription;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>?
      _friendRequestsSubscription;

  final StreamController<List<Friend>> _friendsController =
      StreamController<List<Friend>>.broadcast();
  final StreamController<List<FriendRequest>> _friendRequestsController =
      StreamController<List<FriendRequest>>.broadcast();

  /// Stream of friends for the logged-in user.
  Stream<List<Friend>> getFriendsStream() {
    if (_currentUser == null) {
      return Stream.value([]);
    }

    _friendsSubscription = _firestore
        .collection('friends')
        .where('userId', isEqualTo: _currentUser!.uid)
        .snapshots()
        .listen((snapshot) {
      final friends =
          snapshot.docs.map((doc) => Friend.fromDocument(doc)).toList();
      _friendsController.add(friends);
    }, onError: (error) {
      if (kDebugMode) {
        print('Error fetching friends: $error');
      }
      _friendsController.addError(error);
    });

    return _friendsController.stream;
  }

  /// Stream of friend requests for the logged-in user.
  Stream<List<FriendRequest>> getFriendRequestsStream() {
    if (_currentUser == null) {
      return Stream.value([]);
    }

    _friendRequestsSubscription =
        _firestore.collection('friend_requests').snapshots().listen((snapshot) {
      final requests =
          snapshot.docs.map((doc) => FriendRequest.fromDocument(doc)).toList();
      _friendRequestsController.add(requests);
    }, onError: (error) {
      if (kDebugMode) {
        print('Error fetching friend requests: $error');
      }
      _friendRequestsController.addError(error);
    });

    return _friendRequestsController.stream;
  }

  /// Add a new friend.
  Future<void> addFriend(Friend friend) async {
    try {
      await _firestore.collection('friends').doc(friend.id).set(friend.toMap());
    } catch (e) {
      if (kDebugMode) {
        print('Error adding friend: $e');
      }
      throw Exception('Failed to add friend');
    }
  }

  /// Remove a friend by ID.
  Future<void> removeFriend(String friendId) async {
    try {
      // Remove friendships in both directions
      final userDocs = await _firestore
          .collection('friends')
          .where('friendId', isEqualTo: friendId)
          .where('userId', isEqualTo: _currentUser!.uid)
          .get();

      for (var doc in userDocs.docs) {
        await doc.reference.delete();
      }

      final friendDocs = await _firestore
          .collection('friends')
          .where('friendId', isEqualTo: _currentUser!.uid)
          .where('userId', isEqualTo: friendId)
          .get();

      for (var doc in friendDocs.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error removing friend: $e');
      }
      throw Exception('Failed to remove friend');
    }
  }

  /// Send a friend request.
  Future<void> sendFriendRequest(String toUserId) async {
    final currentUserId = _currentUser!.uid;

    try {
      // Check for existing friend or request in both directions
      final existingRequest = await _firestore
          .collection('friend_requests')
          .where('fromUserId', isEqualTo: currentUserId)
          .where('toUserId', isEqualTo: toUserId)
          .get();

      if (existingRequest.docs.isNotEmpty) {
        if (kDebugMode) {
          print('Friend request already sent.');
        }
        return;
      }

      final existingFriend = await _firestore
          .collection('friends')
          .where('userId', isEqualTo: currentUserId)
          .where('friendId', isEqualTo: toUserId)
          .get();

      if (existingFriend.docs.isNotEmpty) {
        if (kDebugMode) {
          print('User is already your friend.');
        }
        return;
      }

      final reverseRequest = await _firestore
          .collection('friend_requests')
          .where('fromUserId', isEqualTo: toUserId)
          .where('toUserId', isEqualTo: currentUserId)
          .get();

      if (reverseRequest.docs.isNotEmpty) {
        if (kDebugMode) {
          print('You have a pending request from this user.');
        }
        return;
      }

      // Add new friend request
      await _firestore.collection('friend_requests').add({
        'fromUserId': currentUserId,
        'toUserId': toUserId,
        'timestamp': Timestamp.now(),
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error sending friend request: $e');
      }
      throw Exception('Failed to send friend request');
    }
  }

  /// Cancel a friend request.
  Future<void> cancelFriendRequest(String fromUserId, String toUserId) async {
    try {
      final requestDocs = await _firestore
          .collection('friend_requests')
          .where('fromUserId', isEqualTo: fromUserId)
          .where('toUserId', isEqualTo: toUserId)
          .get();

      for (var doc in requestDocs.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error cancelling friend request: $e');
      }
      throw Exception('Failed to cancel friend request');
    }
  }

  /// Accept a friend request.
  Future<void> acceptFriendRequest(String fromUserId, String toUserId) async {
    try {
      await cancelFriendRequest(fromUserId, toUserId);

      // Add friendships in both directions
      await addFriend(
          Friend(id: fromUserId, friendId: fromUserId, userId: toUserId));
      await addFriend(
          Friend(id: toUserId, friendId: toUserId, userId: fromUserId));
    } catch (e) {
      if (kDebugMode) {
        print('Error accepting friend request: $e');
      }
      throw Exception('Failed to accept friend request');
    }
  }

  /// Check if there is a pending friend request.
  Future<bool> hasPendingRequest(String toUserId) async {
    try {
      final currentUserId = _currentUser!.uid;
      final requestDocs = await _firestore
          .collection('friend_requests')
          .where('fromUserId', isEqualTo: currentUserId)
          .where('toUserId', isEqualTo: toUserId)
          .get();

      return requestDocs.docs.isNotEmpty;
    } catch (e) {
      if (kDebugMode) {
        print('Error checking pending requests: $e');
      }
      throw Exception('Failed to check pending requests');
    }
  }

  /// Cancel active subscriptions and dispose streams.
  void cancelSubscriptions() {
    _friendsSubscription?.cancel();
    _friendRequestsSubscription?.cancel();
  }

  void dispose() {
    cancelSubscriptions();
    _friendsController.close();
    _friendRequestsController.close();
  }
}
