import 'package:cloud_firestore/cloud_firestore.dart';
import 'medicine_model.dart';

class MedicineService {
  final CollectionReference _db = FirebaseFirestore.instance.collection('medicines');

  Stream<List<Medicine>> getMedicines() {
    return _db.orderBy('time').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Medicine.fromFirestore(doc)).toList());
  }

  Future<void> addMedicine(String name, String time, int target,String type) {
    return _db.add({
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
      await _db.doc(id).update({
        'currentDoses': current + 1,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<void> deleteMedicine(String id) {
    return _db.doc(id).delete();
  }
}