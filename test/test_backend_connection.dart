import 'dart:convert';
import 'package:http/http.dart' as http;

/// Simple test script to verify Flutter can connect to backend
void main() async {
  print('🧪 Testing Flutter → Backend connectivity...');

  // Test 1: Health Check
  await testHealthCheck();

  // Test 2: Aadhaar Validation
  await testAadhaarValidation();
}

Future<void> testHealthCheck() async {
  print('\n📊 Test 1: Health Check');
  try {
    final url = Uri.parse('http://10.252.175.5:3000/api/health');
    print('🔗 URL: $url');

    final response = await http.get(url).timeout(Duration(seconds: 10));

    print('📨 Status: ${response.statusCode}');
    print('📄 Response: ${response.body}');

    if (response.statusCode == 200) {
      print('✅ Health check PASSED');
    } else {
      print('❌ Health check FAILED');
    }
  } catch (e) {
    print('❌ Health check ERROR: $e');
  }
}

Future<void> testAadhaarValidation() async {
  print('\n🔍 Test 2: Aadhaar Validation');
  try {
    final url = Uri.parse('http://10.252.175.5:3000/api/aadhaar/validate');
    print('🔗 URL: $url');

    final requestBody = {
      'aadhaar_number': '123456789012',
      'user_id': 'flutter-test-user',
    };

    print('📤 Request: $requestBody');

    final response = await http
        .post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(requestBody),
        )
        .timeout(Duration(seconds: 10));

    print('📨 Status: ${response.statusCode}');
    print('📄 Response: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        print('✅ Aadhaar validation PASSED');
        print('🔑 Transaction ID: ${data['transaction_id']}');
        print('📱 Debug OTP: ${data['debug_otp']}');
      } else {
        print('❌ Aadhaar validation FAILED: ${data['message']}');
      }
    } else {
      print('❌ HTTP Error: ${response.statusCode}');
    }
  } catch (e) {
    print('❌ Aadhaar validation ERROR: $e');
  }
}
