import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:medgurdian/modules/chat/services/chat_service.dart';

class MedicalChatScreen extends StatefulWidget {
  const MedicalChatScreen({super.key});

  @override
  State<MedicalChatScreen> createState() => _MedicalChatScreenState();
}

class _MedicalChatScreenState extends State<MedicalChatScreen> {

  final ChatService _chatService = ChatService();
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];
  bool _isLoading = false;

  // Suggestions tailored to your MedGuardian project focus
  final List<String> _suggestions = [
    "Explain Brain MRI results",
    "Symptoms of Breast Cancer",
    "How to prepare for a scan?",
    "Next steps after diagnosis"
  ];

  void _sendPrompt({String? text}) async {
    String userMessage = text ?? _controller.text;
    if (userMessage.isEmpty) return;

    setState(() {
      _messages.add({"role": "user", "text": userMessage});
      _isLoading = true;
    });
    _controller.clear();

    final response = await _chatService.sendMessage(userMessage);

    setState(() {
      _messages.add({
        "role": "ai",
        "text": response ??
            "I'm having trouble connecting to the medical server."
      });
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        foregroundColor: const Color(0xFF0277BD),

        centerTitle: true,
        title: Column(
          children: [

            const Text("AI Helper", style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),

        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFE1F5FE), // Light Sky Blue
              Colors.white,
              Color(0xFFE3F2FD), // Soft Blue Wash
            ],
            stops: [0.0, 0.4, 1.0],
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: _messages.isEmpty
                  ? _buildWelcomeState()
                  : _buildChatList(),
            ),
            _buildInputSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeState() {


    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 220,
            child: Lottie.asset(
              'assets/json/circles.json',
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => const CircleAvatar(
                radius: 60,
                backgroundColor: Colors.blueAccent,
                child: Icon(Icons.auto_awesome, color: Colors.white, size: 40),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            "Hey, What are you looking for today?", // Dynamic greeting
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0277BD),
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildChatList() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 100, 20, 20),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final msg = _messages[index];
        bool isUser = msg["role"] == "user";
        return _buildChatBubble(msg["text"]!, isUser);
      },
    );
  }

  Widget _buildChatBubble(String text, bool isUser) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isUser ? const Color(0xFF0277BD) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4)
            )
          ],
        ),
        child: Text(
          text,
          style: TextStyle(
              color: isUser ? Colors.white : Colors.black87,
              fontSize: 15,
              height: 1.4
          ),
        ),
      ),
    );
  }

  Widget _buildInputSection() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 25),
      child: Column(
        children: [
          // Horizontal Scrollable Suggestions with Constant Size
          if (_messages.isEmpty)
            SizedBox(
              height: 70, // Increased height to accommodate multiple lines
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _suggestions.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () => _sendPrompt(text: _suggestions[index]),
                    child: Container(
                      width: 180,
                      // Constant width for all capsules
                      margin: const EdgeInsets.only(right: 12),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: Colors.blue.withOpacity(0.1)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          )
                        ],
                      ),
                      child: Center(
                        child: Text(
                          _suggestions[index],
                          textAlign: TextAlign.center,
                          maxLines: 2, // Allows text to wrap into lines
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF0277BD),
                            fontWeight: FontWeight.w500,
                            height: 1.2, // Adjusts line spacing for clarity
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          const SizedBox(height: 15),

          // Modern Capsule Input Bar
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(40),
              boxShadow: [
                BoxShadow(
                    color: Colors.blue.withOpacity(0.1),
                    blurRadius: 25,
                    offset: const Offset(0, 8)
                )
              ],
            ),
            child: Row(
              children: [
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    onSubmitted: (val) => _sendPrompt(),
                    decoration: const InputDecoration(
                      hintText: "Start searching...",
                      border: InputBorder.none,
                      hintStyle: TextStyle(
                          color: Colors.blueGrey, fontSize: 15),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: _sendPrompt,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white)
                    )
                        : const Icon(
                        Icons.arrow_upward, color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}