import 'package:cloud_firestore/cloud_firestore.dart';

class SettingsModel {
  bool autoRemoveEnabled;
  int autoRemoveHours;
  int autoRemoveMinutes;

  SettingsModel({
    required this.autoRemoveEnabled,
    required this.autoRemoveHours,
    required this.autoRemoveMinutes,
  });

  SettingsModel.fromDocument(DocumentSnapshot doc)
      : autoRemoveEnabled = doc.get('enabled') ?? false,
        autoRemoveHours = doc.get('hours') ?? 0,
        autoRemoveMinutes = doc.get('minutes') ?? 0;

  Map<String, dynamic> toMap() {
    return {
      'enabled': autoRemoveEnabled,
      'hours': autoRemoveHours,
      'minutes': autoRemoveMinutes,
    };
  }
}
