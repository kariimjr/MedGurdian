import 'dart:io';
import 'dart:typed_data';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

class TFLiteService {
  Interpreter? _interpreter;

  // 1. Load the Model
  Future<void> loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset('assets/models/brain_cancer.tflite');
      print('Model loaded successfully');
    } catch (e) {
      print('Failed to load model: $e');
    }
  }

  // 2. Run Inference
  Future<Map<String, dynamic>?> runPrediction(String imagePath) async {
    if (_interpreter == null) return null;

    // Read the image from the file
    File file = File(imagePath);
    img.Image? originalImage = img.decodeImage(file.readAsBytesSync());
    if (originalImage == null) return null;

    // Resize image to fit your CNN input shape (Usually 224x224)
    img.Image resizedImage = img.copyResize(originalImage, width: 224, height: 224);

    // Convert the image to a multi-dimensional array of floats
    var inputBuffer = _imageToByteListFloat32(resizedImage, 224, 127.5, 127.5);

    // Prepare the output buffer.
    // Assuming 2 classes (Index 0: Normal, Index 1: Tumor)
    var outputBuffer = List.filled(1 * 2, 0.0).reshape([1, 2]);

    // RUN THE AI
    _interpreter!.run(inputBuffer, outputBuffer);

    // Extract results
    double normalProb = outputBuffer[0][0];
    double tumorProb = outputBuffer[0][1];

    if (tumorProb > normalProb) {
      return {'label': 'Tumor Detected', 'confidence': tumorProb};
    } else {
      return {'label': 'Normal', 'confidence': normalProb};
    }
  }

  // 3. The Math: Converting pixels to neural network inputs
  ByteBuffer _imageToByteListFloat32(img.Image image, int inputSize, double mean, double std) {
    var convertedBytes = Float32List(1 * inputSize * inputSize * 3);
    var buffer = Float32List.view(convertedBytes.buffer);
    int pixelIndex = 0;

    for (int i = 0; i < inputSize; i++) {
      for (int j = 0; j < inputSize; j++) {
        var pixel = image.getPixel(j, i);
        // Normalize the R, G, B values
        buffer[pixelIndex++] = (pixel.r - mean) / std;
        buffer[pixelIndex++] = (pixel.g - mean) / std;
        buffer[pixelIndex++] = (pixel.b - mean) / std;
      }
    }
    return convertedBytes.buffer;
  }

  void dispose() {
    _interpreter?.close();
  }
}