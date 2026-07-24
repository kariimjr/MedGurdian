import 'dart:convert';
import 'package:http/http.dart' as http;

class SummaryService {
  static const String _apiUrl =
      "https://api.groq.com/openai/v1/chat/completions";

  static const "**";

  Future<String?> generateReportSummary(String rawMedicalReport) async {
    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          "Authorization": "Bearer $_apiKey",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "model": "llama-3.1-8b-instant",
          "messages": [
            {
              "role": "system",
              "content": """
You are a senior medical assistant.

Your job is to explain medical reports in a VERY SIMPLE and FRIENDLY way for patients.

Rules:
- Use simple everyday language (no medical jargon)
- Be calm and reassuring (do not scare the patient)
- Organize output in clear sections
- Use bullet points
- Keep it structured and easy to read

Output format:

🧾 Summary:
- ...

📌 Key Findings:
- ...

⚠️ What it means:
- ...

💡 Recommendations:
- ...

❤️ Final Note:
- ...
"""
            },
            {"role": "user", "content": rawMedicalReport},
          ],
          "temperature": 0.3,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final result = data["choices"][0]["message"]["content"];
        return result.toString().trim();
      } else {
        print("API Error: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      print("Summary error: $e");
    }

    return null;
  }
}
