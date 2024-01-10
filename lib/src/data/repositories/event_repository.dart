import 'package:hive_flutter/hive_flutter.dart';
import '../../models/event_model.dart';

class EventRepository {
  late Box<Event> _hive;
  late List<Event> _box;
  EventRepository._create();

  static Future<EventRepository> create() async {
    final component = EventRepository._create();
    await component._init();
    return component;
  }

  _init() async {
    _hive = await Hive.openBox<Event>('eventBox');
    _box = _hive.values.toList();
  }

  List<Event> getEvents() {
    return _box;
  }

  Future<void> addEvent(Event event) async {
    await _hive.put(event.id, event);
    await _init();
  }

  Future<void> updateEvent(Event event) async {
    await _hive.put(event.id, event);
  }

  Future<void> deleteEvent(int index) async {
    await _hive.deleteAt(index);
  }

  Future<Event?> getEventById(String petId) async {
    return _hive.get(petId);
  }
}
