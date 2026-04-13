import 'dart:io';

abstract class ScanState {}

class ScanInitial extends ScanState {}

class ScanLoading extends ScanState {}

class ScanImagePicked extends ScanState {
  final File image;
  ScanImagePicked(this.image);
}

class ScanSuccess extends ScanState {
  final File image;
  final String resultLabel;
  final double confidence;
  final String category; // 🔥 Now tracks 'Brain', 'Breast', or 'Lung'

  ScanSuccess({
    required this.image,
    required this.resultLabel,
    required this.confidence,
    required this.category,
  });
}

class ScanError extends ScanState {
  final String message;
  ScanError(this.message);
}