import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/models/pet_setting_model.dart';
import 'package:pet_diary/src/services/pet_setting_service.dart';

final petSettingsServiceProvider = Provider<PetSettingsService>((ref) {
  return PetSettingsService();
});

final petSettingsStreamProvider =
    StreamProvider.family<PetSettingsModel?, String>((ref, petId) {
  return ref.watch(petSettingsServiceProvider).getPetSettingsStream(petId);
});

class PetSettingsNotifier extends StateNotifier<PetSettingsModel?> {
  final PetSettingsService _service;
  final String petId;

  PetSettingsNotifier(this._service, this.petId) : super(null) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final settings = await _service.getPetSettings(petId);
    state = settings;
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

final petSettingsProvider = StateNotifierProvider.family<PetSettingsNotifier,
    PetSettingsModel?, String>(
  (ref, petId) {
    final service = ref.watch(petSettingsServiceProvider);
    return PetSettingsNotifier(service, petId);
  },
);
