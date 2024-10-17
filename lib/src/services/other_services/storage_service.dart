import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  Future<String?> uploadPhoto(File photo) async {
    try {
      if (_currentUser == null) {
        return null;
      }
      String fileName = basename(photo.path);
      String storagePath = 'user_photos/${_currentUser.uid}/$fileName';

      File? compressedPhoto = await _compressImage(photo);

      if (compressedPhoto == null) {
        return null;
      }

      try {
        UploadTask uploadTask =
            _storage.ref(storagePath).putFile(compressedPhoto);

        uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {});

        TaskSnapshot snapshot = await uploadTask;

        String downloadUrl = await snapshot.ref.getDownloadURL();

        await _savePhotoMetadata(downloadUrl, storagePath);

        return downloadUrl;
      } catch (e) {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  Future<File?> _compressImage(File photo) async {
    try {
      img.Image? image = img.decodeImage(await photo.readAsBytes());

      if (image == null) {
        return null;
      }

      img.Image resizedImage = img.copyResize(image, width: 1024);

      List<int> compressedBytes = img.encodeJpg(resizedImage, quality: 25);

      String tempDir = (await getTemporaryDirectory()).path;
      File compressedFile = File('$tempDir/${basename(photo.path)}')
        ..writeAsBytesSync(compressedBytes);

      return compressedFile;
    } catch (e) {
      return null;
    }
  }

  Future<void> _savePhotoMetadata(
      String downloadUrl, String storagePath) async {
    if (_currentUser == null) return;

    await _firestore.collection('user_photos').add({
      'userId': _currentUser.uid,
      'downloadUrl': downloadUrl,
      'storagePath': storagePath,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteExpiredPhotos() async {
    if (_currentUser == null) return;

    QuerySnapshot querySnapshot = await _firestore
        .collection('user_photos')
        .where('userId', isEqualTo: _currentUser.uid)
        .get();

    for (QueryDocumentSnapshot doc in querySnapshot.docs) {
      Timestamp? timestamp = doc.get('timestamp') as Timestamp?;
      if (timestamp != null &&
          DateTime.now().difference(timestamp.toDate()).inHours >= 24) {
        String storagePath = doc.get('storagePath');
        await _deletePhoto(storagePath, doc.id);
      }
    }
  }

  Future<void> _deletePhoto(String storagePath, String docId) async {
    await _storage.ref(storagePath).delete();
    await _firestore.collection('user_photos').doc(docId).delete();
  }
}
