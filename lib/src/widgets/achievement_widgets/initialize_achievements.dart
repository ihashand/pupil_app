import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pet_diary/src/models/achievement.dart';
import 'package:uuid/uuid.dart';

final FirebaseFirestore _firestore = FirebaseFirestore.instance;
const String _avatarUrl = 'assets/images/dog_avatar_06.png';

void initializeAchievements() async {
  List<Achievement> achievements = [
    // Steps achievements
    Achievement(
      id: const Uuid().v4(),
      name: '10,000 Steps',
      description: 'Walk 10,000 steps.',
      avatarUrl: _avatarUrl,
      category: 'steps',
      stepsRequired: 10000,
    ),
    Achievement(
      id: const Uuid().v4(),
      name: '25,000 Steps',
      description: 'Walk 25,000 steps.',
      avatarUrl: _avatarUrl,
      category: 'steps',
      stepsRequired: 25000,
    ),
    Achievement(
      id: const Uuid().v4(),
      name: '50,000 Steps',
      description: 'Walk 50,000 steps.',
      avatarUrl: _avatarUrl,
      category: 'steps',
      stepsRequired: 50000,
    ),
    Achievement(
      id: const Uuid().v4(),
      name: '100,000 Steps',
      description: 'Walk 100,000 steps.',
      avatarUrl: _avatarUrl,
      category: 'steps',
      stepsRequired: 100000,
    ),
    // More steps achievements...

    // Nature achievements
    Achievement(
      id: const Uuid().v4(),
      name: 'Marathon',
      description: 'Walk 42.0 km.',
      avatarUrl: _avatarUrl,
      category: 'nature',
      stepsRequired: 42000,
    ),
    Achievement(
      id: const Uuid().v4(),
      name: 'Suez Canal',
      description: 'Walk 200.0 km.',
      avatarUrl: _avatarUrl,
      category: 'nature',
      stepsRequired: 200000,
    ),
    Achievement(
      id: const Uuid().v4(),
      name: 'Route 66',
      description: 'Walk 4,000.0 km.',
      avatarUrl: _avatarUrl,
      category: 'nature',
      stepsRequired: 4000000,
    ),
    // More nature achievements...

    // Fantasy achievements
    Achievement(
      id: const Uuid().v4(),
      name: 'Fellowship of the Ring',
      description: 'Walk 1,900 km.',
      avatarUrl: _avatarUrl,
      category: 'fantasy',
      stepsRequired: 1900000,
    ),
    // More fantasy achievements...
  ];

  for (var achievement in achievements) {
    await _firestore
        .collection('achievements')
        .doc(achievement.id)
        .set(achievement.toMap());
  }
}
