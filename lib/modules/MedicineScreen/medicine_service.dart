import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'medicine_model.dart';

class MedicineService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference _getPersonalMedsRef() {
    final User? user = _auth.currentUser;
    if (user == null) {
      throw Exception("Authentication Error: No logged-in patient detected.");
    }
    return _firestore.collection('patients').doc(user.uid).collection('medicines');
  }

  Stream<List<Medicine>> getMedicines() {
    return _getPersonalMedsRef().snapshots().map((snapshot) {
      final List<Medicine> medicines = snapshot.docs
          .map((doc) => Medicine.fromFirestore(doc))
          .toList();

      medicines.sort((a, b) => a.time.compareTo(b.time));
      return medicines;
    });
  }

  Future<void> addMedicine(String name, String time, int target, String type) {
    return _getPersonalMedsRef().add({
      'name': name,
      'time': time,
      'type': type,
      'targetDoses': target,
      'currentDoses': 0,
      'lastUpdated': FieldValue.serverTimestamp(),
    });
  }

  Future<void> takeDose(String id, int current, int target) async {
    if (current < target) {
      await _getPersonalMedsRef().doc(id).update({
        'currentDoses': current + 1,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<void> deleteMedicine(String id) {
    return _getPersonalMedsRef().doc(id).delete();
  }
}