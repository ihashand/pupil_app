import 'package:cloud_firestore/cloud_firestore.dart';

class FriendRequest {
  final String id;
  final String fromUserId;
  final String toUserId;
  final Timestamp timestamp;

  FriendRequest({
    required this.id,
    required this.fromUserId,
    required this.toUserId,
    required this.timestamp,
  });

  factory FriendRequest.fromDocument(DocumentSnapshot doc) {
    return FriendRequest(
      id: doc.id,
      fromUserId: doc['fromUserId'],
      toUserId: doc['toUserId'],
      timestamp: doc['timestamp'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'fromUserId': fromUserId,
      'toUserId': toUserId,
      'timestamp': timestamp,
    };
  }
}
