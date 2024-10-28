import 'package:cloud_firestore/cloud_firestore.dart';

class AppUserModel {
  final String id;
  final String email;
  final String username;
  final String avatarUrl;
  final bool isPremium;

  AppUserModel({
    required this.id,
    required this.email,
    required this.username,
    required this.avatarUrl,
    this.isPremium = false,
  });

  factory AppUserModel.fromDocument(DocumentSnapshot doc) {
    return AppUserModel(
      id: doc['uid'],
      email: doc['email'],
      username: doc['username'] ?? 'No username',
      avatarUrl: doc['avatarUrl'] ?? 'assets/images/default_avatar.png',
      isPremium: doc['isPremium'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': id,
      'email': email,
      'username': username,
      'avatarUrl': avatarUrl,
      'isPremium': isPremium,
    };
  }

  AppUserModel copyWith({
    String? uid,
    String? email,
    String? username,
    String? avatarUrl,
    bool? isPremium,
  }) {
    return AppUserModel(
      id: uid ?? id,
      email: email ?? this.email,
      username: username ?? this.username,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isPremium: isPremium ?? this.isPremium,
    );
  }
}
