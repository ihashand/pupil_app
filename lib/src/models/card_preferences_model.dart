class CardPreferencesModel {
  List<String> cardOrder;

  CardPreferencesModel({required this.cardOrder});

  Map<String, dynamic> toMap() {
    return {'cardOrder': cardOrder};
  }

  factory CardPreferencesModel.fromMap(Map<String, dynamic> map) {
    return CardPreferencesModel(cardOrder: List<String>.from(map['cardOrder']));
  }
}
