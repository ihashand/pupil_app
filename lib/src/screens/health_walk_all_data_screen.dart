import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pet_diary/src/components/events/event_delete_func.dart';
import 'package:pet_diary/src/models/event_model.dart';
import 'package:pet_diary/src/models/event_walk_model.dart';
import 'package:pet_diary/src/providers/event_walk_provider.dart';
import 'package:pet_diary/src/screens/health_walk_details_screen.dart';

enum SortOrder { newest, oldest }

class HealthWalkAllDataScreen extends ConsumerStatefulWidget {
  final String petId;
  final List<Event> petEvents;
  const HealthWalkAllDataScreen(this.petId, this.petEvents, {super.key});

  @override
  createState() => _HealthWalkAllDataScreenState();
}

class _HealthWalkAllDataScreenState
    extends ConsumerState<HealthWalkAllDataScreen> {
  SortOrder _sortOrder = SortOrder.newest;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Theme.of(context).primaryColorDark.withOpacity(0.7),
        ),
        title: Text(
          'W a l k s',
          style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColorDark.withOpacity(0.7)),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        toolbarHeight: 50,
        actions: [
          PopupMenuButton<SortOrder>(
            onSelected: (SortOrder result) {
              setState(() {
                _sortOrder = result;
              });
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<SortOrder>>[
              const PopupMenuItem<SortOrder>(
                value: SortOrder.newest,
                child: Text('Sort by Newest'),
              ),
              const PopupMenuItem<SortOrder>(
                value: SortOrder.oldest,
                child: Text('Sort by Oldest'),
              ),
            ],
          ),
        ],
      ),
      body: Consumer(builder: (context, ref, _) {
        final asyncWalks = ref.watch(eventWalksProvider);

        return asyncWalks.when(
          loading: () => const CircularProgressIndicator(),
          error: (err, stack) => Text('Error fetching walks: $err'),
          data: (walks) {
            List<EventWalkModel?> petWalks =
                walks.where((walk) => walk!.petId == widget.petId).toList();

            petWalks.sort((a, b) {
              if (_sortOrder == SortOrder.newest) {
                return b!.dateTime.compareTo(a!.dateTime);
              } else {
                return a!.dateTime.compareTo(b!.dateTime);
              }
            });

            if (petWalks.isEmpty) {
              return const Center(child: Text('No data available'));
            }

            return ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: petWalks.length,
              itemBuilder: (context, index) {
                final walk = petWalks[index];
                final formattedDate =
                    DateFormat('dd-MM-yyyy').format(walk!.dateTime.toLocal());

                return GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => HealthWalkDetailsScreen(walk: walk),
                    ));
                  },
                  child: Card(
                    color: Theme.of(context).colorScheme.primary,
                    elevation: 3.0,
                    margin: const EdgeInsets.symmetric(
                        vertical: 3.0, horizontal: 10),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 0.2, horizontal: 15.0),
                      subtitle: Text(formattedDate,
                          style: TextStyle(
                              color: Theme.of(context).primaryColorDark,
                              fontSize: 12)),
                      title: Text('Steps: ${walk.distance}',
                          style: TextStyle(
                              color: Theme.of(context).primaryColorDark,
                              fontSize: 15)),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        color:
                            Theme.of(context).primaryColorDark.withOpacity(0.7),
                        onPressed: () {
                          _confirmDelete(context, walk, ref);
                        },
                      ),
                    ),
                  ),
                );
              },
            );
          },
        );
      }),
    );
  }

  void _confirmDelete(
      BuildContext context, EventWalkModel? walk, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Confirm Delete',
            style: TextStyle(
                color: Theme.of(context).primaryColorDark.withOpacity(0.7)),
          ),
          content: Text(
            'Are you sure you want to delete this walk?',
            style: TextStyle(
                color: Theme.of(context).primaryColorDark.withOpacity(0.7)),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Cancel',
                style: TextStyle(
                    color: Theme.of(context).primaryColorDark.withOpacity(0.7)),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(
                'OK',
                style: TextStyle(
                    color: Theme.of(context).primaryColorDark.withOpacity(0.7)),
              ),
              onPressed: () {
                eventDeleteFunc(ref, context, widget.petEvents, walk!.eventId);
                ref.read(eventWalkServiceProvider).deleteWalk(walk.id);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
