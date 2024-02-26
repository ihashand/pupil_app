import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/models/event_model.dart';
import 'package:pet_diary/src/providers/event_provider.dart';
import 'package:pet_diary/src/providers/weight_provider.dart';

void deleteEventModule(
  WidgetRef ref,
  List<Event>? allEvents,
  void Function(DateTime date, DateTime focusedDate) selectDate,
  DateTime dateController,
  String eventId,
  String petId,
) async {
  final int indexToDeleteEvent =
      allEvents?.indexWhere((e) => e.id == eventId) ?? -1;
  var event = allEvents?.where((element) => element.id == eventId).first;
  var allWeights = ref.watch(weightRepositoryProvider).value?.getWeights();

  final int indexToDeleteWeight =
      allWeights?.indexWhere((w) => w.id == event!.weightId) ?? -1;

  if (indexToDeleteEvent != -1) {
    await ref
        .watch(eventRepositoryProvider)
        .value
        ?.deleteEvent(indexToDeleteEvent);
    ref.refresh(eventRepositoryProvider);
  }

  if (indexToDeleteWeight != -1) {
    await ref
        .watch(weightRepositoryProvider)
        .value
        ?.deleteWeight(indexToDeleteWeight);
    ref.refresh(weightRepositoryProvider);
  }

  selectDate(dateController, dateController);
}
