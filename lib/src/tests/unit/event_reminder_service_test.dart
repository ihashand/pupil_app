import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pet_diary/src/models/events_models/event_reminder_model.dart';
import 'package:pet_diary/src/services/event_reminder_service.dart';

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
  late EventReminderService service;
  late FakeFirebaseFirestore fakeFirestore;
  late FakeFirebaseAuth fakeAuth;
  late FakeUser fakeUser;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    fakeUser = FakeUser(uid: 'testUserId');
    fakeAuth = FakeFirebaseAuth(user: fakeUser);

    service = EventReminderService(
      firestore: fakeFirestore,
      auth: fakeAuth,
    );
  });

  group('EventReminderService', () {
    test('should remove expired reminders', () async {
      final reminders = [
        EventReminderModel(
          id: '1',
          objectId: 'obj1',
          userId: 'testUserId',
          title: 'Reminder 1',
          description: 'Description 1',
          time: const TimeOfDay(hour: 10, minute: 0),
          dateTime: DateTime.now().subtract(const Duration(hours: 1)),
          endDate: DateTime.now().add(const Duration(hours: 1)),
          selectedDays: [],
          selectedPets: [],
        ),
        EventReminderModel(
          id: '2',
          objectId: 'obj2',
          userId: 'testUserId',
          title: 'Reminder 2',
          description: 'Description 2',
          time: const TimeOfDay(hour: 12, minute: 0),
          dateTime: DateTime.now().add(const Duration(hours: 1)),
          endDate: DateTime.now().add(const Duration(days: 1)),
          selectedDays: [],
          selectedPets: [],
        ),
      ];

      for (var reminder in reminders) {
        await fakeFirestore
            .collection('users')
            .doc('testUserId')
            .collection('event_reminders')
            .doc(reminder.id)
            .set(reminder.toMap());
      }

      await service.removeExpiredReminders();

      final snapshot = await fakeFirestore
          .collection('users')
          .doc('testUserId')
          .collection('event_reminders')
          .get();

      expect(snapshot.docs.length, 1);
      expect(snapshot.docs.first.id, '2');
    });

    test('should delete cyclic reminders after end date', () async {
      final reminders = [
        EventReminderModel(
          id: '1',
          objectId: 'obj1',
          userId: 'testUserId',
          title: 'Cyclic Reminder 1',
          description: 'Description 1',
          time: const TimeOfDay(hour: 10, minute: 0),
          dateTime: DateTime.now().subtract(const Duration(days: 1)),
          endDate: DateTime.now().subtract(const Duration(hours: 1)),
          selectedDays: [],
          selectedPets: [],
        ),
        EventReminderModel(
          id: '2',
          objectId: 'obj1',
          userId: 'testUserId',
          title: 'Cyclic Reminder 2',
          description: 'Description 2',
          time: const TimeOfDay(hour: 12, minute: 0),
          dateTime: DateTime.now().add(const Duration(hours: 1)),
          endDate: DateTime.now().add(const Duration(days: 1)),
          selectedDays: [],
          selectedPets: [],
        ),
      ];

      for (var reminder in reminders) {
        await fakeFirestore
            .collection('users')
            .doc('testUserId')
            .collection('event_reminders')
            .doc(reminder.id)
            .set(reminder.toMap());
      }

      await service.removeExpiredReminders();

      final snapshot = await fakeFirestore
          .collection('users')
          .doc('testUserId')
          .collection('event_reminders')
          .get();

      expect(snapshot.docs.length, 1);
      expect(snapshot.docs.first.id, '2');
    });

    test('should add reminder for multiple pets without duplication', () async {
      final reminder = EventReminderModel(
        id: '1',
        objectId: 'obj1',
        userId: 'testUserId',
        title: 'Reminder for Multiple Pets',
        description: 'Description',
        time: const TimeOfDay(hour: 10, minute: 0),
        dateTime: DateTime.now().add(const Duration(hours: 1)),
        endDate: DateTime.now().add(const Duration(days: 1)),
        selectedDays: [],
        selectedPets: ['pet1', 'pet2', 'pet3'],
      );

      await service.addReminder(reminder);

      final snapshot = await fakeFirestore
          .collection('users')
          .doc('testUserId')
          .collection('event_reminders')
          .get();

      expect(snapshot.docs.length, 1);
      expect(snapshot.docs.first.id, '1');
    });

    test('should add and fetch reminders correctly', () async {
      final reminder = EventReminderModel(
        id: '1',
        objectId: 'obj1',
        userId: 'testUserId',
        title: 'Test Reminder',
        description: 'Description',
        time: const TimeOfDay(hour: 10, minute: 0),
        dateTime: DateTime.now().add(const Duration(hours: 1)),
        endDate: DateTime.now().add(const Duration(days: 1)),
        selectedDays: [],
        selectedPets: ['pet1'],
      );

      await service.addReminder(reminder);

      final fetchedReminders = await service.getReminders();
      expect(fetchedReminders.length, 1);
      expect(fetchedReminders.first.title, 'Test Reminder');
    });

    test('should handle reminders without pets correctly', () async {
      final reminder = EventReminderModel(
        id: '1',
        objectId: 'obj1',
        userId: 'testUserId',
        title: 'Reminder without Pets',
        description: 'Description',
        time: const TimeOfDay(hour: 10, minute: 0),
        dateTime: DateTime.now().add(const Duration(hours: 1)),
        endDate: DateTime.now().add(const Duration(days: 1)),
        selectedDays: [],
        selectedPets: [],
      );

      await service.addReminder(reminder);

      final snapshot = await fakeFirestore
          .collection('users')
          .doc('testUserId')
          .collection('event_reminders')
          .get();

      expect(snapshot.docs.length, 1);
      expect(snapshot.docs.first.id, '1');
    });

    test('should delete reminder correctly', () async {
      final reminder = EventReminderModel(
        id: '1',
        objectId: 'obj1',
        userId: 'testUserId',
        title: 'Reminder to Delete',
        description: 'Description',
        time: const TimeOfDay(hour: 10, minute: 0),
        dateTime: DateTime.now().add(const Duration(hours: 1)),
        endDate: DateTime.now().add(const Duration(days: 1)),
        selectedDays: [],
        selectedPets: ['pet1'],
      );

      await service.addReminder(reminder);
      await service.deleteReminder(reminder.id);

      final snapshot = await fakeFirestore
          .collection('users')
          .doc('testUserId')
          .collection('event_reminders')
          .get();

      expect(snapshot.docs.isEmpty, true);
    });

    test('should remove expired reminders', () async {
      final reminders = [
        EventReminderModel(
          id: '1',
          objectId: 'obj1',
          userId: 'testUserId',
          title: 'Reminder 1',
          description: 'Description 1',
          time: const TimeOfDay(hour: 10, minute: 0),
          dateTime: DateTime.now().subtract(const Duration(hours: 1)),
          endDate: DateTime.now().subtract(const Duration(hours: 1)),
          selectedDays: [],
          selectedPets: [],
        ),
        EventReminderModel(
          id: '2',
          objectId: 'obj2',
          userId: 'testUserId',
          title: 'Reminder 2',
          description: 'Description 2',
          time: const TimeOfDay(hour: 12, minute: 0),
          dateTime: DateTime.now().add(const Duration(hours: 1)),
          endDate: DateTime.now().add(const Duration(days: 1)),
          selectedDays: [],
          selectedPets: [],
        ),
      ];

      for (var reminder in reminders) {
        await fakeFirestore
            .collection('users')
            .doc('testUserId')
            .collection('event_reminders')
            .doc(reminder.id)
            .set(reminder.toMap());
      }

      await service.removeExpiredReminders();

      final snapshot = await fakeFirestore
          .collection('users')
          .doc('testUserId')
          .collection('event_reminders')
          .get();

      expect(snapshot.docs.length, 1);
      expect(snapshot.docs.first.id, '2');
    });

    test('should not remove ongoing reminders', () async {
      final reminders = [
        EventReminderModel(
          id: '1',
          objectId: 'obj1',
          userId: 'testUserId',
          title: 'Reminder 1',
          description: 'Description 1',
          time: const TimeOfDay(hour: 10, minute: 0),
          dateTime: DateTime.now().subtract(const Duration(hours: 1)),
          endDate: DateTime.now().add(const Duration(days: 1)),
          selectedDays: [],
          selectedPets: [],
          repeatOption: 'Daily',
        ),
        EventReminderModel(
          id: '2',
          objectId: 'obj2',
          userId: 'testUserId',
          title: 'Reminder 2',
          description: 'Description 2',
          time: const TimeOfDay(hour: 12, minute: 0),
          dateTime: DateTime.now().add(const Duration(hours: 1)),
          endDate: DateTime.now().add(const Duration(days: 1)),
          selectedDays: [],
          selectedPets: [],
        ),
      ];

      for (var reminder in reminders) {
        await fakeFirestore
            .collection('users')
            .doc('testUserId')
            .collection('event_reminders')
            .doc(reminder.id)
            .set(reminder.toMap());
      }

      await service.removeExpiredReminders();

      final snapshot = await fakeFirestore
          .collection('users')
          .doc('testUserId')
          .collection('event_reminders')
          .get();

      expect(snapshot.docs.length, 2);
    });
  });
}
