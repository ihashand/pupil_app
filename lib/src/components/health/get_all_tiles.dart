import 'package:flutter/material.dart';
import 'package:pet_diary/src/models/event_model.dart';
import 'package:pet_diary/src/models/tile_info.dart';
import 'package:pet_diary/src/screens/health_activity_screen.dart';

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
    TileInfoModel(
      Icons.mood,
      'M o o d',
      Colors.amber,
      ['mood', 'emotion', 'feeling', 'happiness', 'sadness', 'joy'],
      onTap: () {},
    ),
    TileInfoModel(
      Icons.medication,
      'M e d i c a t i o n s',
      Colors.green,
      ['medication', 'drugs', 'pills', 'therapy', 'prescription', 'dosage'],
      onTap: () {
        // Add onTap logic for Medications tile
      },
    ),
    TileInfoModel(
      Icons.warning,
      'S y m p t o m s',
      Colors.red,
      ['symptom', 'illness', 'pain', 'discomfort', 'condition', 'disease'],
      onTap: () {
        // Add onTap logic for Symptoms tile
      },
    ),
    TileInfoModel(
      Icons.timeline,
      'M e a s u r e m e n t s',
      Colors.orange,
      ['measurement', 'data', 'metrics', 'record', 'result', 'analysis'],
      onTap: () {
        // Add onTap logic for Measurements tile
      },
    ),
    TileInfoModel(
      Icons.bedtime,
      'S l e e p',
      Colors.indigo,
      ['sleep', 'rest', 'nap', 'slumber', 'insomnia', 'bedtime'],
      onTap: () {
        // Add onTap logic for Sleep tile
      },
    ),
    TileInfoModel(
      Icons.favorite,
      'H e a r t',
      Colors.pink,
      ['heart', 'cardio', 'pulse', 'blood pressure', 'rate', 'exercise'],
      onTap: () {
        // Add onTap logic for Heart tile
      },
    ),
    TileInfoModel(
      Icons.track_changes,
      'C y c l e',
      Colors.teal,
      [
        'cycle',
        'period',
        'menstruation',
        'ovulation',
        'fertility',
        'reproductive'
      ],
      onTap: () {
        // Add onTap logic for Cycle tile
      },
    ),
    TileInfoModel(
      Icons.pregnant_woman,
      'P r e g n a n c y',
      Colors.deepOrange,
      ['pregnancy', 'maternity', 'expecting', 'baby', 'prenatal', 'parenthood'],
      onTap: () {
        // Add onTap logic for Pregnancy tile
      },
    ),
    TileInfoModel(
      Icons.dashboard_customize,
      'O t h e r  D a t a',
      Colors.brown,
      ['data', 'information', 'records', 'details', 'statistics', 'history'],
      onTap: () {
        // Add onTap logic for Other Data tile
      },
    ),
  ];
}
