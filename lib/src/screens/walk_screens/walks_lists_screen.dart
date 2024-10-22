import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:apple_maps_flutter/apple_maps_flutter.dart';
import 'package:pet_diary/src/models/others/global_walk_model.dart';
import 'package:pet_diary/src/models/others/pet_model.dart';
import 'package:pet_diary/src/providers/pets_providers.dart'; // Provider dla zwierząt
import 'package:pet_diary/src/providers/global_walks_provider.dart'; // Provider dla spacerów
import 'package:pet_diary/src/screens/walk_summary_modal.dart'; // Modalne okno podsumowania spaceru

class WalksListScreen extends ConsumerWidget {
  const WalksListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final walksAsyncValue = ref.watch(globalWalksProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Walks'),
      ),
      body: walksAsyncValue.when(
        data: (walks) => ListView.builder(
          itemCount: walks.length,
          itemBuilder: (context, index) {
            final walk = walks[index];
            return _buildWalkTile(context, walk, ref);
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _buildWalkTile(
      BuildContext context, GlobalWalkModel walk, WidgetRef ref) {
    final petsAsyncValue = ref.watch(petFriendServiceProvider(
        walk.petIds.first)); // Zakładamy, że lista zwierząt istnieje

    return Card(
      child: ListTile(
        leading: SizedBox(
          height: 100,
          width: 100,
          child: AppleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(walk.routePoints.first['latitude'],
                  walk.routePoints.first['longitude']),
              zoom: 14,
            ),
            polylines: {
              Polyline(
                polylineId: PolylineId('route_${walk.id}'),
                points: walk.routePoints
                    .map((point) =>
                        LatLng(point['latitude'], point['longitude']))
                    .toList(),
                width: 5,
                color: Colors.blue,
              ),
            },
          ),
        ),
        title: Text('Walk on ${walk.dateTime.toString()}'),
        subtitle: Text(
            'Duration: ${walk.walkTime.toString()} mins\nSteps: ${walk.steps}'),
        trailing: petsAsyncValue.when(
          data: (pets) => Row(
            mainAxisSize: MainAxisSize.min,
            children: pets.map((pet) {
              return CircleAvatar(
                backgroundImage: AssetImage(pet.avatarImage),
              );
            }).toList(),
          ),
          loading: () => const CircularProgressIndicator(),
          error: (error, stack) => Text('Error loading pets'),
        ),
        onTap: () {
          showModalBottomSheet(
            context: context,
            builder: (context) => WalkSummaryModal(walk: walk),
          );
        },
      ),
    );
  }
}
