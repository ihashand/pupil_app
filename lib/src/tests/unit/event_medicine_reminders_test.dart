import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pet_diary/src/helpers/others/generate_unique_id.dart';
import 'package:pet_diary/src/models/events_models/event_medicine_model.dart';
import 'package:pet_diary/src/services/events_services/event_medicine_service.dart';

class FakeFirebaseAuth extends Fake implements FirebaseAuth {
  final User? user;
  FakeFirebaseAuth({this.user});

  @override
  User? get currentUser => user;
}

class FakeUser extends Fake implements User {
  @override
  final String uid;
  FakeUser({required this.uid});
}

void main() {
  late EventMedicineService service;
  late FakeFirebaseFirestore fakeFirestore;
  late FakeFirebaseAuth fakeAuth;
  late FakeUser fakeUser;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    fakeUser = FakeUser(uid: 'testUserId');
    fakeAuth = FakeFirebaseAuth(user: fakeUser);

    service = EventMedicineService(
      firestore: fakeFirestore,
      auth: fakeAuth,
    );
  });

  group('EventMedicineService', () {
    test('should schedule daily notifications', () async {
      DateTime startDate = DateTime(2023, 10, 1);
      DateTime endDate = DateTime(2023, 10, 10);
      List<TimeOfDay> times = [TimeOfDay(hour: 8, minute: 0)];
      String medicineId = generateUniqueId();
      final newMedicine = EventMedicineModel(
        id: medicineId,
        name: 'Daily Medicine',
        petId: 'pet123',
        eventId: generateUniqueId(),
        frequency: '1',
        dosage: '100mg',
        emoji: '💊',
        startDate: startDate,
        endDate: endDate,
        remindersEnabled: true,
        scheduleDetails: 'Daily',
        medicineType: 'Capsule',
        times: times,
      );

      await service.addMedicine(newMedicine);

      // Pobranie leków (wymuszenie synchronizacji)
      final pillsSnapshot = await fakeFirestore
          .collection('event_medicines')
          .where('name', isEqualTo: 'Daily Medicine')
          .get();

      // Sprawdzenie liczby dokumentów
      expect(pillsSnapshot.docs.length,
          (endDate.difference(startDate).inDays + 1) * times.length);
    });

    test('should schedule every X days notifications', () async {
      DateTime startDate = DateTime(2023, 10, 1);
      DateTime endDate = DateTime(2023, 10, 10);
      List<TimeOfDay> times = [TimeOfDay(hour: 10, minute: 0)];
      String medicineId = generateUniqueId();
      final newMedicine = EventMedicineModel(
        id: medicineId,
        name: 'Medicine Every 2 Days',
        petId: 'pet123',
        eventId: generateUniqueId(),
        frequency: '1',
        dosage: '100mg',
        emoji: '💊',
        startDate: startDate,
        endDate: endDate,
        remindersEnabled: true,
        scheduleDetails: 'Every 2 Days',
        medicineType: 'Capsule',
        times: times,
      );

      await service.addMedicine(newMedicine);

      // Pobranie leków (wymuszenie synchronizacji)
      final pillsSnapshot = await fakeFirestore
          .collection('event_medicines')
          .where('name', isEqualTo: 'Medicine Every 2 Days')
          .get();

      // Sprawdzamy liczbę powiadomień dla co 2 dni
      int expectedNotificationCount =
          ((endDate.difference(startDate).inDays ~/ 2) + 1) * times.length;
      expect(pillsSnapshot.docs.length, expectedNotificationCount);
    });
  });
}
