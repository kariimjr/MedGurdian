import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:medgurdian/modules/ReportSummrizer/service/summary_service.dart';

class MedicalSummaryModal extends StatefulWidget {
  final String category;

  const MedicalSummaryModal({
    super.key,
    required this.category,
  });

  @override
  State<MedicalSummaryModal> createState() => _MedicalSummaryModalState();
}

class _MedicalSummaryModalState extends State<MedicalSummaryModal> {
  String summaryText = "";
  bool isLoading = false;
  String fileName = "";

  Future<void> pickAndSummarizePDF() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result == null || result.files.single.path == null) return;

      setState(() {
        isLoading = true;
        fileName = result.files.single.name;
        summaryText = "Processing report...";
      });

      final file = File(result.files.single.path!);

      final document = PdfDocument(inputBytes: await file.readAsBytes());
      final extractedText = PdfTextExtractor(document).extractText();
      document.dispose();

      if (extractedText.trim().isEmpty) {
        setState(() {
          isLoading = false;
          summaryText = "No readable text found (maybe scanned PDF).";
        });
        return;
      }

      final service = SummaryService();
      final resultSummary =
      await service.generateReportSummary(extractedText);

      setState(() {
        isLoading = false;
        summaryText = resultSummary ?? "Failed to generate summary.";
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        summaryText = "Error: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasFile = fileName.isNotEmpty;

    return Scaffold(
      backgroundColor: Colors.white,

      // 🔵 TITLE
      appBar: AppBar(
        title: Text("AI ${widget.category} Summary"),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.blue,
        elevation: 0,
      ),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              // 🟡 TEXT BOX CENTER
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F7FA),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.blue.withOpacity(0.1)),
                  ),
                  child: isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : SingleChildScrollView(
                    child: Text(
                      summaryText.isEmpty
                          ? "Upload a medical report to generate summary..."
                          : summaryText,
                      style: const TextStyle(
                        fontSize: 15,
                        height: 1.6,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 25),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                    hasFile ? Colors.redAccent : Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  onPressed: isLoading ? null : pickAndSummarizePDF,
                  icon: Icon(hasFile ? Icons.refresh : Icons.upload_file,color: Colors.white,),
                  label: Text(
                    hasFile ? "Upload New Report" : "Upload Report",
                    style: const TextStyle(fontSize: 16,color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      // 🔵 BIG LEFT FLOAT BUTTON (Back)
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
    );
  }
}