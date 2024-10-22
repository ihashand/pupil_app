import 'package:apple_maps_flutter/apple_maps_flutter.dart' as apple_maps;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pet_diary/src/components/events/walk/walk_summary_modal.dart';
import 'package:pet_diary/src/models/others/pet_model.dart';

void showWalkSummary(
    BuildContext context,
    List<apple_maps.Polyline> eventLines,
    List<Map<String, dynamic>> addedEvents,
    List<XFile> photos,
    String totalDistance,
    int totalTimeInSeconds,
    List<Pet> pets,
    String notes) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
    ),
    builder: (context) {
      return WalkSummaryModal(
        eventLines: eventLines,
        addedEvents: addedEvents,
        photos: photos,
        totalDistance: totalDistance,
        totalTimeInSeconds: totalTimeInSeconds,
        pets: pets,
        notes: notes,
      );
    },
  );
}
