import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  // Upload a photo to Firebase Storage
  Future<String?> uploadPhoto(File photo) async {
    try {
      if (_currentUser == null) {
        print("Użytkownik nie jest zalogowany.");
        return null;
      }

      // Tworzenie unikalnej ścieżki dla pliku w Firebase Storage
      String fileName = basename(photo.path);
      String storagePath = 'user_photos/${_currentUser.uid}/$fileName';

      try {
        UploadTask uploadTask = _storage.ref(storagePath).putFile(photo);

        uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
          print(
              'Upload is ${snapshot.bytesTransferred / snapshot.totalBytes * 100}% complete.');
        });

        TaskSnapshot snapshot = await uploadTask;
        print('Upload complete');

        String downloadUrl = await snapshot.ref.getDownloadURL();
        print('Download URL: $downloadUrl');

        await _savePhotoMetadata(downloadUrl, storagePath);

        return downloadUrl;
      } catch (e) {
        print('Upload failed: $e');
        return null;
      }
    } catch (e) {
      print('Błąd podczas przesyłania zdjęcia: $e');
      return null;
    }
  }

  // Zapis metadanych w Firestore dla automatycznego usuwania po 24 godzinach
  Future<void> _savePhotoMetadata(
      String downloadUrl, String storagePath) async {
    try {
      if (_currentUser == null) return;

      await _firestore.collection('user_photos').add({
        'userId': _currentUser!.uid,
        'downloadUrl': downloadUrl,
        'storagePath': storagePath,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print("Błąd podczas zapisu metadanych zdjęcia: $e");
    }
  }

  // Metoda do usuwania zdjęć starszych niż 24 godziny
  Future<void> deleteExpiredPhotos() async {
    try {
      if (_currentUser == null) return;

      // Pobieranie wszystkich zdjęć przesłanych przez bieżącego użytkownika
      QuerySnapshot querySnapshot = await _firestore
          .collection('user_photos')
          .where('userId', isEqualTo: _currentUser!.uid)
          .get();

      for (QueryDocumentSnapshot doc in querySnapshot.docs) {
        // Sprawdzenie, czy zdjęcie ma więcej niż 24 godziny
        Timestamp? timestamp = doc.get('timestamp') as Timestamp?;
        if (timestamp != null &&
            DateTime.now().difference(timestamp.toDate()).inHours >= 24) {
          String storagePath = doc.get('storagePath');
          await _deletePhoto(storagePath, doc.id);
        }
      }
    } catch (e) {
      print('Błąd podczas usuwania zdjęć: $e');
    }
  }

  // Usuwanie zdjęcia z Firebase Storage i Firestore
  Future<void> _deletePhoto(String storagePath, String docId) async {
    try {
      // Usuwanie zdjęcia z Firebase Storage
      await _storage.ref(storagePath).delete();

      // Usuwanie metadanych z Firestore
      await _firestore.collection('user_photos').doc(docId).delete();
    } catch (e) {
      print('Błąd podczas usuwania zdjęcia: $e');
    }
  }
}
