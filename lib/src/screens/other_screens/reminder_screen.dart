import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/helpers/animations/slide_animation_helper.dart';
import 'package:pet_diary/src/helpers/messages/empty_state_widget.dart';
import 'package:pet_diary/src/models/reminder_models/reminder_model.dart';
import 'package:pet_diary/src/providers/reminder_providers/reminder_providers.dart';
import 'package:intl/intl.dart';
import 'package:pet_diary/src/screens/reminders_screens/feed_reminder_screen.dart';
import 'package:pet_diary/src/screens/reminders_screens/walk_reminder_screen.dart';

class ReminderScreen extends ConsumerStatefulWidget {
  const ReminderScreen({super.key});

  @override
  ConsumerState<ReminderScreen> createState() => _ReminderScreenState();
}

class _ReminderScreenState extends ConsumerState<ReminderScreen> {
  bool isCreatorSelected = true;
  bool sortAscending = true;
  String searchQuery = '';

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
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(25),
                bottomRight: Radius.circular(25),
              ),
            ),
            child: Column(
              children: [
                Divider(color: Theme.of(context).colorScheme.surface),
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildTabButton('Creator', isCreatorSelected, () {
                        setState(() => isCreatorSelected = true);
                      }),
                      _buildTabButton('Remaining', !isCreatorSelected, () {
                        setState(() => isCreatorSelected = false);
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 7),
          Expanded(
            child:
                isCreatorSelected ? _buildCreatorView() : _buildRemainingView(),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 20.0),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.secondary
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? Theme.of(context).primaryColorDark
                : Theme.of(context).primaryColorDark.withOpacity(0.4),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildCreatorView() {
    return ListView(
      padding: const EdgeInsets.all(8),
      children: [
        _buildCreatorCard(
          title: 'Feed Reminder',
          image: 'assets/images/reminder_cards/eating_dog.jpg',
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
          image: 'assets/images/others/walk_background.jpg',
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const WalkReminderScreen(),
              ),
            );
          },
        ),
        _buildCreatorCard(
          title: 'Other Reminders',
          image: 'assets/images/others/walk_background.jpg',
          onTap: () {
            // Placeholder for future screens
          },
        ),
        _buildCreatorCard(
          title: 'Vet Appointment',
          image: 'assets/images/reminder_cards/vet_dog.jpg',
          onTap: () {
            // Placeholder for future screens
          },
        ),
        _buildCreatorCard(
          title: 'Grooming Reminder',
          image: 'assets/images/reminder_cards/walk_dog.jpg',
          onTap: () {
            // Placeholder for future screens
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
      margin: const EdgeInsets.symmetric(vertical: 10),
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
                  fit: BoxFit.cover,
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              ListTile(
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRemainingView() {
    return Column(
      children: [
        _buildSearchAndSortOptions(),
        Expanded(
          child: Consumer(
            builder: (context, ref, _) {
              final remindersAsync = ref.watch(remindersStreamProvider);

              return remindersAsync.when(
                data: (reminders) {
                  final filteredReminders = reminders.where((reminder) {
                    final dateFormats = [
                      DateFormat('dd.MM.yyyy'),
                      DateFormat('dd-MM-yyyy'),
                      DateFormat('dd MM yyyy'),
                    ];

                    bool matchesQuery = reminder.name
                            .toLowerCase()
                            .contains(searchQuery.toLowerCase()) ||
                        dateFormats.any((format) =>
                            format.format(reminder.scheduledDate) ==
                            searchQuery);
                    return matchesQuery;
                  }).toList();

                  if (filteredReminders.isEmpty) {
                    return const Center(
                      child: SlideAnimationHelper(
                        duration: Duration(milliseconds: 1600),
                        curve: Curves.bounceOut,
                        child: EmptyStateWidget(
                          message: "No upcoming reminders.",
                          icon: Icons.notifications_off,
                        ),
                      ),
                    );
                  }

                  final sortedReminders =
                      List<ReminderModel>.from(filteredReminders);
                  sortedReminders.sort((a, b) => sortAscending
                      ? a.scheduledDate.compareTo(b.scheduledDate)
                      : b.scheduledDate.compareTo(a.scheduledDate));

                  return ListView.builder(
                    itemCount: sortedReminders.length,
                    itemBuilder: (context, index) {
                      final reminder = sortedReminders[index];
                      return _buildReminderTile(reminder);
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => Center(child: Text('Error: $error')),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSearchAndSortOptions() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              onChanged: (value) {
                setState(() => searchQuery = value);
              },
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search,
                    color: Theme.of(context).primaryColorDark),
                hintText: 'Search by name or date (dd.MM.yyyy)',
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
              color: Theme.of(context).primaryColorDark,
            ),
            onPressed: () => setState(() => sortAscending = !sortAscending),
          ),
        ],
      ),
    );
  }

  Widget _buildReminderTile(ReminderModel reminder) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      color: Theme.of(context).colorScheme.primary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.surface,
          child: Text(
            reminder.emoji,
            style: const TextStyle(fontSize: 24),
          ),
        ),
        title: Text(
          reminder.name,
          style: TextStyle(
            fontSize: 16,
            color: Theme.of(context).primaryColorDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          DateFormat('dd-MM-yyyy HH:mm').format(reminder.scheduledDate),
          style: TextStyle(color: Theme.of(context).primaryColorDark),
        ),
        trailing: IconButton(
          icon: Icon(Icons.delete, color: Theme.of(context).primaryColorDark),
          onPressed: () async {
            final shouldDelete = await _showDeleteConfirmation(context);
            if (shouldDelete) {
              await ref
                  .read(reminderServiceProvider)
                  .deleteReminder(reminder.id);
            }
          },
        ),
      ),
    );
  }

  Future<bool> _showDeleteConfirmation(BuildContext context) async {
    return await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Delete Reminder'),
            content:
                const Text('Are you sure you want to delete this reminder?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text('Delete'),
              ),
            ],
          ),
        ) ??
        false;
  }
}
