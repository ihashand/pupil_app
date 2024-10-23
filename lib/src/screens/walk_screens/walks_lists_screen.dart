import 'package:firebase_auth/firebase_auth.dart';
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
  int _loadedItems = 3;
  bool _isLoadingMore = false;

  @override
  Widget build(BuildContext context) {
    final globalWalksAsyncValue = ref.watch(globalWalksStreamProvider);
    final petsAsyncValue = ref.watch(petsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'W A L K S  L I S T', // Tekst z ustawieniem wielkich liter i spacjami
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
                      scrollInfo.metrics.maxScrollExtent &&
                  !_isLoadingMore) {
                // Użytkownik doszedł do końca listy, ładujemy więcej spacerów
                setState(() {
                  _isLoadingMore = true;
                  _loadedItems += 3;
                });

                // Dodajemy lekkie opóźnienie dla animacji ładowania
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
                  // Wyświetlanie animacji ładowania na dole
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
                    // Pobieranie zwierząt na podstawie petIds z danego spaceru
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
                          eventLines:
                              _buildEventLines(walk.routePoints), // linie trasy
                          addedEvents: walk.stoolsAndUrine, // wydarzenia
                          photos: _convertImagesToXFiles(walk.images),
                          totalDistance:
                              walk.steps.toStringAsFixed(2), // dystans
                          totalTimeInSeconds:
                              walk.walkTime.toInt(), // czas trwania
                          pets: petsInWalk, // przekazujemy zwierzęta
                          notes: walk.noteId ?? '', isFromWalksListScreen: true,
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
                                  // Wyświetlanie kroków z poprawioną logiką
                                  Text(
                                    'Steps: ${walk.steps.toStringAsFixed(0)}', // Wyświetlanie liczby kroków
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).primaryColorDark,
                                    ),
                                  ),
                                  const SizedBox(
                                      height:
                                          5), // Dodatkowa przestrzeń pomiędzy krokami a czasem
                                  // Wyświetlanie czasu trwania spaceru
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

  // Widget for generating map thumbnail
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
          zoom: 16, // Ustawienie domyślnego zoomu
        ),
        polylines: {
          Polyline(
            polylineId: PolylineId('route'),
            points: points,
            width: 5, // Zmniejszenie szerokości linii
            color: Colors.blue,
          ),
        },
        onMapCreated: (controller) {
          // Skalowanie kamery po załadowaniu mapy
          if (points.isNotEmpty) {
            controller.moveCamera(CameraUpdate.newLatLngBounds(bounds, 120));
          }
        },
      ),
    );
  }

  // Formatowanie czasu trwania spaceru
  String _formatDuration(double totalTimeInSeconds) {
    final int hours = (totalTimeInSeconds ~/ 3600);
    final int minutes = ((totalTimeInSeconds % 3600) ~/ 60);
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
  }

  // Konwersja obrazów do formatu XFile
  List<XFile> _convertImagesToXFiles(List<String>? images) {
    return images != null
        ? images.map((imageUrl) => XFile(imageUrl)).toList()
        : [];
  }

  // Tworzenie linii trasy spaceru
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
