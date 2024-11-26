class HomePreferencesModel {
  final List<String> sectionOrder;
  final List<String> visibleSections;

  HomePreferencesModel({
    required this.sectionOrder,
    required this.visibleSections,
  });

  Map<String, dynamic> toMap() {
    return {
      'sectionOrder': sectionOrder,
      'visibleSections': visibleSections,
    };
  }

  factory HomePreferencesModel.fromMap(Map<String, dynamic> map) {
    return HomePreferencesModel(
      sectionOrder: List<String>.from(map['sectionOrder'] ?? []),
      visibleSections: List<String>.from(map['visibleSections'] ?? []),
    );
  }
}
