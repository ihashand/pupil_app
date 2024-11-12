import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:apple_maps_flutter/apple_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:pet_diary/src/helpers/animations/slide_animation_helper.dart';
import 'package:pet_diary/src/helpers/messages/empty_state_widget.dart';
import 'package:pet_diary/src/screens/walk_screens/walk_summary_screen.dart';
import 'package:pet_diary/src/providers/walks_providers/global_walk_provider.dart';
import 'package:pet_diary/src/providers/others_providers/pet_provider.dart';

class ActivityScreen extends ConsumerStatefulWidget {
  final String? petId;

  const ActivityScreen({super.key, this.petId});

  @override
  ConsumerState<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends ConsumerState<ActivityScreen> {
  int _loadedItems = 3;
  bool _isLoadingMore = false;

  @override
  Widget build(BuildContext context) {
    final globalWalksAsyncValue = ref.watch(globalWalksStreamProvider);
    final petsAsyncValue = ref.watch(petsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'A C T I V I T Y',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: globalWalksAsyncValue.when(
        data: (walks) {
          if (widget.petId != null) {
            walks = walks
                .where((walk) => walk.petIds.contains(widget.petId))
                .toList();
          }

          if (walks.isEmpty) {
            return const Center(
                child: SlideAnimationHelper(
              duration: Duration(milliseconds: 2600),
              curve: Curves.bounceOut,
              child: EmptyStateWidget(
                message:
                    "No walks activities yet.\nStart exploring with your pet!",
                icon: Icons.pets,
              ),
            ));
          }

          walks.sort((a, b) => b.dateTime.compareTo(a.dateTime));

          return NotificationListener<ScrollNotification>(
            onNotification: (ScrollNotification scrollInfo) {
              if (scrollInfo.metrics.pixels ==
                      scrollInfo.metrics.maxScrollExtent &&
                  !_isLoadingMore) {
                setState(() {
                  _isLoadingMore = true;
                  _loadedItems += 3;
                });

                Future.delayed(const Duration(seconds: 1), () {
                  setState(() {
                    _isLoadingMore = false;
                  });
                });
              }
              return true;
            },
            child: ListView.builder(
              itemCount: _loadedItems >= walks.length
                  ? walks.length
                  : _loadedItems + 1,
              itemBuilder: (context, index) {
                if (index == _loadedItems) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                final walk = walks[index];
                return GestureDetector(
                  onTap: () async {
                    final pets = await ref
                        .read(petServiceProvider)
                        .getPetsByUserId(
                            FirebaseAuth.instance.currentUser!.uid);
                    final petsInWalk = pets
                        .where((pet) => walk.petIds.contains(pet.id))
                        .toList();

                    // ignore: use_build_context_synchronously
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => WalkSummaryScreen(
                          eventLines: _buildEventLines(walk.routePoints),
                          addedEvents: walk.stoolsAndUrine,
                          photos: _convertImagesToXFiles(walk.images),
                          totalDistance: walk.steps.toStringAsFixed(2),
                          totalTimeInSeconds: walk.walkTime.toInt(),
                          pets: petsInWalk,
                          notes: walk.noteId ?? '',
                          isFromWalksListScreen: true,
                        ),
                      ),
                    );
                  },
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(22),
                    ),
                    margin: const EdgeInsets.all(10),
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(22),
                                topRight: Radius.circular(22),
                              ),
                              child: _buildMapThumbnail(walk.routePoints),
                            ),
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
                                  crossAxisAlignment: CrossAxisAlignment.end,
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
                                      DateFormat('HH:mm').format(walk.dateTime),
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
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              petsAsyncValue.when(
                                data: (pets) {
                                  final petsInWalk = pets
                                      .where(
                                          (pet) => walk.petIds.contains(pet.id))
                                      .toList();
                                  return Row(
                                    children: petsInWalk.map((pet) {
                                      return Padding(
                                        padding:
                                            const EdgeInsets.only(right: 8.0),
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
                                error: (error, stack) => Text('Error: $error'),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Steps: ${walk.steps.toStringAsFixed(0)}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).primaryColorDark,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    'Duration: ${_formatDuration(walk.walkTime)}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).primaryColorDark,
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
        error: (error, stackTrace) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _buildMapThumbnail(List<dynamic> routePoints) {
    final points = routePoints.map((point) {
      final Map<String, dynamic> castedPoint = point;
      return LatLng(castedPoint['latitude'], castedPoint['longitude']);
    }).toList();

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
          zoom: 16,
        ),
        polylines: {
          Polyline(
            polylineId: PolylineId('route'),
            points: points,
            width: 5,
            color: Colors.blue,
          ),
        },
        onMapCreated: (controller) {
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
        width: 5,
      )
    ];
  }
}
