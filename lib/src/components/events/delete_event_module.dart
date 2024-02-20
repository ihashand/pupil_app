import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/models/event_model.dart';
import 'package:pet_diary/src/providers/event_provider.dart';

void deleteEventModule(
  WidgetRef ref,
  List<Event>? allEvents,
  void Function(DateTime date, DateTime focusedDate) selectDate,
  DateTime dateController,
  String id,
) async {
  final int indexToDelete =
      allEvents?.indexWhere((event) => event.id == id) ?? -1;

  await ref.watch(eventRepositoryProvider).value?.deleteEvent(indexToDelete);
  allEvents = ref.refresh(eventRepositoryProvider).value?.getEvents();
  selectDate(dateController, dateController);
}
