import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pet_diary/src/components/events/delete_event.dart';
import 'package:pet_diary/src/models/event_model.dart';
import 'package:pet_diary/src/models/walk_model.dart';
import 'package:pet_diary/src/providers/walk_provider.dart';
import 'package:pet_diary/src/screens/all_data_walk_details_screen.dart';

class AllDataWalkScreen extends ConsumerWidget {
  final String petId;
  final List<Event> petEvents;
  const AllDataWalkScreen(this.petId, this.petEvents, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final walkProvider = ref.watch(walkServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Data Walks'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        toolbarHeight: 50,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: StreamBuilder<List<Walk?>>(
        stream: walkProvider.getWalksStream(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('Error fetching walks: ${snapshot.error}');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }

          if (snapshot.hasData) {
            List<Walk?> walks =
                snapshot.data!.where((walk) => walk!.petId == petId).toList();

            return ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: walks.length,
              itemBuilder: (context, index) {
                final walk = walks[index];
                final formattedDate =
                    DateFormat('dd-MM-yyyy').format(walk!.dateTime.toLocal());

                return GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) =>
                          AllDataWalkDetailsScreen(walk: walk),
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
                        color: Theme.of(context).primaryColorDark,
                        onPressed: () {
                          deleteEvents(ref, context, petEvents, walk.eventId);
                          ref.read(walkServiceProvider).deleteWalk(walk.id);
                        },
                      ),
                    ),
                  ),
                );
              },
            );
          } else {
            return const Center(child: Text('No data available'));
          }
        },
      ),
    );
  }
}
