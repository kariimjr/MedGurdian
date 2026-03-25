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

    on<InitializeScanEvent>((event, emit) async {
      emit(ScanLoading());
      try {
        await _tfliteService.loadModel(_activeModel);
        emit(ScanInitial());
      } catch (e) {
        emit(ScanError("Initial load failed: $e"));
      }
    });

    on<SwitchModelEvent>((event, emit) async {
      try {
        // Use event.modelType safely
        _activeModel = event.modelType;
        emit(ScanLoading());

        // This now fetches from Firebase instead of local assets
        await _tfliteService.loadModel(_activeModel);

        emit(ScanInitial());
      } catch (e) {
        emit(ScanError("Failed to switch model: $e"));
      }
    });

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

            await _saveScanToHistory(label, confidence, _activeModel);

            emit(ScanSuccess(imageFile, label, confidence, _activeModel));
          } else {
            emit(ScanError("Could not analyze the image."));
          }
        } else {
          emit(ScanInitial());
        }
      } catch (e) {
        emit(ScanError("Failed to process image: $e"));
      }
    });

    on<ClearHistoryEvent>((event, emit) async {
      try {
        final String? userId = _auth.currentUser?.uid;
        if (userId != null) {
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