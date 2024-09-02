import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/models/events_models/event_food_pet_setting_model.dart';
import 'package:pet_diary/src/tests/unit/services/events_services/event_food_pet_setting_service.dart';

final eventFoodPetSettingsServiceProvider =
    Provider<EventFoodPetSettingsService>((ref) {
  return EventFoodPetSettingsService();
});

final eventFoodPetSettingsStreamProvider =
    StreamProvider.family<EventFoodPetSettingsModel?, String>((ref, petId) {
  return ref
      .watch(eventFoodPetSettingsServiceProvider)
      .getPetSettingsStream(petId);
});

class EventFoodPetSettingsNotifier
    extends StateNotifier<EventFoodPetSettingsModel?> {
  final EventFoodPetSettingsService _service;
  final String petId;

  EventFoodPetSettingsNotifier(this._service, this.petId) : super(null) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final settings = await _service.getPetSettings(petId);
    if (settings == null) {
      // If no settings found, set default settings
      await setDefaultSettings();
    } else {
      state = settings;
    }
  }

  Future<void> setDefaultSettings() async {
    final defaultSettings = EventFoodPetSettingsModel(
      id: 'default',
      petId: petId,
      dailyKcal: 0,
      proteinPercentage: 0,
      fatPercentage: 0,
      carbsPercentage: 0,
      mealTypes: ['Breakfast', 'Lunch', 'Dinner'],
    );
    state = defaultSettings;
    await _service.savePetSettings(defaultSettings);
  }

  Future<void> updateKcal(double kcal) async {
    if (state != null) {
      final updatedSettings = state!.copyWith(dailyKcal: kcal);
      state = updatedSettings;
      await _service.savePetSettings(updatedSettings);
    }
  }

  Future<void> updateProteinPercentage(double percentage) async {
    if (state != null) {
      final updatedSettings = state!.copyWith(proteinPercentage: percentage);
      state = updatedSettings;
      await _service.savePetSettings(updatedSettings);
    }
  }

  Future<void> updateFatPercentage(double percentage) async {
    if (state != null) {
      final updatedSettings = state!.copyWith(fatPercentage: percentage);
      state = updatedSettings;
      await _service.savePetSettings(updatedSettings);
    }
  }

  Future<void> updateCarbsPercentage(double percentage) async {
    if (state != null) {
      final updatedSettings = state!.copyWith(carbsPercentage: percentage);
      state = updatedSettings;
      await _service.savePetSettings(updatedSettings);
    }
  }

  Future<void> updateMealTypes(List<String> mealTypes) async {
    if (state != null) {
      final updatedSettings = state!.copyWith(mealTypes: mealTypes);
      state = updatedSettings;
      await _service.savePetSettings(updatedSettings);
    }
  }
}

final eventFoodPetSettingsProvider = StateNotifierProvider.family<
    EventFoodPetSettingsNotifier, EventFoodPetSettingsModel?, String>(
  (ref, petId) {
    final service = ref.watch(eventFoodPetSettingsServiceProvider);
    return EventFoodPetSettingsNotifier(service, petId);
  },
);
