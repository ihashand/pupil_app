import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:apple_maps_flutter/apple_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:pet_diary/src/screens/walk_screens/walk_summary_screen.dart';
import 'package:pet_diary/src/providers/walks_providers/global_walk_provider.dart';
import 'package:pet_diary/src/providers/others_providers/pet_provider.dart';

class WalksListScreen extends ConsumerStatefulWidget {
  const WalksListScreen({super.key});

  @override
  ConsumerState<WalksListScreen> createState() => _WalksListScreenState();
}

class _WalksListScreenState extends ConsumerState<WalksListScreen> {
  int _loadedItems = 5; // liczba załadowanych spacerów na początek

  @override
  Widget build(BuildContext context) {
    final globalWalksAsyncValue = ref.watch(globalWalksStreamProvider);
    final petsAsyncValue = ref.watch(petsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Walks List'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Column(
        children: [
          Divider(
            color: Theme.of(context).colorScheme.secondary,
            height: 1,
            thickness: 1,
          ),
          Container(
            height: 70,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(22),
                bottomRight: Radius.circular(22),
              ),
            ),
            child: Center(
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.sort),
                label: const Text("Sort"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.surface,
                  foregroundColor: Theme.of(context).primaryColorDark,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: globalWalksAsyncValue.when(
              data: (walks) {
                if (walks.isEmpty) {
                  return const Center(
                    child: Text('No walks available'),
                  );
                }

                // Sortowanie spacerów od najnowszego do najstarszego
                walks.sort((a, b) => b.dateTime.compareTo(a.dateTime));

                return NotificationListener<ScrollNotification>(
                  onNotification: (ScrollNotification scrollInfo) {
                    if (scrollInfo.metrics.pixels ==
                        scrollInfo.metrics.maxScrollExtent) {
                      setState(() {
                        _loadedItems += 5; // Ładowanie kolejnych 5 spacerów
                      });
                    }
                    return true;
                  },
                  child: ListView.builder(
                    itemCount: walks.length < _loadedItems
                        ? walks.length
                        : _loadedItems,
                    itemBuilder: (context, index) {
                      final walk = walks[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => WalkSummaryScreen(
                                eventLines: _buildEventLines(
                                    walk.routePoints), // linie trasy
                                addedEvents: walk.stoolsAndUrine, // wydarzenia
                                photos: _convertImagesToXFiles(walk.images),
                                totalDistance: walk.walkTime.toStringAsFixed(2),
                                totalTimeInSeconds: walk.walkTime.toInt(),
                                pets: const [], // Lista zwierząt
                                notes: walk.noteId ?? '',
                              ),
                            ),
                          );
                        },
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          margin: const EdgeInsets.all(10),
                          child: Column(
                            children: [
                              Stack(
                                children: [
                                  _buildMapThumbnail(walk.routePoints),
                                  Positioned(
                                    top: 10,
                                    right: 10,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.6),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            DateFormat('dd-MM-yyyy')
                                                .format(walk.dateTime),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                          Text(
                                            DateFormat('HH:mm')
                                                .format(walk.dateTime),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20.0, vertical: 12.0),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primary,
                                  borderRadius: const BorderRadius.only(
                                    bottomLeft: Radius.circular(12),
                                    bottomRight: Radius.circular(12),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    petsAsyncValue.when(
                                      data: (pets) {
                                        final petsInWalk = pets
                                            .where((pet) =>
                                                walk.petIds.contains(pet.id))
                                            .toList();
                                        return Row(
                                          children: petsInWalk.map((pet) {
                                            return Padding(
                                              padding: const EdgeInsets.only(
                                                  right: 8.0),
                                              child: CircleAvatar(
                                                backgroundImage:
                                                    AssetImage(pet.avatarImage),
                                                radius: 18,
                                              ),
                                            );
                                          }).toList(),
                                        );
                                      },
                                      loading: () =>
                                          const CircularProgressIndicator(),
                                      error: (error, stack) =>
                                          Text('Error: $error'),
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Distance: ${walk.walkTime.toStringAsFixed(2)} km',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Theme.of(context)
                                                .primaryColorDark,
                                          ),
                                        ),
                                        Text(
                                          'Duration: ${_formatDuration(walk.walkTime)}',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Theme.of(context)
                                                .primaryColorDark,
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
                    },
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) =>
                  Center(child: Text('Error: $error')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapThumbnail(List<dynamic> routePoints) {
    final points = routePoints.map((point) {
      final Map<String, dynamic> castedPoint = point;
      return LatLng(castedPoint['latitude'], castedPoint['longitude']);
    }).toList();

    // Tworzenie bounds, aby zoom kamery objął całą trasę
    LatLngBounds bounds;
    if (points.isNotEmpty) {
      bounds = LatLngBounds(
        southwest: points.reduce((a, b) => LatLng(
            a.latitude < b.latitude ? a.latitude : b.latitude,
            a.longitude < b.longitude ? a.longitude : b.longitude)),
        northeast: points.reduce((a, b) => LatLng(
            a.latitude > b.latitude ? a.latitude : b.latitude,
            a.longitude > b.longitude ? a.longitude : b.longitude)),
      );
    } else {
      bounds = LatLngBounds(
        southwest: const LatLng(51.5, -0.09),
        northeast: const LatLng(51.5, -0.09),
      );
    }

    return SizedBox(
      height: 170,
      child: AppleMap(
        initialCameraPosition: CameraPosition(
          target: points.isNotEmpty ? points.first : const LatLng(51.5, -0.09),
          zoom: 12, // Ustawienie początkowego zoomu
        ),
        polylines: {
          Polyline(
            polylineId: PolylineId('route'),
            points: points,
            width: 3,
            color: Colors.blue,
          ),
        },
        onMapCreated: (controller) {
          // Przeskalowanie kamery do bounds po stworzeniu mapy
          if (points.isNotEmpty) {
            controller.moveCamera(CameraUpdate.newLatLngBounds(bounds, 120));
          }
        },
      ),
    );
  }

  String _formatDuration(double totalTimeInSeconds) {
    final int hours = (totalTimeInSeconds ~/ 3600);
    final int minutes = ((totalTimeInSeconds % 3600) ~/ 60);
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
  }

  List<XFile> _convertImagesToXFiles(List<String>? images) {
    return images != null
        ? images.map((imageUrl) => XFile(imageUrl)).toList()
        : [];
  }

  List<Polyline> _buildEventLines(List<dynamic> routePoints) {
    final List<LatLng> points = routePoints.map((point) {
      final Map<String, dynamic> castedPoint = point;
      return LatLng(castedPoint['latitude'], castedPoint['longitude']);
    }).toList();

    return [
      Polyline(
        polylineId: PolylineId('route'),
        points: points,
        color: Colors.blue,
        width: 3,
      )
    ];
  }
}
