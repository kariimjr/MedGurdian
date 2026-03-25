import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

// Ensure these paths match your actual project structure
import '../bloc/scan_bloc.dart';
import '../bloc/scan_event.dart';
import '../bloc/scan_state.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  String _activeModel = 'Brain';

  @override
  void initState() {
    super.initState();
    // 🔥 NEW: Trigger the initial model download from Firebase when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ScanBloc>().add(InitializeScanEvent());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(

        title: Text("$_activeModel Analysis", style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0277BD),
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
                    // Model Selection Toggle
                    CupertinoSlidingSegmentedControl<String>(
                      groupValue: _activeModel,
                      children: const {
                        'Brain': Text('Brain Cancer'),
                        'Breast': Text('Breast Cancer'),
                      },
                      onValueChanged: (value) {
                        if (value != null) {
                          setState(() => _activeModel = value);
                          // Notify BLoC to switch the cloud model
                          context.read<ScanBloc>().add(SwitchModelEvent(value));
                        }
                      },
                    ),
                    const SizedBox(height: 20),

                    // Image Display Area
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

                    // Results and Recommendation Area
                    _buildResultsArea(state),
                    const SizedBox(height: 24),

                    // Action Buttons (Camera/Gallery)
                    _buildActionButtons(context),
                    const SizedBox(height: 32),

                    // Filtered History List
                    _buildHistoryList(),
                  ],
                ),
              ),

              // 🔥 UPDATED: Full-screen loader for Cloud Syncing
              if (state is ScanLoading)
                Container(
                  color: Colors.black45,
                  child: const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(color: Colors.white),
                        SizedBox(height: 16),
                        Text(
                          "Syncing AI with Cloud...",
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  // --- HELPER WIDGETS ---

  Widget _buildImageArea(ScanState state) {
    if (state is ScanImagePicked) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Image.file(state.image, fit: BoxFit.cover),
      );
    } else if (state is ScanSuccess) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Image.file(state.image, fit: BoxFit.cover),
      );
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.biotech, size: 80, color: Colors.blue),
        const SizedBox(height: 16),
        Text("Upload $_activeModel Scan", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const Text("Analyze scans instantly", style: TextStyle(color: Colors.grey)),
      ],
    );
  }

  Widget _buildResultsArea(ScanState state) {
    if (state is ScanSuccess) {
      bool isPositive = state.resultLabel.contains("Tumor") || state.resultLabel.contains("Malignant");
      Color resultColor = isPositive ? Colors.red : Colors.green;

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
          if (isPositive)
            _buildRecommendationCard(
              "Recommendation",
              _activeModel == 'Brain'
                  ? "Consult a neurologist for a professional review."
                  : "Consult an oncologist for further tests.",
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

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            icon: const Icon(Icons.photo_library),
            label: const Text("Gallery"),
            onPressed: () => context.read<ScanBloc>().add(PickImageEvent(ImageSource.gallery)),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
            icon: const Icon(Icons.camera_alt),
            label: const Text("Camera"),
            onPressed: () => context.read<ScanBloc>().add(PickImageEvent(ImageSource.camera)),
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryList() {
    final String? userId = FirebaseAuth.instance.currentUser?.uid;

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('scan_history')
          .where('userId', isEqualTo: userId)
          .where('category', isEqualTo: _activeModel)
          .orderBy('date', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          if (snapshot.error.toString().contains("FAILED_PRECONDITION")) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  "Database is preparing your history index. Please wait a few minutes...",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.orange),
                ),
              ),
            );
          }
          return Center(child: Text("Error: ${snapshot.error}"));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data?.docs ?? [];

        if (docs.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text("No $_activeModel scans found.", style: const TextStyle(color: Colors.grey)),
            ),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            return ListTile(
              leading: const Icon(Icons.history, color: Colors.blue),
              title: Text(data['label'] ?? 'Unknown Result'),
              subtitle: Text("Confidence: ${(data['confidence'] * 100).toStringAsFixed(1)}%"),
            );
          },
        );
      },
    );
  }
}