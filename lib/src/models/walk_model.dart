import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong2/latlong.dart';

class WalkModel {
  late String id;
  late String userId;
  late String petId;
  late DateTime startTime;
  late DateTime endTime;
  late int steps;
  late double calories;
  late double distance;
  late List<LatLng> routePoints;
  late List<LatLng> stopPoints;

  WalkModel({
    required this.id,
    required this.userId,
    required this.petId,
    required this.startTime,
    required this.endTime,
    required this.steps,
    required this.calories,
    required this.distance,
    required this.routePoints,
    required this.stopPoints,
  });

  WalkModel.fromDocument(DocumentSnapshot doc) {
    id = doc.id;
    userId = doc.get('userId');
    petId = doc.get('petId');
    startTime = (doc.get('startTime') as Timestamp).toDate();
    endTime = (doc.get('endTime') as Timestamp).toDate();
    steps = doc.get('steps');
    calories = doc.get('calories');
    distance = doc.get('distance');
    routePoints = (doc.get('routePoints') as List)
        .map((e) => LatLng(e['latitude'], e['longitude']))
        .toList();
    stopPoints = (doc.get('stopPoints') as List)
        .map((e) => LatLng(e['latitude'], e['longitude']))
        .toList();
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'petId': petId,
      'startTime': startTime,
      'endTime': endTime,
      'steps': steps,
      'calories': calories,
      'distance': distance,
      'routePoints': routePoints
          .map((point) =>
              {'latitude': point.latitude, 'longitude': point.longitude})
          .toList(),
      'stopPoints': stopPoints
          .map((point) =>
              {'latitude': point.latitude, 'longitude': point.longitude})
          .toList(),
    };
  }
}
