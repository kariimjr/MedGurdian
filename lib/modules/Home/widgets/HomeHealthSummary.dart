import 'package:flutter/material.dart';

class HomeHealthSummary extends StatelessWidget {
  const HomeHealthSummary({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.blue.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _statItem("Hydration", "80%", Icons.water_drop, Colors.blue),
          _vDivider(),
          _statItem("Sleep", "7h 20m", Icons.bedtime, Colors.indigo),
          _vDivider(),
          _statItem("Activity", "4.2k", Icons.directions_walk, Colors.orange),
        ],
      ),
    );
  }

  Widget _statItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }

  Widget _vDivider() => Container(height: 40, width: 1, color: Colors.grey.shade200);
}