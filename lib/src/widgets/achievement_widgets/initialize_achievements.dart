import 'package:pet_diary/src/models/achievement.dart';

const String _avatarUrl = 'assets/images/dog_avatar_06.png';

// ids
const String _id10kSteps = '1a2b3c4d-0000-0000-0000-000000000001';
const String _id25kSteps = '1a2b3c4d-0000-0000-0000-000000000002';
const String _id50kSteps = '1a2b3c4d-0000-0000-0000-000000000003';
const String _id100kSteps = '1a2b3c4d-0000-0000-0000-000000000004';
const String _idMarathon = '1a2b3c4d-0000-0000-0000-000000000005';
const String _idSuezCanal = '1a2b3c4d-0000-0000-0000-000000000006';
const String _idRoute66 = '1a2b3c4d-0000-0000-0000-000000000007';
const String _idFellowshipOfTheRing = '1a2b3c4d-0000-0000-0000-000000000008';

List<Achievement> achievements = [
  Achievement(
    id: _id10kSteps,
    name: '10,000 Steps',
    description: 'Walk 10,000 steps.',
    avatarUrl: _avatarUrl,
    category: 'steps',
    stepsRequired: 10000,
  ),
  Achievement(
    id: _id25kSteps,
    name: '25,000 Steps',
    description: 'Walk 25,000 steps.',
    avatarUrl: _avatarUrl,
    category: 'steps',
    stepsRequired: 25000,
  ),
  Achievement(
    id: _id50kSteps,
    name: '50,000 Steps',
    description: 'Walk 50,000 steps.',
    avatarUrl: _avatarUrl,
    category: 'steps',
    stepsRequired: 50000,
  ),
  Achievement(
    id: _id100kSteps,
    name: '100,000 Steps',
    description: 'Walk 100,000 steps.',
    avatarUrl: _avatarUrl,
    category: 'steps',
    stepsRequired: 100000,
  ),

  // Nature achievements
  Achievement(
    id: _idMarathon,
    name: 'Marathon',
    description: 'Walk 42.0 km.',
    avatarUrl: _avatarUrl,
    category: 'nature',
    stepsRequired: 42000,
  ),
  Achievement(
    id: _idSuezCanal,
    name: 'Suez Canal',
    description: 'Walk 200.0 km.',
    avatarUrl: _avatarUrl,
    category: 'nature',
    stepsRequired: 200000,
  ),
  Achievement(
    id: _idRoute66,
    name: 'Route 66',
    description: 'Walk 4,000.0 km.',
    avatarUrl: _avatarUrl,
    category: 'nature',
    stepsRequired: 4000000,
  ),

  // Fantasy achievements
  Achievement(
    id: _idFellowshipOfTheRing,
    name: 'Fellowship of the Ring',
    description: 'Walk 1,900 km.',
    avatarUrl: _avatarUrl,
    category: 'fantasy',
    stepsRequired: 1900000,
  ),
];
