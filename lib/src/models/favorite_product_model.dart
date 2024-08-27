class FavoriteProductModel {
  final String productId;

  FavoriteProductModel({required this.productId});

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
    };
  }

  factory FavoriteProductModel.fromMap(Map<String, dynamic> map) {
    return FavoriteProductModel(
      productId: map['productId'],
    );
  }
}
