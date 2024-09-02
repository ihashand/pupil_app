class PreferencesModel {
  List<String> sectionOrder;
  List<String> visibleSections;

  PreferencesModel({
    required this.sectionOrder,
    required this.visibleSections,
  });

  Map<String, dynamic> toMap() {
    return {
      'sectionOrder': sectionOrder,
      'visibleSections': visibleSections,
    };
  }

  factory PreferencesModel.fromMap(Map<String, dynamic> map) {
    return PreferencesModel(
      sectionOrder: List<String>.from(map['sectionOrder']),
      visibleSections: List<String>.from(map['visibleSections']),
    );
  }
}
