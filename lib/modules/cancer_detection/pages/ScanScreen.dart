import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
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
  String _activeModel = 'Brain';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ScanBloc>().add(InitializeScanEvent());
    });
  }

  Color _getResultColor(String label) {
    switch (label) {
      case 'Normal':
      case 'No Tumor':
        return Colors.green;
      case 'Benign':
        return Colors.amber.shade700;
      case 'Malignant':
      case 'Glioma':
      case 'Pituitary':
      case 'Meningioma':
        return Colors.red;
      default:
        return Colors.blueGrey;
    }
  }

  IconData _getResultIcon(String label) {
    Color color = _getResultColor(label);
    if (color == Colors.green) return Icons.check_circle_outline;
    if (color == Colors.red) return Icons.warning_amber_rounded;
    return Icons.info_outline;
  }

  Future<void> _deleteScan(String docId) async {
    try {
      await FirebaseFirestore.instance
          .collection('scan_history')
          .doc(docId)
          .delete();
    } catch (e) {
      debugPrint("Error deleting scan: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(

        title: Text(
          "$_activeModel Analysis",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0277BD),
      ),
      body: BlocConsumer<ScanBloc, ScanState>(
        listener: (context, state) {
          if (state is ScanError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          return Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 10,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F7FA),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: CupertinoSlidingSegmentedControl<String>(
                        backgroundColor: Colors.transparent,
                        thumbColor: Colors.white,
                        groupValue: _activeModel,
                        children: const {
                          'Brain': Text('Brain'),
                          'Breast': Text('Breast'),
                          'Lung': Text('Lung'),
                        },
                        onValueChanged: (value) {
                          if (value != null) {
                            setState(() => _activeModel = value);
                            context.read<ScanBloc>().add(
                              SwitchModelEvent(value),
                            );
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 25),
                    _buildImagePanel(state),
                    const SizedBox(height: 24),
                    _buildResultsArea(state),
                    const SizedBox(height: 24),
                    _buildActionButtons(context),
                    const SizedBox(height: 40),
                    const Text(
                      "Recent History",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF01579B),
                      ),
                    ),
                    const Divider(height: 30),
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
                        Text(
                          "Analyzing Scan...",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
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

  Widget _buildImagePanel(ScanState state) {
    bool hasImage = state is ScanImagePicked || state is ScanSuccess;

    Color borderColor = (state is ScanSuccess)
        ? _getResultColor(state.resultLabel)
        : Colors.blue.shade50;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          height: 300,
          decoration: BoxDecoration(
            color: const Color(0xFFF8FBFF),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: borderColor, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(23),
            child: hasImage
                ? Image.file((state as dynamic).image, fit: BoxFit.cover)
                : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.add_a_photo_outlined,
                  size: 64,
                  color: Colors.blue.shade200,
                ),
                const SizedBox(height: 12),
                const Text(
                  "Upload Medical Scan",
                  style: TextStyle(
                    color: Colors.blueGrey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),

        // 🚨 LIVE STATUS ALERT RIBBON UNDER IMAGE PANEL
        if (state is ScanSuccess) ...[
          const SizedBox(height: 12),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('scan_history')
                .where('userId', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
                .where('category', isEqualTo: state.category)
                .orderBy('date', descending: true)
                .limit(1)
                .snapshots(),
            builder: (context, snapshot) {
              String requestStatus = 'none';
              if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                final docData = snapshot.data!.docs.first.data() as Map<String, dynamic>;
                requestStatus = docData['status'] ?? 'none';
              }

              if (requestStatus == 'none' || requestStatus == '') {
                return Container(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.blueGrey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blueGrey.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.report_problem_outlined, color: Colors.blueGrey.shade700, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "This is an unconfirmed AI finding. It has been automatically shared with medical professionals for full clinical review.",
                          style: TextStyle(
                            color: Colors.blueGrey.shade900,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ],
    );
  }

  Widget _buildResultsArea(ScanState state) {
    if (state is ScanSuccess) {
      Color resultColor = _getResultColor(state.resultLabel);
      final String? userId = FirebaseAuth.instance.currentUser?.uid;

      return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('scan_history')
            .where('userId', isEqualTo: userId)
            .where('category', isEqualTo: state.category)
            .orderBy('date', descending: true)
            .limit(1)
            .snapshots(),
        builder: (context, snapshot) {
          String requestStatus = 'none';
          String doctorNotes = '';
          String doctorName = '';

          if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
            final docData = snapshot.data!.docs.first.data() as Map<String, dynamic>;
            requestStatus = docData['status'] ?? 'none';

            if (docData['doctorConfirmation'] != null) {
              doctorNotes = docData['doctorConfirmation']['notes'] ?? '';
              doctorName = docData['doctorConfirmation']['doctorName'] ?? '';
            }
          }

          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: resultColor.withOpacity(0.05),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: resultColor.withOpacity(0.2), width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  state.resultLabel,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: resultColor,
                  ),
                ),
                Center(
                  child: Text(
                    "AI Confidence: ${(state.confidence * 100).toStringAsFixed(1)}%",
                    style: TextStyle(
                      color: resultColor.withOpacity(0.8),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(),
                ),

                // 🎯 🩺 AUTOMATED MEDICAL VERIFICATION DISCLOSURE SYSTEM
                if (requestStatus == 'none' || requestStatus == '' || requestStatus == 'pending_confirmation') ...[
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.amber.shade200),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.hourglass_empty_rounded, color: Colors.amber.shade800, size: 18),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text(
                            "Scan received successfully. It is currently under live review by our medical specialists.",
                            style: TextStyle(
                              color: Color(0xFF7F5F00), // Amber shade 900 equivalent for typography readability
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else if (requestStatus == 'confirmed_by_doctor') ...[
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.verified_user_rounded, color: Colors.green.shade700, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              "Confirmed by Medical Specialist",
                              style: TextStyle(
                                color: Colors.green.shade800,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                        if (doctorNotes.isNotEmpty) ...[
                          const Divider(height: 20),
                          Text(
                            "Dr. $doctorName Comments:",
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black87),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            doctorNotes,
                            style: TextStyle(color: Colors.grey.shade700, fontSize: 13, fontStyle: FontStyle.italic),
                          ),
                        ]
                      ],
                    ),
                  ),
                ] else if (requestStatus == 'Modified') ...[
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.report_gmailerrorred_rounded, color: Colors.red.shade700, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              "Diagnostic Finding Modified by Doctor",
                              style: TextStyle(
                                color: Colors.red.shade900,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                        if (doctorNotes.isNotEmpty) ...[
                          const Divider(height: 20),
                          Text(
                            "Dr. $doctorName Clinical Notes:",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.red.shade900),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            doctorNotes,
                            style: TextStyle(color: Colors.red.shade900.withOpacity(0.8), fontSize: 13, fontStyle: FontStyle.italic),
                          ),
                        ]
                      ],
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF1F8E9),
              foregroundColor: Colors.green.shade700,
              padding: const EdgeInsets.symmetric(vertical: 15),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            icon: const Icon(Icons.photo_library_rounded),
            label: const Text("Gallery"),
            onPressed: () => context.read<ScanBloc>().add(
              PickImageEvent(ImageSource.gallery),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0277BD),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 15),
              elevation: 5,
              shadowColor: Colors.blue.withOpacity(0.3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            icon: const Icon(Icons.camera_alt_rounded),
            label: const Text("Camera"),
            onPressed: () => context.read<ScanBloc>().add(
              PickImageEvent(ImageSource.camera),
            ),
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
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(20),
            child: Center(child: Text("No history for this category.")),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final doc = docs[index];
            final data = doc.data() as Map<String, dynamic>;
            final String label = data['label'] ?? 'Unknown';
            final String status = data['status'] ?? 'none';

            String historicalNotes = '';
            if (data['doctorConfirmation'] != null) {
              historicalNotes = data['doctorConfirmation']['notes'] ?? '';
            }

            final Color itemColor = _getResultColor(label);
            final IconData itemIcon = _getResultIcon(label);

            return Card(
              elevation: 0,
              margin: const EdgeInsets.only(bottom: 12),
              color: const Color(0xFFF5F7FA),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                leading: CircleAvatar(
                  backgroundColor: itemColor.withOpacity(0.1),
                  child: Icon(itemIcon, color: itemColor, size: 20),
                ),
                title: Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: itemColor,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text(
                      "Confidence: ${(data['confidence'] * 100).toStringAsFixed(1)}%",
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                    ),
                    const SizedBox(height: 6),

                    // 🎯 DYNAMIC MEDICAL CONFIRMATION BADGE SYSTEM IN HISTORY
                    if (status == 'none' || status == '' || status == 'pending_confirmation') ...[
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.hourglass_top_rounded, color: Colors.amber, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            "Awaiting Verification...",
                            style: TextStyle(
                              color: Colors.amber.shade800,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ] else if (status == 'confirmed_by_doctor') ...[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.verified_user_rounded, color: Colors.green, size: 14),
                              const SizedBox(width: 4),
                              const Text(
                                "Confirmed by Doctor",
                                style: TextStyle(
                                  color: Colors.green,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          if (historicalNotes.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              "Note: $historicalNotes",
                              style: TextStyle(color: Colors.grey.shade700, fontSize: 11, fontStyle: FontStyle.italic),
                            ),
                          ]
                        ],
                      ),
                    ] else if (status == 'Modified') ...[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.report_gmailerrorred_rounded, color: Colors.red.shade700, size: 14),
                              const SizedBox(width: 4),
                              Text(
                                "Modified by Specialist",
                                style: TextStyle(
                                  color: Colors.red.shade700,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          if (historicalNotes.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              "Note: $historicalNotes",
                              style: TextStyle(color: Colors.red.shade900.withOpacity(0.8), fontSize: 11, fontStyle: FontStyle.italic),
                            ),
                          ]
                        ],
                      ),
                    ],
                  ],
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.grey),
                  onPressed: () => _confirmDeletion(context, doc.id),
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
        content: const Text(
          "Are you sure you want to remove this scan from your history?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteScan(docId);
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}