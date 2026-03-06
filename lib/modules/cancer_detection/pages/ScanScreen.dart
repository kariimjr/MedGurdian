import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../bloc/scan_bloc.dart';
import '../bloc/scan_event.dart';
import '../bloc/scan_state.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Brain MRI Analysis", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: BlocConsumer<ScanBloc, ScanState>(
        listener: (context, state) {
          if (state is ScanError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        builder: (context, state) {
          return Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 1. Image Display Area
                    Container(
                      height: 300,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.blue.shade100, width: 2),
                      ),
                      child: _buildImageArea(state),
                    ),
                    const SizedBox(height: 24),

                    // 2. Results & Recommendation Area
                    _buildResultsArea(state),
                    const SizedBox(height: 24),

                    // 3. Action Buttons
                    _buildActionButtons(context),
                    const SizedBox(height: 32),


                    _buildHistoryList(),
                  ],
                ),
              ),

              // Loading Overlay
              if (state is ScanLoading)
                Container(
                  color: Colors.black12,
                  child: const Center(child: CircularProgressIndicator()),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            icon: const Icon(Icons.photo_library),
            label: const Text("Gallery"),
            onPressed: () => context.read<ScanBloc>().add(PickImageEvent(ImageSource.gallery)),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            icon: const Icon(Icons.camera_alt),
            label: const Text("Camera"),
            onPressed: () => context.read<ScanBloc>().add(PickImageEvent(ImageSource.camera)),
          ),
        ),
      ],
    );
  }

  Widget _buildImageArea(ScanState state) {
    if (state is ScanImagePicked || state is ScanSuccess) {
      final image = (state is ScanImagePicked) ? state.image : (state as ScanSuccess).image;
      return ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Image.file(image, fit: BoxFit.cover),
      );
    }
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.biotech, size: 80, color: Colors.blue),
        const SizedBox(height: 16),
        Text("Upload MRI Scan", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Text("Analyze brain scans instantly", style: TextStyle(color: Colors.grey)),
      ],
    );
  }

  Widget _buildResultsArea(ScanState state) {
    if (state is ScanSuccess) {
      bool isTumor = state.resultLabel.contains("Tumor");
      Color resultColor = isTumor ? Colors.red : Colors.green;

      return Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: resultColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: resultColor.withOpacity(0.3)),
            ),
            child: Column(
              children: [
                Text(state.resultLabel, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: resultColor)),
                const SizedBox(height: 8),
                Text("AI Confidence: ${(state.confidence * 100).toStringAsFixed(1)}%",
                    style: const TextStyle(fontSize: 16, color: Colors.black87)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (isTumor)
            _buildRecommendationCard(
              "Recommendation",
              "Detection suggests abnormalities. Please consult a neurologist for review.",
              Icons.medical_services,
              Colors.orange,
            ),
        ],
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildRecommendationCard(String title, String desc, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 12),
          Expanded(child: Text(desc, style: const TextStyle(fontSize: 13, color: Colors.black54))),
        ],
      ),
    );
  }

  // --- LOG HISTORY FEATURE WITH DELETE ---

  Widget _buildHistoryList() {
    final String? userId = FirebaseAuth.instance.currentUser?.uid;

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('scan_history')
          .where('userId', isEqualTo: userId)
          .orderBy('date', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text("Error loading history: ${snapshot.error}", style: const TextStyle(fontSize: 12)));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data?.docs ?? [];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 🔥 Dynamic Header with Conditional "Clear All" Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Recent History",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                // Only show the button if the list is NOT empty
                if (docs.isNotEmpty)
                  TextButton.icon(
                    onPressed: () => _showDeleteConfirmation(context),
                    icon: const Icon(Icons.delete_sweep, color: Colors.red, size: 20),
                    label: const Text("Clear All", style: TextStyle(color: Colors.red)),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            if (docs.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Text("No scans found.", style: TextStyle(color: Colors.grey)),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final doc = docs[index];
                  final data = doc.data() as Map<String, dynamic>;
                  final bool isTumor = data['label'].toString().contains("Tumor");
                  final Timestamp? timestamp = data['date'] as Timestamp?;
                  final DateTime date = timestamp?.toDate() ?? DateTime.now();

                  return Dismissible(
                    key: Key(doc.id),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(15)),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    onDismissed: (direction) {
                      FirebaseFirestore.instance.collection('scan_history').doc(doc.id).delete();
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.grey.shade100),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: isTumor ? Colors.red.withOpacity(0.1) : Colors.green.withOpacity(0.1),
                            child: Icon(isTumor ? Icons.warning_amber_rounded : Icons.check_circle_outline,
                                color: isTumor ? Colors.red : Colors.green),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(data['label'] ?? 'Unknown', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                Text("${date.day}/${date.month}/${date.year} • ${date.hour}:${date.minute.toString().padLeft(2, '0')}",
                                    style: const TextStyle(color: Colors.grey, fontSize: 12)),
                              ],
                            ),
                          ),
                          Text("${((data['confidence'] ?? 0) * 100).toStringAsFixed(1)}%",
                              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                        ],
                      ),
                    ),
                  );
                },
              ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text("Clear History"),
        content: const Text("Are you sure you want to delete all scan logs? This cannot be undone."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              context.read<ScanBloc>().add(ClearHistoryEvent());
              Navigator.pop(dialogContext);
            },
            child: const Text("Delete All", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }}