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
    Map data = doc.data() as Map<String, dynamic>;
    DateTime lastUpd = (data['lastUpdated'] as Timestamp?)?.toDate() ?? DateTime.now();

    bool isDifferentDay = lastUpd.day != DateTime.now().day ||
        lastUpd.month != DateTime.now().month ||
        lastUpd.year != DateTime.now().year;

    return Medicine(
      type: data['type'] ?? 'pill',
      id: doc.id,
      name: data['name'] ?? '',
      time: data['time'] ?? '',
      targetDoses: data['targetDoses'] ?? 1,
      currentDoses: isDifferentDay ? 0 : (data['currentDoses'] ?? 0),
      lastUpdated: lastUpd,
    );
  }
}