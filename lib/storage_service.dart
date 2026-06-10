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

  static String _normalizePersonType(Object? type) {
    return type?.toString().trim().toLowerCase() == 'elderly'
        ? 'elderly'
        : 'baby';
  }

  static String _normalizeNameForId(Object? name) {
    final normalized = (name?.toString() ?? '')
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'\s+'), '_')
        .replaceAll(RegExp(r'[^a-z0-9_]'), '')
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^_+|_+$'), '');

    return normalized.isEmpty ? 'profile' : normalized;
  }

  static String _personIdBase(Map<String, dynamic> person) {
    final type = _normalizePersonType(person['type']);
    final name = _normalizeNameForId(person['name']);
    return '${type}_$name';
  }

  static Future<String> _availablePersonId(
    Transaction transaction,
    String baseId, {
    String? currentPersonId,
  }) async {
    var index = 1;

    while (true) {
      final candidateId = index == 1 ? baseId : '${baseId}_$index';

      if (candidateId == currentPersonId) {
        return candidateId;
      }

      final candidateSnapshot = await transaction.get(
        _peopleRef.doc(candidateId),
      );

      if (!candidateSnapshot.exists) {
        return candidateId;
      }

      index++;
    }
  }

  static Future<String> addPerson(Map<String, dynamic> person) async {
    final data = {
      'name': person['name'] ?? '',
      'birthDate': person['birthDate'] ?? '',
      'avatar': person['avatar'] ?? '🙂',
      'type': _normalizePersonType(person['type']),
      'createdAt': FieldValue.serverTimestamp(),
    };

    return _firestore.runTransaction((transaction) async {
      final personId = await _availablePersonId(
        transaction,
        _personIdBase(data),
      );

      transaction.set(_peopleRef.doc(personId), data);
      return personId;
    });
  }

  static Future<String> updatePerson(
    String personId,
    Map<String, dynamic> data,
  ) async {
    final updateData = {
      ...data,
      if (data.containsKey('type')) 'type': _normalizePersonType(data['type']),
    };

    return _firestore.runTransaction((transaction) async {
      final currentRef = _peopleRef.doc(personId);
      final currentSnapshot = await transaction.get(currentRef);

      if (!currentSnapshot.exists) {
        throw Exception('Person profile does not exist.');
      }

      final currentData = currentSnapshot.data() ?? {};
      final updatedData = {...currentData, ...updateData};

      final updatedPersonId = await _availablePersonId(
        transaction,
        _personIdBase(updatedData),
        currentPersonId: personId,
      );

      if (updatedPersonId == personId) {
        transaction.update(currentRef, updateData);
      } else {
        transaction.set(_peopleRef.doc(updatedPersonId), updatedData);
        transaction.delete(currentRef);
      }

      return updatedPersonId;
    });
  }

  static Future<void> deletePerson(String personId) async {
    await _peopleRef.doc(personId).delete();
  }

  static Future<List<Map<String, dynamic>>> loadBabies() async {
    final snapshot = await _peopleRef.where('type', isEqualTo: 'baby').get();
    return snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
  }

  static Future<List<Map<String, dynamic>>> loadOldPeople() async {
    final snapshot = await _peopleRef.where('type', isEqualTo: 'elderly').get();
    return snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
  }
}
