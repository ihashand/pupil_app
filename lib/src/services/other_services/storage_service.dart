import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  /// Upload a photo to Firebase Storage and save metadata in Firestore.
  Future<String?> uploadPhoto(File photo) async {
    if (_currentUser == null) {
      debugPrint('Error: No user logged in.');
      return null;
    }

    try {
      final String fileName = basename(photo.path);
      final String storagePath = 'user_photos/${_currentUser!.uid}/$fileName';

      final File? compressedPhoto = await _compressImage(photo);
      if (compressedPhoto == null) {
        debugPrint('Error: Failed to compress photo.');
        return null;
      }

      final UploadTask uploadTask =
          _storage.ref(storagePath).putFile(compressedPhoto);
      final TaskSnapshot snapshot = await uploadTask;

      final String downloadUrl = await snapshot.ref.getDownloadURL();

      await _savePhotoMetadata(downloadUrl, storagePath);

      // Clean up temporary file
      await compressedPhoto.delete();

      return downloadUrl;
    } catch (e) {
      debugPrint('Error uploading photo: $e');
      return null;
    }
  }

  /// Compress the image to reduce its size.
  Future<File?> _compressImage(File photo) async {
    try {
      final img.Image? image = img.decodeImage(await photo.readAsBytes());
      if (image == null) {
        debugPrint('Error: Failed to decode image.');
        return null;
      }

      final img.Image resizedImage = img.copyResize(image, width: 1024);
      final List<int> compressedBytes =
          img.encodeJpg(resizedImage, quality: 25);

      final String tempDir = (await getTemporaryDirectory()).path;
      final File compressedFile = File('$tempDir/${basename(photo.path)}')
        ..writeAsBytesSync(compressedBytes);

      return compressedFile;
    } catch (e) {
      debugPrint('Error compressing image: $e');
      return null;
    }
  }

  /// Save photo metadata to Firestore.
  Future<void> _savePhotoMetadata(
      String downloadUrl, String storagePath) async {
    if (_currentUser == null) {
      debugPrint('Error: No user logged in.');
      return;
    }

    try {
      await _firestore.collection('user_photos').add({
        'userId': _currentUser!.uid,
        'downloadUrl': downloadUrl,
        'storagePath': storagePath,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error saving photo metadata: $e');
    }
  }

  /// Delete expired photos (older than 24 hours).
  Future<void> deleteExpiredPhotos() async {
    if (_currentUser == null) {
      debugPrint('Error: No user logged in.');
      return;
    }

    try {
      final QuerySnapshot querySnapshot = await _firestore
          .collection('user_photos')
          .where('userId', isEqualTo: _currentUser!.uid)
          .get();

      for (final QueryDocumentSnapshot doc in querySnapshot.docs) {
        final Timestamp? timestamp = doc.get('timestamp') as Timestamp?;
        if (timestamp != null &&
            DateTime.now().difference(timestamp.toDate()).inHours >= 24) {
          final String storagePath = doc.get('storagePath');
          await _deletePhoto(storagePath, doc.id);
        }
      }
    } catch (e) {
      debugPrint('Error deleting expired photos: $e');
    }
  }

  /// Delete a photo from Firebase Storage and Firestore.
  Future<void> _deletePhoto(String storagePath, String docId) async {
    try {
      await _storage.ref(storagePath).delete();
      await _firestore.collection('user_photos').doc(docId).delete();
    } catch (e) {
      debugPrint('Error deleting photo: $e');
    }
  }
}
