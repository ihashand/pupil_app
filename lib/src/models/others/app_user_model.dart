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
    final data = doc.data() as Map<String, dynamic>;

    return AppUserModel(
      id: data['uid'] ?? doc.id,
      email: data['email'] ?? 'No email',
      username: data['username'] ?? 'No username',
      avatarUrl: data['avatarUrl'] ?? 'assets/images/default_avatar.png',
      isPremium: data.containsKey('isPremium') ? data['isPremium'] : false,
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

  // Update bazy danych Update all user documents in Firestore
  static Future<void> updateAllUsers() async {
    final userCollection = FirebaseFirestore.instance.collection('app_users');

    // Fetch all documents in the collection
    final querySnapshot = await userCollection.get();

    // Loop through each document and update it
    for (var doc in querySnapshot.docs) {
      // Convert each document into an AppUserModel instance
      AppUserModel user = AppUserModel.fromDocument(doc);

      // Update the document in Firestore with the user's data
      await userCollection.doc(user.id).update(user.toMap());
    }
  }

  AppUserModel copyWith({
    String? id,
    String? email,
    String? username,
    String? avatarUrl,
    bool? isPremium,
  }) {
    return AppUserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      username: username ?? this.username,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isPremium: isPremium ?? this.isPremium,
    );
  }
}
