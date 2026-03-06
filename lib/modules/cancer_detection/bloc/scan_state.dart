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

  ScanSuccess(this.image, this.resultLabel, this.confidence);
}

class ScanError extends ScanState {
  final String message;
  ScanError(this.message);
}