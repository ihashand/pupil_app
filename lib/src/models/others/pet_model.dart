import 'package:cloud_firestore/cloud_firestore.dart';

class Pet {
  late String id;
  late String name;
  late String avatarImage;
  late String age;
  late String gender;
  late String userId;
  late String breed;
  late DateTime dateTime;
  late String backgroundImage;
  List<String>? achievementIds;
  List<String>? sharedWithIds;

  Pet({
    required this.id,
    required this.name,
    required this.avatarImage,
    required this.age,
    required this.gender,
    required this.userId,
    required this.breed,
    required this.dateTime,
    required this.backgroundImage,
    this.achievementIds,
    this.sharedWithIds,
  });

  Pet.fromDocument(DocumentSnapshot doc) {
    id = doc.id;
    name = doc.get('name') ?? '';
    avatarImage = doc.get('avatarImage') ?? '';
    age = doc.get('age') ?? '';
    gender = doc.get('gender') ?? '';
    userId = doc.get('userId') ?? '';
    breed = doc.get('breed') ?? '';
    dateTime = (doc.get('dateTime') as Timestamp?)?.toDate() ?? DateTime.now();
    backgroundImage = doc.get('backgroundImage') ?? '';
    achievementIds = doc.data().toString().contains('achievementIds')
        ? List<String>.from(doc.get('achievementIds'))
        : [];
    sharedWithIds = doc.data().toString().contains('sharedWithIds')
        ? List<String>.from(doc.get('sharedWithIds'))
        : [];
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'avatarImage': avatarImage,
      'age': age,
      'gender': gender,
      'userId': userId,
      'breed': breed,
      'dateTime': dateTime,
      'backgroundImage': backgroundImage,
      'achievementIds': achievementIds ?? [],
      'sharedWithIds': sharedWithIds ?? [],
    };
  }

  // Update bazy danych Update all pet documents in Firestore
  static Future<void> updateAllPets() async {
    final petCollection = FirebaseFirestore.instance.collection('pets');

    // Fetch all documents in the collection
    final querySnapshot = await petCollection.get();

    // Loop through each document and update it
    for (var doc in querySnapshot.docs) {
      // Convert each document into a Pet instance
      Pet pet = Pet.fromDocument(doc);

      // Update the document in Firestore with the pet's data
      await petCollection.doc(pet.id).update(pet.toMap());
    }
  }

  static Future<void> migratePetsToTopLevel() async {
    final usersCollection = FirebaseFirestore.instance.collection('app_users');
    final petsCollection = FirebaseFirestore.instance.collection('pets');

    // Get all users
    final usersSnapshot = await usersCollection.get();

    for (var userDoc in usersSnapshot.docs) {
      // Get userId
      final userId = userDoc.id;

      // Get pets sub-collection for each user
      final userPetsSnapshot =
          await usersCollection.doc(userId).collection('pets').get();

      // Loop through each pet document and copy it to the top-level pets collection
      for (var petDoc in userPetsSnapshot.docs) {
        // Create a Pet instance from the document data
        Pet pet = Pet.fromDocument(petDoc);

        // Ensure the pet has the userId field for ownership tracking
        pet.userId = userId;

        // Set the pet document in the top-level pets collection
        await petsCollection.doc(pet.id).set(pet.toMap());
      }
    }
  }
}
