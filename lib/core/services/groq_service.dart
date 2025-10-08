import 'dart:convert';
import 'package:http/http.dart' as http;

class GroqService {
  static const String _baseUrl = 'https://api.groq.com/openai/v1/chat/completions';
  
  // TODO: Add your Groq API key here or use environment variables
  static const String _apiKey = 'YOUR_GROQ_API_KEY_HERE';

  static Future<String> sendMessage(String message) async {
    try {
      print(' Groq API: Sending message: \');

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer \',
        },
        body: jsonEncode({
          'model': 'llama-3.1-8b-instant',
          'messages': [
            {
              'role': 'system',
              'content': 'You are a helpful agricultural assistant. Provide accurate and practical advice about farming, crops, and agricultural practices. Keep responses concise and actionable.'
            },
            {
              'role': 'user',
              'content': message,
            }
          ],
          'max_tokens': 1000,
          'temperature': 0.7,
        }),
      );

      print(' Groq API: Response status: \');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'];
        print(' Groq API: Response received successfully');
        return content;
      } else {
        print(' Groq API: Error \: \');
        return 'Sorry, I encountered an error while processing your request. Please try again later.';
      }
    } catch (e) {
      print(' Groq API: Exception occurred: \');
      return 'Sorry, I encountered an error while processing your request. Please try again later.';
    }
  }
}
