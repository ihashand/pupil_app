import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/models/event_model.dart';
import 'package:pet_diary/src/providers/event_provider.dart';

void deleteEventModule(
  WidgetRef ref,
  List<Event>? allEvents,
  void Function(DateTime date, DateTime focusedDate) selectDate,
  DateTime dateController,
  int index,
) async {
  await ref.watch(eventRepositoryProvider).value?.deleteEvent(index);
  allEvents = ref.refresh(eventRepositoryProvider).value?.getEvents();
  selectDate(dateController, dateController);
}
