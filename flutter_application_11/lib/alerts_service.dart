import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AlertsService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static CollectionReference<Map<String, dynamic>> get _alertsRef {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      throw Exception('User is not logged in.');
    }

    return _firestore
        .collection('users')
        .doc(uid)
        .collection('alerts');
  }

  static Stream<List<Map<String, dynamic>>> getAll() {
    return _alertsRef.orderBy('createdAt', descending: true).snapshots().map(
      (snapshot) {
        return snapshot.docs.map((doc) {
          final data = doc.data();
          return {
            'id': doc.id,
            'text': data['text'] ?? '',
            'createdAt': data['createdAt'],
          };
        }).toList();
      },
    );
  }

  static Future<void> addAlert(String text) async {
    await _alertsRef.add({
      'text': text,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  static Future<void> clearAll() async {
    final snapshot = await _alertsRef.get();
    for (final doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }
}
