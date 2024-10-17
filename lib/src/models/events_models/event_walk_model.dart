import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong2/latlong.dart';

class EventWalkModel {
  String id;
  double walkTime;
  double steps;
  String eventId;
  String petId;
  DateTime dateTime;
  double caloriesBurned;
  double distance;
  List<LatLng> routePoints;
  List<String>? images;
  String? notes;
  Map<String, dynamic>? events;

  EventWalkModel({
    required this.id,
    required this.walkTime,
    required this.eventId,
    required this.petId,
    required this.steps,
    required this.dateTime,
    required this.caloriesBurned,
    required this.distance,
    required this.routePoints,
    this.images,
    this.notes,
    this.events,
  });

  EventWalkModel.fromDocument(DocumentSnapshot doc)
      : id = doc.id,
        walkTime = doc.get('walkTime'),
        steps = doc.get('steps') ?? 0.0,
        eventId = doc.get('eventId') ?? '',
        petId = doc.get('petId') ?? '',
        dateTime =
            (doc.get('dateTime') as Timestamp?)?.toDate() ?? DateTime.now(),
        caloriesBurned = doc.get('caloriesBurned') ?? 0.0,
        distance = doc.get('distance') ?? 0.0,
        routePoints = (doc.get('routePoints') as List<dynamic>)
            .map((point) => LatLng(point['latitude'], point['longitude']))
            .toList(),
        images = (doc.data() as Map<String, dynamic>).containsKey('images')
            ? List<String>.from(doc.get('images'))
            : [],
        notes =
            (doc.data() as Map<String, dynamic>?)?.containsKey('notes') == true
                ? doc.get('notes')
                : null,
        events =
            (doc.data() as Map<String, dynamic>?)?.containsKey('events') == true
                ? doc.get('events')
                : null;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'walkTime': walkTime,
      'steps': steps,
      'eventId': eventId,
      'petId': petId,
      'dateTime': Timestamp.fromDate(dateTime),
      'caloriesBurned': caloriesBurned,
      'distance': distance,
      'routePoints': routePoints
          .map((point) =>
              {'latitude': point.latitude, 'longitude': point.longitude})
          .toList(),
      if (images != null) 'images': images,
      if (notes != null) 'notes': notes,
      if (events != null) 'events': events,
    };
  }
}
