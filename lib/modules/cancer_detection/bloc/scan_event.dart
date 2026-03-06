import 'package:image_picker/image_picker.dart';

abstract class ScanEvent {}

class PickImageEvent extends ScanEvent {
  final ImageSource source;
  PickImageEvent(this.source);
}
class ClearHistoryEvent extends ScanEvent {}