import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/tests/unit/services/other_services/settings_service.dart';
import 'package:pet_diary/src/models/others/settings_model.dart';

final settingsServiceProvider = Provider<SettingsService>((ref) {
  return SettingsService();
});

final autoRemoveEnabledProvider =
    StateNotifierProvider<AutoRemoveEnabledNotifier, bool>((ref) {
  return AutoRemoveEnabledNotifier(ref);
});

final autoRemoveHoursProvider =
    StateNotifierProvider<AutoRemoveHoursNotifier, int>((ref) {
  return AutoRemoveHoursNotifier(ref);
});

final autoRemoveMinutesProvider =
    StateNotifierProvider<AutoRemoveMinutesNotifier, int>((ref) {
  return AutoRemoveMinutesNotifier(ref);
});

class AutoRemoveEnabledNotifier extends StateNotifier<bool> {
  final StateNotifierProviderRef<AutoRemoveEnabledNotifier, bool> ref;
  AutoRemoveEnabledNotifier(this.ref) : super(false) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final settings =
        await ref.read(settingsServiceProvider).getAutoRemoveSettings();
    if (settings != null) {
      state = settings.autoRemoveEnabled;
    }
  }

  Future<void> toggle(bool value) async {
    state = value;
    await _saveSettings();
  }

  Future<void> _saveSettings() async {
    final hours = ref.read(autoRemoveHoursProvider);
    final minutes = ref.read(autoRemoveMinutesProvider);
    final settings = SettingsModel(
      autoRemoveEnabled: state,
      autoRemoveHours: hours,
      autoRemoveMinutes: minutes,
    );
    await ref.read(settingsServiceProvider).saveAutoRemoveSettings(settings);
  }
}

class AutoRemoveHoursNotifier extends StateNotifier<int> {
  final StateNotifierProviderRef<AutoRemoveHoursNotifier, int> ref;
  AutoRemoveHoursNotifier(this.ref) : super(0) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final settings =
        await ref.read(settingsServiceProvider).getAutoRemoveSettings();
    if (settings != null) {
      state = settings.autoRemoveHours;
    }
  }

  Future<void> setHours(int hours) async {
    state = hours;
    await _saveSettings();
  }

  Future<void> _saveSettings() async {
    final isEnabled = ref.read(autoRemoveEnabledProvider);
    final minutes = ref.read(autoRemoveMinutesProvider);
    final settings = SettingsModel(
      autoRemoveEnabled: isEnabled,
      autoRemoveHours: state,
      autoRemoveMinutes: minutes,
    );
    await ref.read(settingsServiceProvider).saveAutoRemoveSettings(settings);
  }
}

class AutoRemoveMinutesNotifier extends StateNotifier<int> {
  final StateNotifierProviderRef<AutoRemoveMinutesNotifier, int> ref;
  AutoRemoveMinutesNotifier(this.ref) : super(30) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final settings =
        await ref.read(settingsServiceProvider).getAutoRemoveSettings();
    if (settings != null) {
      state = settings.autoRemoveMinutes;
    }
  }

  Future<void> setMinutes(int minutes) async {
    state = minutes;
    await _saveSettings();
  }

  Future<void> _saveSettings() async {
    final isEnabled = ref.read(autoRemoveEnabledProvider);
    final hours = ref.read(autoRemoveHoursProvider);
    final settings = SettingsModel(
      autoRemoveEnabled: isEnabled,
      autoRemoveHours: hours,
      autoRemoveMinutes: state,
    );
    await ref.read(settingsServiceProvider).saveAutoRemoveSettings(settings);
  }
}
