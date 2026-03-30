import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_ml_model_downloader/firebase_ml_model_downloader.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

class TFLiteService {
  Interpreter? _interpreter;
  String _currentModelType = 'Brain';

  // Labels matching the index order of your model
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

    // 1. Resize to match Colab input (224x224)
    img.Image resizedImage = img.copyResize(originalImage, width: 224, height: 224);

    // 2. Preprocess: Use 0.0 mean and 255.0 std to match "input / 255.0" from Colab
    var inputBuffer = _imageToByteListFloat32(resizedImage, 224, 0.0, 255.0);

    // 3. Prepare output buffer (4 classes for Brain, 2 for Breast)
    int numClasses = _currentModelType == 'Brain' ? 4 : 2;
    var outputBuffer = List<double>.filled(1 * numClasses, 0.0).reshape([1, numClasses]);

    // 4. Run Inference
    _interpreter!.run(inputBuffer, outputBuffer);

    // 5. Process results
    List<double> probabilities = List<double>.from(outputBuffer[0]);

    // Find the index with the highest probability (Argmax)
    int maxIndex = 0;
    double maxProb = -1.0;
    for (int i = 0; i < probabilities.length; i++) {
      if (probabilities[i] > maxProb) {
        maxProb = probabilities[i];
        maxIndex = i;
      }
    }

    List<String> labels = _currentModelType == 'Brain' ? _brainLabels : _breastLabels;

    return {
      'label': labels[maxIndex],
      'confidence': maxProb,
      'all_scores': probabilities // Good for debugging
    };
  }

  ByteBuffer _imageToByteListFloat32(img.Image image, int size, double d, double k) {
    var convertedBytes = Float32List(1 * size * size * 3);
    int bufferIndex = 0;

    for (int y = 0; y < size; y++) {
      for (int x = 0; x < size; x++) {
        var pixel = image.getPixel(x, y);

        // TRY THIS:
        // If the model was trained with 'preprocess_input',
        // it usually wants the pixels scaled to [-1, 1]
        // OR kept at [0, 255].

        // Standard EfficientNetV2 (Most likely):
        convertedBytes[bufferIndex++] = pixel.r.toDouble();
        convertedBytes[bufferIndex++] = pixel.g.toDouble();
        convertedBytes[bufferIndex++] = pixel.b.toDouble();

        /* IF THE ABOVE STILL SAYS "NO TUMOR", replace the 3 lines above with:
      convertedBytes[bufferIndex++] = (pixel.r / 127.5) - 1.0;
      convertedBytes[bufferIndex++] = (pixel.g / 127.5) - 1.0;
      convertedBytes[bufferIndex++] = (pixel.b / 127.5) - 1.0;
      */
      }
    }
    return convertedBytes.buffer;
  }
  void dispose() {
    _interpreter?.close();
  }
}