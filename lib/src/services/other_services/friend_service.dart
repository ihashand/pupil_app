import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:pet_diary/src/models/others/friend_model.dart';
import 'package:pet_diary/src/models/others/friend_request_model.dart';

class FriendService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  // StreamControllers for managing streams
  final StreamController<List<Friend>> _friendsController =
      StreamController<List<Friend>>.broadcast();
  final StreamController<List<FriendRequest>> _friendRequestsController =
      StreamController<List<FriendRequest>>.broadcast();

  // Subscriptions to manage Firestore listeners
  final List<StreamSubscription> _subscriptions = [];

  /// Stream of friends for the logged-in user.
  Stream<List<Friend>> getFriendsStream() {
    try {
      if (_currentUser == null) {
        return Stream.value([]);
      }

      final subscription = _firestore
          .collection('friends')
          .where('userId', isEqualTo: _currentUser.uid)
          .snapshots()
          .listen((snapshot) {
        final friends =
            snapshot.docs.map((doc) => Friend.fromDocument(doc)).toList();
        _friendsController.add(friends);
      }, onError: (error) {
        debugPrint('Error fetching friends: $error');
        _friendsController.addError(error);
      });

      _subscriptions.add(subscription);
      return _friendsController.stream;
    } catch (e) {
      debugPrint('Error in getFriendsStream: $e');
      return Stream.error(e);
    }
  }

  /// Stream of friend requests for the logged-in user.
  Stream<List<FriendRequest>> getFriendRequestsStream() {
    try {
      if (_currentUser == null) {
        return Stream.value([]);
      }

      final subscription = _firestore
          .collection('friend_requests')
          .snapshots()
          .listen((snapshot) {
        final requests = snapshot.docs
            .map((doc) => FriendRequest.fromDocument(doc))
            .toList();
        _friendRequestsController.add(requests);
      }, onError: (error) {
        debugPrint('Error fetching friend requests: $error');
        _friendRequestsController.addError(error);
      });

      _subscriptions.add(subscription);
      return _friendRequestsController.stream;
    } catch (e) {
      debugPrint('Error in getFriendRequestsStream: $e');
      return Stream.error(e);
    }
  }

  /// Add a new friend.
  Future<void> addFriend(Friend friend) async {
    try {
      await _firestore.collection('friends').doc(friend.id).set(friend.toMap());
    } catch (e) {
      debugPrint('Error adding friend: $e');
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
          .where('friendId', isEqualTo: _currentUser.uid)
          .where('userId', isEqualTo: friendId)
          .get();

      for (var doc in friendDocs.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      debugPrint('Error removing friend: $e');
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
        debugPrint('Friend request already sent.');
        return;
      }

      final existingFriend = await _firestore
          .collection('friends')
          .where('userId', isEqualTo: currentUserId)
          .where('friendId', isEqualTo: toUserId)
          .get();

      if (existingFriend.docs.isNotEmpty) {
        debugPrint('User is already your friend.');
        return;
      }

      final reverseRequest = await _firestore
          .collection('friend_requests')
          .where('fromUserId', isEqualTo: toUserId)
          .where('toUserId', isEqualTo: currentUserId)
          .get();

      if (reverseRequest.docs.isNotEmpty) {
        debugPrint('You have a pending request from this user.');
        return;
      }

      // Add new friend request
      await _firestore.collection('friend_requests').add({
        'fromUserId': currentUserId,
        'toUserId': toUserId,
        'timestamp': Timestamp.now(),
      });
    } catch (e) {
      debugPrint('Error sending friend request: $e');
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
      debugPrint('Error cancelling friend request: $e');
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
      debugPrint('Error accepting friend request: $e');
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
      debugPrint('Error checking pending requests: $e');
      throw Exception('Failed to check pending requests');
    }
  }

  /// Dispose method to clean up resources and cancel subscriptions
  void dispose() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions.clear();
    _friendsController.close();
    _friendRequestsController.close();
  }
}
