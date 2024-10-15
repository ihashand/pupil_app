import 'dart:io';
import 'package:flutter/material.dart';
import 'package:apple_maps_flutter/apple_maps_flutter.dart' as apple_maps;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:pet_diary/src/models/others/pet_model.dart';

class WalkSummaryScreen extends StatelessWidget {
  final List<apple_maps.Polyline> eventLines;
  final List<Map<String, dynamic>> addedEvents;
  final List<XFile> photos;
  final String totalDistance;
  final int totalTimeInSeconds;
  final List<Pet> pets;
  final String notes;

  const WalkSummaryScreen({
    Key? key,
    required this.eventLines,
    required this.addedEvents,
    required this.photos,
    required this.totalDistance,
    required this.totalTimeInSeconds,
    required this.pets,
    required this.notes,
  }) : super(key: key);

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
      ),
      body: Column(
        children: [
          _buildMapSection(context),
          Divider(
            height: 1,
            thickness: 1,
            color: Theme.of(context).colorScheme.secondary,
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildProgressBarWithDetails(context),
                  if (addedEvents.isNotEmpty) _buildEventList(context),
                  if (photos.isNotEmpty) _buildPhotos(context),
                  if (notes.isNotEmpty) _buildNotesSection(context),
                  _buildFinalizeButton(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapSection(BuildContext context) {
    return Container(
      height: 225,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(15),
          bottomRight: Radius.circular(15),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: apple_maps.AppleMap(
          minMaxZoomPreference: const apple_maps.MinMaxZoomPreference(10, 16),
          polylines: eventLines.toSet(),
          initialCameraPosition: apple_maps.CameraPosition(
            target: eventLines.isNotEmpty
                ? eventLines.first.points.first
                : const apple_maps.LatLng(0, 0),
            zoom: 16,
          ),
          zoomGesturesEnabled: false,
          scrollGesturesEnabled: true,
          onMapCreated: (apple_maps.AppleMapController controller) {
            // Dalsze ustawienia jeśli potrzebne
          },
        ),
      ),
    );
  }

  Widget _buildProgressBarWithDetails(BuildContext context) {
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
                          value: double.parse(totalDistance) /
                              10, // Assuming max distance
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
                              fontWeight: FontWeight.bold),
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
                              fontWeight: FontWeight.bold),
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
                  .map(
                    (pet) => Stack(
                      clipBehavior: Clip.none,
                      children: [
                        CircleAvatar(
                          backgroundImage: AssetImage(pet.avatarImage),
                          radius: 25,
                        ),
                      ],
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventList(BuildContext context) {
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
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 10),
            ...addedEvents.map((event) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 5.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${event['icon']}  ${event['label']}',
                      style: TextStyle(
                        fontSize: 15,
                        color: Theme.of(context).primaryColorDark,
                      ),
                    ),
                    Text(
                      DateFormat('HH:mm').format(event['time']),
                      style: TextStyle(
                        fontSize: 13,
                        color: Theme.of(context).primaryColorDark,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotos(BuildContext context) {
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
                fontSize: 11,
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

  Widget _buildNotesSection(BuildContext context) {
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
                fontSize: 11,
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

  Widget _buildFinalizeButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: ElevatedButton(
        onPressed: () {
          // Save the data
          Navigator.of(context).pop();
        },
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
          backgroundColor: Theme.of(context).colorScheme.secondary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          'S A V E  W A L K',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColorDark,
          ),
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
