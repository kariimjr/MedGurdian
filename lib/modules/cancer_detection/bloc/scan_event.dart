import 'package:image_picker/image_picker.dart';

abstract class ScanEvent {}

class InitializeScanEvent extends ScanEvent {}

class PickImageEvent extends ScanEvent {
  final ImageSource source;
  PickImageEvent(this.source);
}

class SwitchModelEvent extends ScanEvent {
  final String modelType; // 🔥 Supports 'Brain', 'Breast', or 'Lung'
  SwitchModelEvent(this.modelType);
}

class ClearHistoryEvent extends ScanEvent {}