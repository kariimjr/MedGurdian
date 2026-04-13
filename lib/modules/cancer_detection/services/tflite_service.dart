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

  final List<String> _lungLabels = ['Benign', 'Malignant', 'Normal'];

  Future<void> loadModel(String modelType) async {
    try {
      _currentModelType = modelType;

      String firebaseModelName;
      switch (modelType) {
        case 'Breast': firebaseModelName = 'Breast_Model'; break;
        case 'Lung':   firebaseModelName = 'Lung_Model'; break;
        default:       firebaseModelName = 'Brain_Model';
      }

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

    img.Image resizedImage = img.copyResize(originalImage, width: 224, height: 224);
    var inputBuffer = _imageToByteListFloat32(resizedImage, 224);

    if (_currentModelType == 'Breast') {
      var outputBuffer = List<double>.filled(1, 0.0).reshape([1, 1]);
      _interpreter!.run(inputBuffer, outputBuffer);

      double score = outputBuffer[0][0];
      bool isMalignant = score > 0.5;

      return {
        'label': isMalignant ? 'Malignant' : 'Benign',
        'confidence': isMalignant ? score : (1.0 - score),
        'all_scores': [score]
      };
    }
    else if (_currentModelType == 'Lung') {
      var outputBuffer = List<double>.filled(1 * 3, 0.0).reshape([1, 3]);
      _interpreter!.run(inputBuffer, outputBuffer);
      return _processMultiClassResults(outputBuffer[0], _lungLabels);
    }
    else {
      var outputBuffer = List<double>.filled(1 * 4, 0.0).reshape([1, 4]);
      _interpreter!.run(inputBuffer, outputBuffer);
      return _processMultiClassResults(outputBuffer[0], _brainLabels);
    }
  }

  Map<String, dynamic> _processMultiClassResults(List<dynamic> results, List<String> labels) {
    List<double> probabilities = List<double>.from(results);
    print("Raw Model Output Scores: $probabilities"); // Helpful for debugging
    int maxIndex = 0;
    double maxProb = -1.0;

    for (int i = 0; i < probabilities.length; i++) {
      if (probabilities[i] > maxProb) {
        maxProb = probabilities[i];
        maxIndex = i;
      }
    }
    return {
      'label': labels[maxIndex],
      'confidence': maxProb,
      'all_scores': probabilities
    };
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
          convertedBytes[bufferIndex++] = b - 103.939;
          convertedBytes[bufferIndex++] = g - 116.779;
          convertedBytes[bufferIndex++] = r - 123.68;
        }
        else if (_currentModelType == 'Lung') {

          convertedBytes[bufferIndex++] = r ;
          convertedBytes[bufferIndex++] = g ;
          convertedBytes[bufferIndex++] = b ;
        }
        else {
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