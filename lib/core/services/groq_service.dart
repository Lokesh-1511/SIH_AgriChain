import 'dart:convert';import 'dart:convert';

import 'package:http/http.dart' as http;import 'package:http/http.dart' as http;



class GroqService {class GroqService {

  static const String _baseUrl =  static const String _baseUrl =

      'https://api.groq.com/openai/v1/chat/completions';      'https://api.groq.com/openai/v1/chat/completions';

    

  // TODO: Add your Groq API key here or use environment variables  // TODO: Add your Groq API key here or use environment variables

  static const String _apiKey = 'YOUR_GROQ_API_KEY_HERE';  static const String _apiKey = 'YOUR_GROQ_API_KEY_HERE';



  static Future<String> sendMessage(String message) async {  static Future<String> sendMessage(String message) async {

    try {    try {

      print('🤖 Groq API: Sending message: $message');      print('🤖 Groq API: Sending message: $message');



      final response = await http.post(      final response = await http.post(

        Uri.parse(_baseUrl),        Uri.parse(_baseUrl),

        headers: {        headers: {

          'Content-Type': 'application/json',          'Content-Type': 'application/json',

          'Authorization': 'Bearer $_apiKey',          'Authorization': 'Bearer $_apiKey',

        },        },

        body: jsonEncode({        body: jsonEncode({

          'model': 'llama-3.1-8b-instant',          'model': 'llama-3.1-8b-instant',

          'messages': [          'messages': [

            {            {

              'role': 'system',              'role': 'system',

              'content': 'You are a helpful agricultural assistant. Provide accurate and practical advice about farming, crops, and agricultural practices. Keep responses concise and actionable.'              'content':

            },                  'You are a helpful agricultural supply chain assistant. Provide concise, helpful responses about farming, distribution, logistics, and agricultural best practices. Keep responses under 150 words.',

            {            },

              'role': 'user',            {'role': 'user', 'content': message},

              'content': message,          ],

            }          'max_tokens': 200,

          ],          'temperature': 0.7,

          'max_tokens': 1000,        }),

          'temperature': 0.7,      );

        }),

      );      print('🤖 Groq API Response Status: ${response.statusCode}');

      print('🤖 Groq API Response Body: ${response.body}');

      print('🤖 Groq API: Response status: ${response.statusCode}');

      if (response.statusCode == 200) {

      if (response.statusCode == 200) {        final data = jsonDecode(response.body);

        final data = jsonDecode(response.body);        if (data['choices'] != null && data['choices'].isNotEmpty) {

        final content = data['choices'][0]['message']['content'];          return data['choices'][0]['message']['content'];

        print('🤖 Groq API: Response received successfully');        } else {

        return content;          return 'I received your message but could not generate a proper response. Please try rephrasing your question.';

      } else {        }

        print('🤖 Groq API: Error ${response.statusCode}: ${response.body}');      } else {

        return 'Sorry, I encountered an error while processing your request. Please try again later.';        print('🤖 Groq API Error: ${response.statusCode} - ${response.body}');

      }        return 'Sorry, I am currently experiencing technical difficulties (Error ${response.statusCode}). Please try again later.';

    } catch (e) {      }

      print('🤖 Groq API: Exception occurred: $e');    } catch (e) {

      return 'Sorry, I encountered an error while processing your request. Please try again later.';      print('🤖 Groq API Exception: $e');

    }      return 'I apologize, but I am unable to respond right now. Please check your internet connection and try again.';

  }    }

}  }
}
