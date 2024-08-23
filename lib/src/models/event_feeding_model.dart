import 'package:cloud_firestore/cloud_firestore.dart';

class EventFeedingModel {
  String id = '';
  late String eventId;
  late String petId;
  late String foodType;
  late double amount; // Ilość w gramach
  late DateTime dateTime;
  late String mood; // ocena posiłku
  late String note; // dodatkowe spostrzeżenia i opis
  late String
      productId; // Identyfikator produktu (jeśli produkt istnieje w systemie)
  late String productName; // Nazwa produktu (może być zeskanowana lub wpisana)

  EventFeedingModel({
    required this.id,
    required this.eventId,
    required this.petId,
    required this.foodType,
    required this.amount,
    required this.dateTime,
    required this.mood,
    required this.note,
    required this.productId,
    required this.productName,
  });

  EventFeedingModel.fromDocument(DocumentSnapshot doc) {
    id = doc.id;
    eventId = doc.get('eventId') ?? '';
    petId = doc.get('petId') ?? '';
    foodType = doc.get('foodType') ?? '';
    amount = doc.get('amount') ?? 0.0;
    dateTime = (doc.get('dateTime') as Timestamp?)?.toDate() ?? DateTime.now();
    mood = doc.get('mood') ?? 'neutral';
    note = doc.get('note') ?? '';
    productId = doc.get('productId') ?? '';
    productName = doc.get('productName') ?? 'Meal';
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'eventId': eventId,
      'petId': petId,
      'foodType': foodType,
      'amount': amount,
      'dateTime': Timestamp.fromDate(dateTime),
      'mood': mood,
      'note': note,
      'productId': productId,
      'productName': productName,
    };
  }
}
