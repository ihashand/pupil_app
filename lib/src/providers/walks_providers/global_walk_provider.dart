import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/models/others/global_walk_model.dart';
import 'package:pet_diary/src/services/other_services/global_walk_service.dart';

final globalWalkServiceProvider = Provider<GlobalWalkService>((ref) {
  return GlobalWalkService();
});

final globalWalksStreamProvider = StreamProvider<List<GlobalWalkModel>>((ref) {
  final globalWalkService = ref.watch(globalWalkServiceProvider);
  return globalWalkService.getGlobalWalksStream();
});

final globalWalkByIdProvider =
    FutureProvider.family<GlobalWalkModel?, String>((ref, walkId) {
  final globalWalkService = ref.watch(globalWalkServiceProvider);
  return globalWalkService.getGlobalWalkById(walkId);
});
