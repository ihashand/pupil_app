import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/models/others/home_preferences_model.dart';
import 'package:pet_diary/src/services/home_services/home_preferences_service.dart';

final homePreferencesProvider =
    StateNotifierProvider<HomePreferencesService, HomePreferencesModel>(
        (ref) => HomePreferencesService());
