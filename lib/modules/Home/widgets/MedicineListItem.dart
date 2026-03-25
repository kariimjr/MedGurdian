import 'package:flutter/material.dart';
import 'package:medgurdian/modules/MedicineScreen/medicine_model.dart';

class MedicineListItem extends StatelessWidget {
  final Medicine med;
  final VoidCallback onTake;

  const MedicineListItem({super.key, required this.med, required this.onTake});

  @override
  Widget build(BuildContext context) {
    bool isDone = med.currentDoses >= med.targetDoses;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: CircleAvatar(
          backgroundColor: isDone ? Colors.green.shade50 : Colors.blue.shade50,
          child: Icon(isDone ? Icons.check : Icons.access_time, color: isDone ? Colors.green : Colors.blue),
        ),
        title: Text(med.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(isDone ? "Completed Today" : "Next dose at ${med.time}"),
        trailing: !isDone ? IconButton(
          icon: const Icon(Icons.add_circle_outline, color: Colors.blue),
          onPressed: onTake,
        ) : null,
      ),
    );
  }
}