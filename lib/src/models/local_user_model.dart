import 'package:cloud_firestore/cloud_firestore.dart';

class LocalUser {
  late String image;
  late String uid;
  late String id;
  late DateTime dateTime;

  LocalUser(this.image, this.uid, this.id) : dateTime = DateTime.now();

  LocalUser.fromDocument(DocumentSnapshot doc) {
    image = doc.get('image') ?? '';
    uid = doc.get('uid') ?? '';
    id = doc.get('id') ?? '';
    dateTime = (doc.get('dateTime') as Timestamp?)?.toDate() ?? DateTime.now();
  }

  Map<String, dynamic> toMap() {
    return {
      'image': image,
      'uid': uid,
      'id': id,
      'dateTime': Timestamp.fromDate(dateTime),
    };
  }
}
