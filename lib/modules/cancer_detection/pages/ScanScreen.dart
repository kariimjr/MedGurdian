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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ScanBloc>().add(InitializeScanEvent());
    });
  }

  // Helper to determine if a result is "Healthy"
  bool _isResultHealthy(String label) {
    return label == 'No Tumor' || label == 'Benign';
  }

  // Firestore Delete Function
  Future<void> _deleteScan(String docId) async {
    try {
      await FirebaseFirestore.instance.collection('scan_history').doc(docId).delete();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Scan record removed"),
            duration: Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      debugPrint("Error deleting scan: $e");
    }
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
                    CupertinoSlidingSegmentedControl<String>(
                      groupValue: _activeModel,
                      children: const {
                        'Brain': Text('Brain Cancer'),
                        'Breast': Text('Breast Cancer'),
                      },
                      onValueChanged: (value) {
                        if (value != null) {
                          setState(() => _activeModel = value);
                          context.read<ScanBloc>().add(SwitchModelEvent(value));
                        }
                      },
                    ),
                    const SizedBox(height: 20),
                    Container(
                      height: 300,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: state is ScanSuccess
                              ? (_isResultHealthy(state.resultLabel) ? Colors.green : Colors.red)
                              : Colors.blue.shade100,
                          width: 2,
                        ),
                      ),
                      child: _buildImageArea(state),
                    ),
                    const SizedBox(height: 24),
                    _buildResultsArea(state),
                    const SizedBox(height: 24),
                    _buildActionButtons(context),
                    const SizedBox(height: 32),
                    const Text("Recent History", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const Divider(),
                    _buildHistoryList(),
                  ],
                ),
              ),
              if (state is ScanLoading)
                Container(
                  color: Colors.black45,
                  child: const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(color: Colors.white),
                        SizedBox(height: 16),
                        Text("Syncing AI...", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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

  Widget _buildImageArea(ScanState state) {
    if (state is ScanImagePicked || state is ScanSuccess) {
      dynamic currentState = state;
      return ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Image.file(currentState.image, fit: BoxFit.cover),
      );
    }
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.biotech, size: 80, color: Colors.blue),
        Text("Upload Scan", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildResultsArea(ScanState state) {
    if (state is ScanSuccess) {
      bool isHealthy = _isResultHealthy(state.resultLabel);
      Color resultColor = isHealthy ? Colors.green : Colors.red;
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: resultColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: resultColor.withOpacity(0.5), width: 2),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(isHealthy ? Icons.check_circle : Icons.warning_rounded, color: resultColor),
                const SizedBox(width: 10),
                Text(state.resultLabel, style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: resultColor)),
              ],
            ),
            Text("AI Confidence: ${(state.confidence * 100).toStringAsFixed(1)}%"),
          ],
        ),
      );
    }
    return const SizedBox.shrink();
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
        if (snapshot.hasError) return Center(child: Text("Error: ${snapshot.error}"));
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());

        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) return const Center(child: Text("No scans found.", style: TextStyle(color: Colors.grey)));

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final doc = docs[index];
            final data = doc.data() as Map<String, dynamic>;
            final String label = data['label'] ?? 'Unknown';
            final bool isHealthy = _isResultHealthy(label);
            final Color itemColor = isHealthy ? Colors.green : Colors.red;

            return Dismissible(
              key: Key(doc.id),
              direction: DismissDirection.endToStart,
              onDismissed: (direction) => _deleteScan(doc.id),
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20),
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.delete_sweep, color: Colors.white),
              ),
              child: Card(
                elevation: 0,
                margin: const EdgeInsets.only(bottom: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: itemColor.withOpacity(0.2)),
                ),
                color: itemColor.withOpacity(0.05),
                child: ListTile(
                  leading: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.grey),
                    onPressed: () => _confirmDeletion(context, doc.id),
                  ),
                  title: Text(label, style: TextStyle(fontWeight: FontWeight.bold, color: itemColor)),
                  subtitle: Text("Confidence: ${(data['confidence'] * 100).toStringAsFixed(1)}%"),
                  trailing: CircleAvatar(
                    radius: 14,
                    backgroundColor: itemColor.withOpacity(0.2),
                    child: Icon(isHealthy ? Icons.check : Icons.priority_high, color: itemColor, size: 14),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _confirmDeletion(BuildContext context, String docId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Record?"),
        content: const Text("This scan will be permanently removed."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(onPressed: () { Navigator.pop(context); _deleteScan(docId); },
              child: const Text("Delete", style: TextStyle(color: Colors.red))),
        ],
      ),
    );
  }
}