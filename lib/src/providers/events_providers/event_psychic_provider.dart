import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/models/events_models/event_issue_model.dart';
import 'package:pet_diary/src/services/events_services/event_psychic_servie.dart';

final eventIssueServiceProvider = Provider((ref) {
  return EventIssueService();
});

final eventsIssueProvider = StreamProvider<List<EventIssueModel>>((ref) {
  return ref.watch(eventIssueServiceProvider).getIssuesStream();
});
