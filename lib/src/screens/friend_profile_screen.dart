import 'package:flutter/material.dart';
import 'package:pet_diary/src/models/friend_model.dart';

class ProfileScreen extends StatelessWidget {
  final Friend friend;

  const ProfileScreen({super.key, required this.friend});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(friend.id),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // CircleAvatar(
            //   radius: 50,
            //   backgroundImage: AssetImage(friend.avatarUrl),
            // ),
            const SizedBox(height: 16),
            Text(
              friend.id,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              friend.userId,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
