import 'package:image_picker/image_picker.dart';

abstract class ScanEvent {}

// 🔥 NEW: Triggers the first model download/load on app startup
class InitializeScanEvent extends ScanEvent {}

class PickImageEvent extends ScanEvent {
  final ImageSource source;
  PickImageEvent(this.source);
}

class SwitchModelEvent extends ScanEvent {
  final String modelType; // 'Brain' or 'Breast'
  SwitchModelEvent(this.modelType);
}

class ClearHistoryEvent extends ScanEvent {}