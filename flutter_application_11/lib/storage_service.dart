import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StorageService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static User get _currentUser {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User is not logged in.');
    }
    return user;
  }

  static CollectionReference<Map<String, dynamic>> get _peopleRef {
    return _firestore
        .collection('users')
        .doc(_currentUser.uid)
        .collection('people');
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> peopleStream() {
    return _peopleRef.orderBy('createdAt', descending: true).snapshots();
  }

  static Future<void> addPerson(Map<String, dynamic> person) async {
    await _peopleRef.add({
      'name': person['name'] ?? '',
      'birthDate': person['birthDate'] ?? '',
      'avatar': person['avatar'] ?? '🙂',
      'type': person['type'] ?? 'baby',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  static Future<void> updatePerson(
    String personId,
    Map<String, dynamic> data,
  ) async {
    await _peopleRef.doc(personId).update(data);
  }

  static Future<void> deletePerson(String personId) async {
    await _peopleRef.doc(personId).delete();
  }

  static Future<List<Map<String, dynamic>>> loadBabies() async {
    final snapshot = await _peopleRef.where('type', isEqualTo: 'baby').get();
    return snapshot.docs
        .map((doc) => {'id': doc.id, ...doc.data()})
        .toList();
  }

  static Future<List<Map<String, dynamic>>> loadOldPeople() async {
    final snapshot = await _peopleRef.where('type', isEqualTo: 'elderly').get();
    return snapshot.docs
        .map((doc) => {'id': doc.id, ...doc.data()})
        .toList();
  }
}
