import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_ml_model_downloader/firebase_ml_model_downloader.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

class TFLiteService {
  Interpreter? _interpreter;
  String _currentModelType = 'Brain';

  // 1. Load the Model Dynamically from Firebase
  Future<void> loadModel(String modelType) async {
    try {
      _currentModelType = modelType;

      // Use a local variable to prevent race conditions during the download
      String firebaseModelName = modelType == 'Brain' ? 'Brain_Model' : 'Breast_Model';

      final customModel = await FirebaseModelDownloader.instance.getModel(
        firebaseModelName,
        FirebaseModelDownloadType.localModelUpdateInBackground,
        FirebaseModelDownloadConditions(iosAllowsCellularAccess: true),
      );

      // ONLY close the old one if the NEW one is ready to be assigned
      final newInterpreter = Interpreter.fromFile(customModel.file);

      _interpreter?.close(); // Safe to close now
      _interpreter = newInterpreter;

      print('$modelType model loaded successfully');
    } catch (e) {
      print('Failed to load $modelType model from Firebase: $e');
      // If download fails, don't kill the whole app; just keep the old model or null
    }
  }
  // 2. Run Inference
  Future<Map<String, dynamic>?> runPrediction(String imagePath) async {
    if (_interpreter == null) return null;

    File file = File(imagePath);
    Uint8List bytes = await file.readAsBytes();
    img.Image? originalImage = img.decodeImage(bytes);
    if (originalImage == null) return null;

    // Standardize input size for your CNN models
    img.Image resizedImage = img.copyResize(originalImage, width: 224, height: 224);
    var inputBuffer = _imageToByteListFloat32(resizedImage, 224, 127.5, 127.5);

    // Output shape: [1, 2] for binary classification (Tumor/Normal or Malignant/Benign)
    var outputBuffer = List.filled(1 * 2, 0.0).reshape([1, 2]);

    _interpreter!.run(inputBuffer, outputBuffer);

    double class0Prob = outputBuffer[0][0];
    double class1Prob = outputBuffer[0][1];

    // Dynamic Labeling based on active model
    if (_currentModelType == 'Brain') {
      return class1Prob > class0Prob
          ? {'label': 'Tumor Detected', 'confidence': class1Prob}
          : {'label': 'Normal', 'confidence': class0Prob};
    } else {
      return class1Prob > class0Prob
          ? {'label': 'Malignant', 'confidence': class1Prob}
          : {'label': 'Benign', 'confidence': class0Prob};
    }
  }

  ByteBuffer _imageToByteListFloat32(img.Image image, int inputSize, double mean, double std) {
    var convertedBytes = Float32List(1 * inputSize * inputSize * 3);
    int pixelIndex = 0;

    for (int i = 0; i < inputSize; i++) {
      for (int j = 0; j < inputSize; j++) {
        var pixel = image.getPixel(j, i);
        // Normalize pixels to [-1, 1] range as required by many CNNs
        convertedBytes[pixelIndex++] = (pixel.r - mean) / std;
        convertedBytes[pixelIndex++] = (pixel.g - mean) / std;
        convertedBytes[pixelIndex++] = (pixel.b - mean) / std;
      }
    }
    return convertedBytes.buffer;
  }

  void dispose() {
    _interpreter?.close();
  }
}