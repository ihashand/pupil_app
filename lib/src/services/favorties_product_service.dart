import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pet_diary/src/models/product_model.dart';

class FavoritesProductsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<String>> getFavoriteProductIds(String userId) {
    return _firestore
        .collection('app_users')
        .doc(userId)
        .collection('favorites')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => doc.data()['productId'] as String)
            .toList());
  }

  Future<ProductModel?> getProductById(String productId) async {
    final doc = await _firestore.collection('products').doc(productId).get();
    if (doc.exists) {
      return ProductModel.fromDocument(doc);
    } else {
      return null;
    }
  }

  Future<void> addFavorite(String userId, String productId) async {
    await _firestore
        .collection('app_users')
        .doc(userId)
        .collection('favorites')
        .doc(productId)
        .set({'productId': productId});
  }

  Future<void> removeFavorite(String userId, String productId) async {
    await _firestore
        .collection('app_users')
        .doc(userId)
        .collection('favorites')
        .doc(productId)
        .delete();
  }
}
