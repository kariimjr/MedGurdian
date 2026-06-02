import 'dart:math'; // 🟢 Needed for Randomizing tips selection
import 'package:flutter/material.dart';
import 'package:medgurdian/modules/MedicineScreen/MedicineReminderScreen.dart';
import 'package:medgurdian/modules/ReportSummrizer/MedicalSummaryModal.dart';

class HomeQuickActions extends StatelessWidget {
  final VoidCallback? onPdfSummaryPressed;

  const HomeQuickActions({super.key, this.onPdfSummaryPressed});

  static const List<String> _patientTips = [
    "Consistency is key! Taking your medication at the same time every day builds a stronger defense system. 🛡️",
    "Small steps every day lead to big health victories. Stay committed to your recovery journey! ✨",
    "Don't look back; you're not going that way. Focus on feeling better one day at a time. 💪",
    "Your health is an investment, not an expense. Keep up the amazing work tracking your daily schedule! 🌟",
    "Hydration check! Remember to take your prescriptions with a full glass of water unless advised otherwise. 💧",
    "Listen to your body. Resting when you are tired is just as important as taking your daily medicine. 🛌",
    "You are stronger than your diagnosis. Believe in your resilience today! ❤️",
    "A journey of a thousand miles begins with a single step—and you just completed your daily health tracker updates! 🚀",
  ];

  // 🟢 Helper function to select a random tip and render it smoothly inside a clean SnackBar layout
  void _showRandomHealthTip(BuildContext context) {
    final random = Random();
    final String selectedTip = _patientTips[random.nextInt(_patientTips.length)];

    // Clear any active snackbars on screen first to prevent UI stacking delay
    ScaffoldMessenger.of(context).clearSnackBars();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.auto_awesome, color: Colors.amber, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                selectedTip,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.blueAccent,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        action: SnackBarAction(
          label: "DISMISS",
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _actionCard(
          title: "Add Med",
          icon: Icons.add_moderator,
          color: Colors.green,
          onTap: () {
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                const MedicineReminderScreen(),
              ),
            );
          },
        ),
        const SizedBox(width: 12),

        _actionCard(
          title: "Tips",
          icon: Icons.lightbulb_outline,
          color: Colors.blueAccent,
          onTap: () => _showRandomHealthTip(context),
        ),
        const SizedBox(width: 12),

        _actionCard(
          title: "Reports",
          icon: Icons.picture_as_pdf_rounded,
          color: Colors.purple,
          onTap:
          onPdfSummaryPressed ??
                  () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MedicalSummaryModal(category: ''),
                  ),
                );
              },
        ),
      ],
    );
  }

  Widget _actionCard({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: Card(
        margin: EdgeInsets.zero,
        elevation: 0,
        color: color.withOpacity(0.08),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(15),
          highlightColor: color.withOpacity(0.05),
          splashColor: color.withOpacity(0.1),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(height: 8),
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}