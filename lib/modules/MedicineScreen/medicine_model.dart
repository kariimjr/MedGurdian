import 'package:cloud_firestore/cloud_firestore.dart';

class Medicine {
  final String type;
  final String id;
  final String name;
  final String time;
  final int targetDoses;
  final int currentDoses;
  final DateTime lastUpdated;
  final String? dosage;

  Medicine({
    required this.type,
    required this.id,
    required this.name,
    required this.time,
    required this.targetDoses,
    required this.currentDoses,
    required this.lastUpdated,
    this.dosage,
  });

  factory Medicine.fromFirestore(DocumentSnapshot doc) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>? ?? {};

    DateTime lastUpd = DateTime.now();
    if (data['lastUpdated'] is Timestamp) {
      lastUpd = (data['lastUpdated'] as Timestamp).toDate();
    } else if (data['createdAt'] is Timestamp) {
      lastUpd = (data['createdAt'] as Timestamp).toDate();
    }

    final DateTime now = DateTime.now();
    bool isDifferentDay = lastUpd.day != now.day ||
        lastUpd.month != now.month ||
        lastUpd.year != now.year;

    int target = 1;
    if (data['targetDoses'] is num) {
      target = (data['targetDoses'] as num).toInt();
    }

    int current = 0;
    if (data['currentDoses'] is num) {
      current = (data['currentDoses'] as num).toInt();
    }

    return Medicine(
      id: doc.id,
      type: data['type']?.toString() ?? 'pill',
      name: data['name']?.toString() ?? 'Unknown Medication',
      time: data['time']?.toString() ?? '12:00 PM',
      targetDoses: target,
      currentDoses: isDifferentDay ? 0 : current,
      lastUpdated: lastUpd,
      dosage: data['dosage']?.toString(), // 🟢 3. MAP THE FIREBASE FIELD HERE
    );
  }
}