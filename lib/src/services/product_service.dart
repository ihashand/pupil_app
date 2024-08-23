import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pet_diary/src/models/product_model.dart';

class ProductService {
  final _firestore = FirebaseFirestore.instance;
  final _globalProductsController =
      StreamController<List<ProductModel>>.broadcast();
  final _userProductsController =
      StreamController<List<ProductModel>>.broadcast();

  // Global products stream
  Stream<List<ProductModel>> getProductsStream() {
    _firestore.collection('products').snapshots().listen((snapshot) {
      _globalProductsController.add(
          snapshot.docs.map((doc) => ProductModel.fromDocument(doc)).toList());
    });

    return _globalProductsController.stream;
  }

  // User-specific products stream
  Stream<List<ProductModel>> getUserProductsStream() {
    _firestore
        .collection('app_users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('user_products')
        .snapshots()
        .listen((snapshot) {
      _userProductsController.add(
          snapshot.docs.map((doc) => ProductModel.fromDocument(doc)).toList());
    });

    return _userProductsController.stream;
  }

  // Placeholder for favorite products stream
  Stream<List<ProductModel>> getFavoriteProductsStream() {
    // Implement this based on how you manage favorite products
    return const Stream.empty();
  }

  Future<ProductModel?> getProductByBarcode(String barcode) async {
    final querySnapshot = await _firestore
        .collection('products')
        .where('barcode', isEqualTo: barcode)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      return ProductModel.fromDocument(querySnapshot.docs.first);
    }
    return null;
  }

  Future<void> addProduct(ProductModel product, {bool isGlobal = true}) async {
    if (isGlobal) {
      await _firestore.collection('products').add(product.toMap());
    } else {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        await _firestore
            .collection('app_users')
            .doc(currentUser.uid)
            .collection('user_products')
            .add(product.toMap());
      }
    }
  }

  Future<void> updateProduct(ProductModel product) async {
    await _firestore
        .collection('products')
        .doc(product.id)
        .update(product.toMap());
  }

  Future<void> deleteProduct(String productId) async {
    await _firestore.collection('products').doc(productId).delete();
  }

  void dispose() {
    _globalProductsController.close();
    _userProductsController.close();
  }
}
