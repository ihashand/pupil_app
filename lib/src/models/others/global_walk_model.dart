import 'package:cloud_firestore/cloud_firestore.dart';

class GlobalWalkModel {
  String id;
  List<String> individualWalkIds;
  List<String> petIds;
  DateTime dateTime;
  List<Map<String, double>> routePoints;
  double walkTime;
  double steps;
  List<Map<String, dynamic>> stoolsAndUrine;
  List<String>? images;
  String? noteId;

  GlobalWalkModel({
    required this.id,
    required this.individualWalkIds,
    required this.petIds,
    required this.dateTime,
    required this.routePoints,
    required this.walkTime,
    required this.steps,
    required this.stoolsAndUrine,
    this.images,
    this.noteId,
  });

  // Konwersja z dokumentu Firestore do obiektu
  GlobalWalkModel.fromDocument(DocumentSnapshot doc)
      : id = doc.id,
        individualWalkIds = List<String>.from(doc.get('individualWalkIds')),
        petIds = List<String>.from(doc.get('petIds')),
        dateTime = (doc.get('dateTime') as Timestamp).toDate(),
        routePoints = (doc.get('routePoints') as List<dynamic>)
            .map((point) => {
                  'latitude': (point['latitude'] as num).toDouble(),
                  'longitude': (point['longitude'] as num).toDouble(),
                })
            .toList(),
        walkTime = doc.get('walkTime'),
        steps = doc.get('steps'),
        stoolsAndUrine =
            List<Map<String, dynamic>>.from(doc.get('stoolsAndUrine')),
        images =
            (doc.data() as Map<String, dynamic>).containsKey('images') == true
                ? List<String>.from(doc.get('images'))
                : null,
        noteId =
            (doc.data() as Map<String, dynamic>).containsKey('noteId') == true
                ? doc.get('noteId')
                : null;

  // Konwersja z obiektu na mapę do zapisu w Firestore
  Map<String, dynamic> toMap() {
    return {
      'individualWalkIds': individualWalkIds,
      'petIds': petIds,
      'dateTime': Timestamp.fromDate(dateTime),
      'routePoints': routePoints
          .map((point) => {
                'latitude': point['latitude'],
                'longitude': point['longitude'],
              })
          .toList(),
      'walkTime': walkTime,
      'steps': steps,
      'stoolsAndUrine': stoolsAndUrine,
      if (images != null) 'images': images,
      if (noteId != null) 'noteId': noteId,
    };
  }
}
