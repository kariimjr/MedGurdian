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

  String _activeModel = 'Brain';

  ScanBloc() : super(ScanInitial()) {

    // Initialize first model
    on<InitializeScanEvent>((event, emit) async {
      emit(ScanLoading());
      try {
        await _tfliteService.loadModel(_activeModel);
        emit(ScanInitial());
      } catch (e) {
        emit(ScanError("Initial load failed: $e"));
      }
    });

    // Switch between Brain, Breast, and Lung
    on<SwitchModelEvent>((event, emit) async {
      emit(ScanLoading());
      try {
        _activeModel = event.modelType;
        await _tfliteService.loadModel(_activeModel);
        emit(ScanInitial());
      } catch (e) {
        emit(ScanError("Failed to switch model to $_activeModel: $e"));
      }
    });

    // Handle Image Picking and Prediction
    on<PickImageEvent>((event, emit) async {
      try {
        final XFile? pickedFile = await _picker.pickImage(source: event.source);

        if (pickedFile != null) {
          File imageFile = File(pickedFile.path);

          // Show picked image immediately
          emit(ScanImagePicked(imageFile));
          emit(ScanLoading());

          // 🔥 This calls your TFLiteService which now handles Lung logic
          var result = await _tfliteService.runPrediction(pickedFile.path);

          if (result != null) {
            String label = result['label'];
            double confidence = result['confidence'];

            // Save to Firestore with the correct category
            await _saveScanToHistory(label, confidence, _activeModel);

            emit(ScanSuccess(
                image: imageFile,
                resultLabel: label,
                confidence: confidence,
                category: _activeModel
            ));
          } else {
            emit(ScanError("AI Analysis failed. Please try a different image."));
          }
        }
      } catch (e) {
        emit(ScanError("Processing Error: ${e.toString()}"));
      }
    });

    on<ClearHistoryEvent>((event, emit) async {
      try {
        final String? userId = _auth.currentUser?.uid;
        if (userId == null) return;

        var snapshots = await _firestore
            .collection('scan_history')
            .where('userId', isEqualTo: userId)
            .where('category', isEqualTo: _activeModel) // 🔥 Only clear current category
            .get();

        final batch = _firestore.batch();
        for (var doc in snapshots.docs) {
          batch.delete(doc.reference);
        }
        await batch.commit();
        emit(ScanInitial());
      } catch (e) {
        emit(ScanError("Clear history failed: $e"));
      }
    });
  }

  Future<void> _saveScanToHistory(String label, double confidence, String category) async {
    final String? userId = _auth.currentUser?.uid;
    if (userId != null) {
      await _firestore.collection('scan_history').add({
        'userId': userId,
        'label': label,
        'confidence': confidence,
        'category': category,
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