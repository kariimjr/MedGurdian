import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../services/tflite_service.dart';
import 'scan_event.dart';
import 'scan_state.dart';

class ScanBloc extends Bloc<ScanEvent, ScanState> {
  final ImagePicker _picker = ImagePicker();
  final TFLiteService _tfliteService = TFLiteService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  ScanBloc() : super(ScanInitial()) {
    _tfliteService.loadModel();

    // 1. Handle Batch Delete
    on<ClearHistoryEvent>((event, emit) async {
      try {
        final String? userId = _auth.currentUser?.uid;
        if (userId != null) {
          // Note: In production, batch deletes are better for performance
          var snapshots = await _firestore
              .collection('scan_history')
              .where('userId', isEqualTo: userId)
              .get();

          final batch = _firestore.batch();
          for (var doc in snapshots.docs) {
            batch.delete(doc.reference);
          }
          await batch.commit();
        }
      } catch (e) {
        emit(ScanError("Failed to clear history: $e"));
      }
    });

    // 2. Handle Image Picking and Prediction
    on<PickImageEvent>((event, emit) async {
      try {
        final XFile? pickedFile = await _picker.pickImage(source: event.source);

        if (pickedFile != null) {
          File imageFile = File(pickedFile.path);
          emit(ScanImagePicked(imageFile));
          emit(ScanLoading());

          var result = await _tfliteService.runPrediction(pickedFile.path);

          if (result != null) {
            String label = result['label'];
            double confidence = result['confidence'];

            await _saveScanToHistory(label, confidence);

            emit(ScanSuccess(imageFile, label, confidence));
          } else {
            emit(ScanError("Could not analyze the image."));
          }
        } else {
          // Simply return to initial state if user cancels
          emit(ScanInitial());
        }
      } catch (e) {
        emit(ScanError("Failed to process image: $e"));
      }
    });
  }

  // 3. Data Storage Logic
  Future<void> _saveScanToHistory(String label, double confidence) async {
    final String? userId = _auth.currentUser?.uid;

    if (userId != null) {
      await _firestore.collection('scan_history').add({
        'userId': userId,
        'label': label,
        'confidence': confidence,
        'date': FieldValue.serverTimestamp(),
      });
    }
  }

  @override
  Future<void> close() {
    _tfliteService.dispose();
    return super.close();
  }
}