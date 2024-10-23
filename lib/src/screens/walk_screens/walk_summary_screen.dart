import 'dart:io';
import 'package:apple_maps_flutter/apple_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:pet_diary/src/models/others/pet_model.dart';
import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:image/image.dart' as img;

class WalkSummaryScreen extends StatelessWidget {
  final List<Polyline> eventLines;
  final List<Map<String, dynamic>> addedEvents;
  final List<XFile> photos;
  final String totalDistance;
  final int totalTimeInSeconds;
  final List<Pet> pets;
  final String notes;

  const WalkSummaryScreen({
    super.key,
    required this.eventLines,
    required this.addedEvents,
    required this.photos,
    required this.totalDistance,
    required this.totalTimeInSeconds,
    required this.pets,
    required this.notes,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: const Text(
          'W A L K  S U M M A R Y',
          style: TextStyle(
            fontSize: 13,
            letterSpacing: 2,
            fontWeight: FontWeight.bold,
          ),
        ),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Divider(
            height: 1,
            thickness: 1,
            color: Theme.of(context).colorScheme.surface,
          ),
          FutureBuilder<Set<Annotation>>(
            future: _buildEventAnnotations(addedEvents),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                // Zwraca loader podczas ładowania danych
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                // Obsługa błędu
                return Center(
                    child:
                        Text('Error loading annotations: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                // Obsługa braku danych
                return const Center(child: Text('No annotations available'));
              } else {
                // Jeśli wszystko się udało, wyświetlamy mapę
                return _buildMapSection(context, eventLines, snapshot.data!);
              }
            },
          ),
          Divider(
            height: 1,
            thickness: 1,
            color: Theme.of(context).colorScheme.secondary,
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  _buildProgressBarWithDetails(
                      context, totalDistance, totalTimeInSeconds, pets),
                  const SizedBox(height: 10),
                  if (addedEvents.isNotEmpty)
                    _buildEventList(context, addedEvents),
                  const SizedBox(height: 10),
                  if (photos.isNotEmpty) _buildPhotos(context, photos),
                  const SizedBox(height: 10),
                  if (notes.isNotEmpty) _buildNotesSection(context, notes),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapSection(BuildContext context, List<Polyline> eventLines,
      Set<Annotation> annotations) {
    return SizedBox(
      height: 225,
      width: double.infinity,
      child: AppleMap(
        initialCameraPosition: CameraPosition(
          target: eventLines.isNotEmpty && eventLines.first.points.isNotEmpty
              ? eventLines.first.points.first
              : const LatLng(51.5, -0.09),
          zoom: 16,
        ),
        zoomGesturesEnabled: true,
        scrollGesturesEnabled: true,
        rotateGesturesEnabled: true,
        polylines: eventLines.toSet(),
        annotations: annotations,
        onMapCreated: (AppleMapController controller) {},
      ),
    );
  }

  Future<Set<Annotation>> _buildEventAnnotations(
      List<Map<String, dynamic>> addedEvents) async {
    Set<Annotation> annotations = {};

    for (var event in addedEvents) {
      final dynamic eventLocation = event['location'];

      // Sprawdzenie struktury danych
      if (eventLocation is Map<String, dynamic> &&
          eventLocation.containsKey('latitude') &&
          eventLocation.containsKey('longitude')) {
        final double latitude = eventLocation['latitude'] is double
            ? eventLocation['latitude']
            : double.tryParse(eventLocation['latitude'].toString()) ?? 0.0;
        final double longitude = eventLocation['longitude'] is double
            ? eventLocation['longitude']
            : double.tryParse(eventLocation['longitude'].toString()) ?? 0.0;

        // Sprawdzenie, czy event to Stool czy Urine i przypisanie odpowiedniego obrazka
        final String assetPath = (event['label'] == 'Stool')
            ? 'assets/images/events_type_cards_no_background/poo.png'
            : 'assets/images/events_type_cards_no_background/piee.png';

        // Zamiast bezpośredniego Uint8List, utworzymy BitmapDescriptor
        final Uint8List resizedImageData = await _getResizedImageData(
            assetPath, 124); // Zmniejszenie rozmiaru do 124
        final BitmapDescriptor bitmapDescriptor =
            BitmapDescriptor.fromBytes(resizedImageData);

        // Konwersja Timestamp na DateTime
        final DateTime eventTime = (event['time'] is Timestamp)
            ? (event['time'] as Timestamp).toDate()
            : event['time'] as DateTime;

        annotations.add(
          Annotation(
            annotationId: AnnotationId(event['id']),
            position: LatLng(latitude, longitude),
            icon: bitmapDescriptor,
            infoWindow: InfoWindow(
              title: event['label'],
              snippet: DateFormat('HH:mm')
                  .format(eventTime), // Poprawiona konwersja na DateTime
            ),
          ),
        );
      } else {
        debugPrint('Invalid event location format: $eventLocation');
      }
    }

    return annotations;
  }

// Function to resize the image
  Future<Uint8List> _getResizedImageData(String assetPath, int size) async {
    ByteData imageData = await rootBundle.load(assetPath);
    List<int> bytes = imageData.buffer.asUint8List();
    img.Image? image = img.decodeImage(Uint8List.fromList(bytes));
    img.Image resizedImage = img.copyResize(image!, width: size, height: size);
    return Uint8List.fromList(img.encodePng(resizedImage));
  }

  Widget _buildProgressBarWithDetails(BuildContext context,
      String totalDistance, int totalTimeInSeconds, List<Pet> pets) {
    final durationFormatted = _formatTime(totalTimeInSeconds);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 25.0),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 5.0),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 70,
                        height: 70,
                        child: CircularProgressIndicator(
                          value: totalTimeInSeconds / 3600,
                          strokeWidth: 9,
                          backgroundColor:
                              Theme.of(context).colorScheme.surface,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                              Color(0xffdfd785)),
                        ),
                      ),
                      SizedBox(
                        width: 60,
                        height: 60,
                        child: CircularProgressIndicator(
                          value: double.parse(totalDistance) / 10,
                          strokeWidth: 6,
                          backgroundColor:
                              Theme.of(context).colorScheme.surface,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                              Color(0xff68a2b6)),
                        ),
                      ),
                      Icon(Icons.pets,
                          size: 24, color: Theme.of(context).primaryColorDark),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Duration:   ',
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).primaryColorDark,
                          ),
                        ),
                        Text(
                          durationFormatted,
                          style: TextStyle(
                            fontSize: 15,
                            color: Theme.of(context).primaryColorDark,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          'Distance:   ',
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).primaryColorDark,
                          ),
                        ),
                        Text(
                          '$totalDistance km',
                          style: TextStyle(
                            fontSize: 15,
                            color: Theme.of(context).primaryColorDark,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0, bottom: 8),
              child: Divider(
                color: Theme.of(context).colorScheme.surface,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 15.0),
              child: Text(
                'P U P S  O N  W A L K:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                  color: Theme.of(context).primaryColorDark,
                ),
              ),
            ),
            Wrap(
              alignment: WrapAlignment.start,
              spacing: 8.0,
              runSpacing: 8.0,
              children: pets
                  .map((pet) => Stack(
                        clipBehavior: Clip.none,
                        children: [
                          CircleAvatar(
                            backgroundImage: AssetImage(pet.avatarImage),
                            radius: 25,
                          ),
                        ],
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventList(
      BuildContext context, List<Map<String, dynamic>> addedEvents) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 25.0),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'E V E N T S:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 10),
            ...addedEvents.map((event) {
              final DateTime eventTime = (event['time'] is Timestamp)
                  ? (event['time'] as Timestamp).toDate()
                  : event['time'];

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 5.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Text(
                            event['icon'],
                            style: const TextStyle(fontSize: 40),
                          ),
                          const SizedBox(width: 15),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                event['label'],
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              CircleAvatar(
                                backgroundImage: AssetImage(event['petAvatar']),
                                radius: 16,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Text(
                      DateFormat('HH:mm').format(eventTime),
                      style: TextStyle(
                        fontSize: 13,
                        color: Theme.of(context).primaryColorDark,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotos(BuildContext context, List<XFile> photos) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 25.0),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'P H O T O S:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: photos.map((photo) {
                return GestureDetector(
                  onTap: () {
                    _showPhotoPreview(context, photo);
                  },
                  child: Image.file(
                    File(photo.path),
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  void _showPhotoPreview(BuildContext context, XFile photo) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          content: SizedBox(
            width: 350,
            height: 350,
            child: Image.file(
              File(photo.path),
              fit: BoxFit.contain,
            ),
          ),
        );
      },
    );
  }

  Widget _buildNotesSection(BuildContext context, String notes) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 25.0),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'N O T E S:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              notes,
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(int totalSeconds) {
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;

    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}
