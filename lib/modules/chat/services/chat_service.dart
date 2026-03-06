import 'package:google_generative_ai/google_generative_ai.dart';

class ChatService {
  late final GenerativeModel _model;
  late final ChatSession _chat;

  ChatService() {
    _model = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: 'AIzaSyDa_z-spYVYdiNHgQRoKMXYemDDE-abPk4', // 👈 Replace with your key
      systemInstruction: Content.system(
          "You are MedGuardian AI, a professional medical assistant. "
              "Help users understand medical terms and MRI results. "
              "IMPORTANT: You are not a doctor. Always advise users to consult a specialist "
              "if a tumor is detected. Keep answers concise and empathetic."
      ),
    );
    // Start an empty chat history
    _chat = _model.startChat();
  }

  Future<String?> sendMessage(String message) async {
    try {
      final response = await _chat.sendMessage(Content.text(message));
      return response.text;
    } catch (e) {
      print("FULL CHAT ERROR: $e"); // 👈 Check your IDE console for this!
      return "I'm having trouble connecting right now. Please try again.";
    }
  }
}