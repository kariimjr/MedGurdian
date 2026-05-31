import 'package:cloud_firestore/cloud_firestore.dart';

class Medicine {
  final String type;
  final String id;
  final String name;
  final String time;
  final int targetDoses;
  final int currentDoses;
  final DateTime lastUpdated;

  Medicine({
    required this.type,
    required this.id,
    required this.name,
    required this.time,
    required this.targetDoses,
    required this.currentDoses,
    required this.lastUpdated,
  });

  factory Medicine.fromFirestore(DocumentSnapshot doc) {
    // 1. Safe cast to avoid a null pointer exception if data is malformed
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>? ?? {};

    // 2. Safe parsing of the timestamp
    DateTime lastUpd = DateTime.now();
    if (data['lastUpdated'] is Timestamp) {
      lastUpd = (data['lastUpdated'] as Timestamp).toDate();
    } else if (data['createdAt'] is Timestamp) {
      // Fallback for fields created on the web panel (e.g., serverTimestamp())
      lastUpd = (data['createdAt'] as Timestamp).toDate();
    }

    final DateTime now = DateTime.now();
    bool isDifferentDay = lastUpd.day != now.day ||
        lastUpd.month != now.month ||
        lastUpd.year != now.year;

    // 3. Safe dynamic type casting for numbers (Web numbers vs Mobile integers)
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
      // Fallbacks handle case sensitivity issues seamlessly (e.g., 'type' vs 'medicineType')
      type: data['type']?.toString() ?? 'pill',
      name: data['name']?.toString() ?? data['medicineName']?.toString() ?? 'Unknown Medication',
      time: data['time']?.toString() ?? '12:00 PM', // Fallback prevents Firestore sorting omission
      targetDoses: target,
      // Reset tracker metrics to 0 safely across date mismatches
      currentDoses: isDifferentDay ? 0 : current,
      lastUpdated: lastUpd,
    );
  }
}