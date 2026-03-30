import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_ml_model_downloader/firebase_ml_model_downloader.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

class TFLiteService {
  Interpreter? _interpreter;
  String _currentModelType = 'Brain';

  final List<String> _brainLabels = ['Glioma', 'Meningioma', 'No Tumor', 'Pituitary'];
  final List<String> _breastLabels = ['Benign', 'Malignant'];

  Future<void> loadModel(String modelType) async {
    try {
      _currentModelType = modelType;
      String firebaseModelName = modelType == 'Brain' ? 'Brain_Model' : 'Breast_Model';

      final customModel = await FirebaseModelDownloader.instance.getModel(
        firebaseModelName,
        FirebaseModelDownloadType.localModelUpdateInBackground,
        FirebaseModelDownloadConditions(iosAllowsCellularAccess: true),
      );

      final newInterpreter = Interpreter.fromFile(customModel.file);
      _interpreter?.close();
      _interpreter = newInterpreter;

      print('Model Loaded: $modelType');
    } catch (e) {
      print('Error loading model: $e');
    }
  }

  Future<Map<String, dynamic>?> runPrediction(String imagePath) async {
    if (_interpreter == null) return null;

    final File file = File(imagePath);
    final Uint8List bytes = await file.readAsBytes();
    img.Image? originalImage = img.decodeImage(bytes);
    if (originalImage == null) return null;

    // 1. Resize (Standard 224x224)
    img.Image resizedImage = img.copyResize(originalImage, width: 224, height: 224);

    // 2. Preprocess (Separate logic inside this function)
    var inputBuffer = _imageToByteListFloat32(resizedImage, 224);

    // 3. Prepare Output Buffer & 4. Run Inference
    // We separate these because the number of output classes is different
    if (_currentModelType == 'Breast') {
      // VGG16 Binary Classification usually has 1 output unit
      var outputBuffer = List<double>.filled(1, 0.0).reshape([1, 1]);
      _interpreter!.run(inputBuffer, outputBuffer);

      double score = outputBuffer[0][0];
      bool isMalignant = score > 0.5;

      return {
        'label': isMalignant ? 'Malignant' : 'Benign',
        'confidence': isMalignant ? score : (1.0 - score),
        'all_scores': [score]
      };
    } else {
      // Brain Multi-class Classification (4 classes)
      var outputBuffer = List<double>.filled(1 * 4, 0.0).reshape([1, 4]);
      _interpreter!.run(inputBuffer, outputBuffer);

      List<double> probabilities = List<double>.from(outputBuffer[0]);
      int maxIndex = 0;
      double maxProb = -1.0;
      for (int i = 0; i < probabilities.length; i++) {
        if (probabilities[i] > maxProb) {
          maxProb = probabilities[i];
          maxIndex = i;
        }
      }

      return {
        'label': _brainLabels[maxIndex],
        'confidence': maxProb,
        'all_scores': probabilities
      };
    }
  }

  ByteBuffer _imageToByteListFloat32(img.Image image, int size) {
    var convertedBytes = Float32List(1 * size * size * 3);
    int bufferIndex = 0;

    for (int y = 0; y < size; y++) {
      for (int x = 0; x < size; x++) {
        var pixel = image.getPixel(x, y);

        double r = pixel.r.toDouble();
        double g = pixel.g.toDouble();
        double b = pixel.b.toDouble();

        if (_currentModelType == 'Breast') {
          // --- VGG16 Preprocessing ---
          // BGR Order and Mean Subtraction
          convertedBytes[bufferIndex++] = b - 103.939;
          convertedBytes[bufferIndex++] = g - 116.779;
          convertedBytes[bufferIndex++] = r - 123.68;
        } else {
          // --- Brain Model (EfficientNet) Preprocessing ---
          // Reverted to your original logic: No division, pure RGB
          convertedBytes[bufferIndex++] = r;
          convertedBytes[bufferIndex++] = g;
          convertedBytes[bufferIndex++] = b;
        }
      }
    }
    return convertedBytes.buffer;
  }

  void dispose() {
    _interpreter?.close();
  }
}