import 'package:cloud_firestore/cloud_firestore.dart';

class Friend {
  final String id;
  final String userId;
  final String friendId;

  Friend({
    required this.id,
    required this.userId,
    required this.friendId,
  });

  factory Friend.fromDocument(DocumentSnapshot doc) {
    return Friend(
      id: doc.id,
      userId: doc['userId'],
      friendId: doc['friendId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'friendId': friendId,
    };
  }
}
