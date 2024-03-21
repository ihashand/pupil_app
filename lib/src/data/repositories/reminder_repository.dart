import 'package:hive_flutter/hive_flutter.dart';
import 'package:pet_diary/src/models/reminder_model.dart';

class ReminderRepository {
  late Box<Reminder> _hive;
  late List<Reminder> _box;

  ReminderRepository._create();

  static Future<ReminderRepository> create() async {
    final component = ReminderRepository._create();
    await component._init();
    return component;
  }

  _init() async {
    _hive = await Hive.openBox<Reminder>('reminderBox');
    _box = _hive.values.toList();
  }

  List<Reminder> getReminders() {
    return _box;
  }

  Future<void> addReminder(Reminder reminder) async {
    await _hive.put(reminder.id, reminder);
  }

  Future<void> updateReminder(Reminder reminder) async {
    await _hive.put(reminder.id, reminder);
  }

  Future<void> deleteReminder(String reminderId) async {
    await _hive.delete(reminderId);
    await _init();
  }

  Reminder? getReminderById(String reminderId) {
    return _hive.get(reminderId);
  }
}
