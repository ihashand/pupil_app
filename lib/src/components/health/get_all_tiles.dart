import 'package:flutter/material.dart';
import 'package:pet_diary/src/models/events_models/event_model.dart';
import 'package:pet_diary/src/models/others/tile_info.dart';
import 'package:pet_diary/src/screens/health_screens/health_activity_screen.dart';

List<TileInfoModel> getAllTiles(
    BuildContext context, String petId, List<Event> petEvents) {
  return [
    TileInfoModel(
      Icons.directions_walk,
      'A c t i v i t y',
      Colors.blue,
      ['activity', 'walk', 'wandern', 'fit', 'exercise', 'running'],
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => HealthActivityScreen(petId)),
        );
      },
    ),
  ];
}
