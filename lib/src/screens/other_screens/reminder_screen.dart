import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/screens/reminders_screens/behaviorist_reminder_screen.dart';
import 'package:pet_diary/src/screens/reminders_screens/feed_reminder_screen.dart';
import 'package:pet_diary/src/screens/reminders_screens/grooming_reminder_screen.dart';
import 'package:pet_diary/src/screens/reminders_screens/other_reminder_screen.dart';
import 'package:pet_diary/src/screens/reminders_screens/vet_appointment_reminder_screen.dart';
import 'package:pet_diary/src/screens/reminders_screens/walk_reminder_screen.dart';

class ReminderScreen extends ConsumerStatefulWidget {
  const ReminderScreen({super.key});

  @override
  ConsumerState<ReminderScreen> createState() => _ReminderScreenState();
}

class _ReminderScreenState extends ConsumerState<ReminderScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        iconTheme: IconThemeData(color: Theme.of(context).primaryColorDark),
        title: Text(
          'R E M I N D E R S',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
            color: Theme.of(context).primaryColorDark,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        toolbarHeight: 50,
      ),
      body: Column(
        children: [
          const SizedBox(height: 7),
          Expanded(child: _buildCreatorView()),
        ],
      ),
    );
  }

  Widget _buildCreatorView() {
    return ListView(
      padding: const EdgeInsets.all(8),
      children: [
        _buildCreatorCard(
          title: 'Feed Reminder',
          image: 'assets/images/reminder_cards/eating_dog_01.jpg',
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const FeedReminderScreen(),
              ),
            );
          },
        ),
        _buildCreatorCard(
          title: 'Walk Reminder',
          image: 'assets/images/reminder_cards/walk_2.jpg',
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const WalkReminderScreen(),
              ),
            );
          },
        ),
        _buildCreatorCard(
          title: 'Vet Reminder',
          image: 'assets/images/reminder_cards/vet_dog.jpg',
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const VetAppointmentScreen(),
              ),
            );
          },
        ),
        _buildCreatorCard(
          title: 'Grooming Reminder',
          image: 'assets/images/reminder_cards/bath.jpg',
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const GroomingReminderScreen(),
              ),
            );
          },
        ),
        _buildCreatorCard(
          title: 'Behaviorist Reminder',
          image: 'assets/images/reminder_cards/behawiorist.jpg',
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const BehavioristReminderScreen(),
              ),
            );
          },
        ),
        _buildCreatorCard(
          title: 'Other Reminders',
          image: 'assets/images/reminder_cards/other.jpg',
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const OtherReminderScreen(),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildCreatorCard({
    required String title,
    required String image,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          height: 200,
          child: Stack(
            children: [
              Positioned.fill(
                child: Image.asset(
                  image,
                  fit: BoxFit.fill,
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 5),
                child: ListTile(
                  title: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  trailing: ElevatedButton(
                    onPressed: onTap,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColorDark,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Create'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
