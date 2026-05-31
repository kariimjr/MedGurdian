import 'package:flutter/material.dart';
import 'package:medgurdian/modules/MedicineScreen/MedicineReminderScreen.dart';
import 'package:medgurdian/modules/ReportSummrizer/MedicalSummaryModal.dart';

class HomeQuickActions extends StatelessWidget {
  final VoidCallback?
  onPdfSummaryPressed; // 🎯 Added dynamic callback trigger hook

  const HomeQuickActions({super.key, this.onPdfSummaryPressed});

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
              PageRouteBuilder(pageBuilder: (context, animation, secondaryAnimation) => MedicineReminderScreen(),),
            );
          },
        ),
        const SizedBox(width: 12),
        _actionCard(
          title: "Tips",
          icon: Icons.lightbulb_outline,
          color: Colors.orange,
          onTap: () {
            debugPrint("Health Tips Tapped");
          },
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
                    builder: (context) => MedicalSummaryModal(category: ''),
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
