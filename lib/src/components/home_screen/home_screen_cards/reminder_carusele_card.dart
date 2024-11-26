import 'package:flutter/material.dart';
import 'package:pet_diary/src/screens/reminders_screens/behaviorist_reminder_screen.dart';
import 'package:pet_diary/src/screens/reminders_screens/feed_reminder_screen.dart';
import 'package:pet_diary/src/screens/reminders_screens/grooming_reminder_screen.dart';
import 'package:pet_diary/src/screens/reminders_screens/other_reminder_screen.dart';
import 'package:pet_diary/src/screens/reminders_screens/vet_appointment_reminder_screen.dart';
import 'package:pet_diary/src/screens/reminders_screens/walk_reminder_screen.dart';

class ReminderCardCarousel extends StatelessWidget {
  const ReminderCardCarousel({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> reminderCards = [
      {
        'title': 'Feed Reminder',
        'image': 'assets/images/reminder_cards/eating_dog_01.jpg',
        'screen': const FeedReminderScreen(),
      },
      {
        'title': 'Walk Reminder',
        'image': 'assets/images/reminder_cards/walk_2.jpg',
        'screen': const WalkReminderScreen(),
      },
      {
        'title': 'Vet Reminder',
        'image': 'assets/images/reminder_cards/vet_dog.jpg',
        'screen': const VetAppointmentScreen(),
      },
      {
        'title': 'Grooming Reminder',
        'image': 'assets/images/reminder_cards/bath.jpg',
        'screen': const GroomingReminderScreen(),
      },
      {
        'title': 'Behaviorist Reminder',
        'image': 'assets/images/reminder_cards/behawiorist.jpg',
        'screen': const BehavioristReminderScreen(),
      },
      {
        'title': 'Other Reminders',
        'image': 'assets/images/reminder_cards/other.jpg',
        'screen': const OtherReminderScreen(),
      },
    ];

    return SizedBox(
      height: 230,
      child: PageView.builder(
        controller: PageController(viewportFraction: 1.04),
        itemCount: reminderCards.length,
        itemBuilder: (context, index) {
          final reminder = reminderCards[index];
          return _buildCarouselCard(
            context: context,
            title: reminder['title'],
            image: reminder['image'],
            screen: reminder['screen'],
          );
        },
      ),
    );
  }

  Widget _buildCarouselCard({
    required BuildContext context,
    required String title,
    required String image,
    required Widget screen,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                image,
                fit: BoxFit.cover,
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => screen),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'Open',
                          style: TextStyle(
                              color: Theme.of(context).primaryColorDark),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
