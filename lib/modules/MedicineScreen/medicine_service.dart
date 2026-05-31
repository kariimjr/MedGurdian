import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'medicine_model.dart';

class MedicineService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 🎯 Dynamic helper method to safely point to the current logged-in patient's nested medicines subcollection
  CollectionReference _getPersonalMedsRef() {
    final User? user = _auth.currentUser;
    if (user == null) {
      throw Exception("Authentication Error: No logged-in patient detected.");
    }
    return _firestore.collection('patients').doc(user.uid).collection('medicines');
  }

  // 🟢 FIXED STREAM: Removed hidden silent failure logic to safely catch and parse database feeds
  Stream<List<Medicine>> getMedicines() {
    // We removed the restrictive .orderBy('time') temporarily.
    // This allows documents from both Web and Mobile to show up instantly without index crashes!
    return _getPersonalMedsRef().snapshots().map((snapshot) {
      final List<Medicine> medicines = snapshot.docs
          .map((doc) => Medicine.fromFirestore(doc))
          .toList();

      // 🎯 Sort in-memory instead! This avoids complex Firestore Index errors entirely
      medicines.sort((a, b) => a.time.compareTo(b.time));
      return medicines;
    });
  }

  // Adds medication explicitly to the active authenticated user's private collection layout
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

  // Updates current compliance tracking parameters isolated by ID
  Future<void> takeDose(String id, int current, int target) async {
    if (current < target) {
      await _getPersonalMedsRef().doc(id).update({
        'currentDoses': current + 1,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    }
  }

  // Deletes a document safely from the user's specific sub-node path reference
  Future<void> deleteMedicine(String id) {
    return _getPersonalMedsRef().doc(id).delete();
  }
}