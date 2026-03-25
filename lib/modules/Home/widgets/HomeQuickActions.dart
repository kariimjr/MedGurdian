import 'package:flutter/material.dart';

class HomeQuickActions extends StatelessWidget {
  const HomeQuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _actionCard("Add Med", Icons.add_moderator, Colors.green),
        const SizedBox(width: 15),
        _actionCard("Tips", Icons.lightbulb_outline, Colors.orange),
        const SizedBox(width: 15),
        _actionCard("Reports", Icons.bar_chart, Colors.purple),
      ],
    );
  }

  Widget _actionCard(String title, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(15)),
        child: Column(
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 8),
            Text(title, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}