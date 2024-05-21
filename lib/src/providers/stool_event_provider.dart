import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/models/stool_event_model.dart';
import 'package:pet_diary/src/services/stool_event_service.dart';

final stoolEventServiceProvider = Provider((ref) {
  return StoolEventService();
});

final stoolEventsProvider = StreamProvider<List<StoolEvent>>((ref) {
  return ref.watch(stoolEventServiceProvider).getStoolEventsStream();
});
