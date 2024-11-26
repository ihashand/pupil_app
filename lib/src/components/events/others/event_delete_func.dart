// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/helpers/others/loading_dialog.dart';
import 'package:pet_diary/src/models/events_models/event_model.dart';
import 'package:pet_diary/src/providers/events_providers/event_care_provider.dart';
import 'package:pet_diary/src/providers/events_providers/event_provider.dart';
import 'package:pet_diary/src/providers/events_providers/event_mood_provider.dart';
import 'package:pet_diary/src/providers/events_providers/event_note_provider.dart';
import 'package:pet_diary/src/providers/events_providers/event_psychic_provider.dart';
import 'package:pet_diary/src/providers/events_providers/event_service_provider.dart';
import 'package:pet_diary/src/providers/events_providers/event_stomach_provider.dart';
import 'package:pet_diary/src/providers/events_providers/event_stool_provider.dart';
import 'package:pet_diary/src/providers/events_providers/event_temperature_provider.dart';
import 'package:pet_diary/src/providers/events_providers/event_urine_provider.dart';
import 'package:pet_diary/src/providers/events_providers/event_walk_provider.dart';
import 'package:pet_diary/src/providers/events_providers/event_water_provider.dart';
import 'package:pet_diary/src/providers/events_providers/event_weight_provider.dart';

void eventDeleteFunc(
  WidgetRef ref,
  BuildContext context,
  List<Event>? allEvents,
  String eventId,
  String petId,
) async {
  Event? event = allEvents?.where((element) => element.id == eventId).first;

  final String noteId = event!.noteId;
  final String temperatureId = event.temperatureId;
  final String walkId = event.walkId;
  final String waterId = event.waterId;
  final String weightId = event.weightId;
  final String moodId = event.moodId;
  final String stomachId = event.stomachId;
  final String isssueId = event.issueId;
  final String stoolId = event.stoolId;
  final String urineId = event.urineId;
  final String serviceId = event.serviceId;
  final String careId = event.careId;

  ref.read(eventServiceProvider).deleteEvent(eventId);

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return const LoadingDialog();
    },
  );

  if (weightId.isNotEmpty) {
    await ref.read(eventWeightServiceProvider).deleteWeight(weightId);
  }

  if (waterId.isNotEmpty) {
    await ref.read(eventWaterServiceProvider).deleteWater(waterId);
  }

  if (temperatureId.isNotEmpty) {
    await ref
        .read(eventTemperatureServiceProvider)
        .deleteTemperature(temperatureId);
  }

  if (walkId.isNotEmpty) {
    await ref.read(eventWalkServiceProvider).deleteWalk(walkId);
  }

  if (noteId.isNotEmpty) {
    await ref.read(eventNoteServiceProvider).deleteNote(noteId);
  }

  if (moodId.isNotEmpty) {
    await ref.read(eventMoodServiceProvider).deleteMood(moodId);
  }

  if (stomachId.isNotEmpty) {
    await ref.read(eventStomachServiceProvider).deleteStomach(stomachId);
  }

  if (isssueId.isNotEmpty) {
    await ref.read(eventIssueServiceProvider).deleteIssue(isssueId);
  }

  if (stoolId.isNotEmpty) {
    await ref.read(eventStoolServiceProvider).deleteStoolEvent(stoolId);
  }

  if (urineId.isNotEmpty) {
    await ref.read(eventUrineServiceProvider).deleteUrineEvent(urineId);
  }

  if (serviceId.isNotEmpty) {
    await ref.read(eventServiceServiceProvider).deleteServiceEvent(serviceId);
  }

  if (careId.isNotEmpty) {
    await ref.read(eventCareServiceProvider).deleteCare(careId);
  }

  Navigator.of(context).pop();
}
