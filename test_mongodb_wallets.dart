import 'dart:convert';
import 'dart:io';

/// Test script to verify MongoDB wallet address storage
Future<void> main() async {
  print('🧪 Testing MongoDB Wallet Address Storage...\n');

  try {
    // Test the API endpoints
    print('📞 Testing wallet assignment API...');

    // Check health endpoint
    final healthProcess = await Process.run('curl', [
      '-X',
      'GET',
      'http://localhost:3001/api/health',
      '-H',
      'Content-Type: application/json',
    ]);

    if (healthProcess.exitCode == 0) {
      final healthResponse = json.decode(healthProcess.stdout);
      print('✅ API Health Check: ${healthResponse['status']}');
      print('🗄️ MongoDB Status: ${healthResponse['mongodb']}');
    } else {
      print('❌ API Health Check failed');
      return;
    }

    // Check wallet assignments
    final assignmentsProcess = await Process.run('curl', [
      '-X',
      'GET',
      'http://localhost:3001/api/wallet-assignments',
      '-H',
      'Content-Type: application/json',
    ]);

    if (assignmentsProcess.exitCode == 0) {
      final assignmentsResponse = json.decode(assignmentsProcess.stdout);
      print('\n📊 Wallet Assignments:');
      print('✅ Success: ${assignmentsResponse['success']}');
      print('📈 Total Assignments: ${assignmentsResponse['totalAssignments']}');
      print('📂 Data Source: ${assignmentsResponse['source']}');

      final assignments =
          assignmentsResponse['assignments'] as Map<String, dynamic>;
      for (final role in assignments.keys) {
        final roleAssignments = assignments[role] as Map<String, dynamic>;
        print('🎭 $role: ${roleAssignments.length} wallet(s) assigned');

        for (final wallet in roleAssignments.keys) {
          final info = roleAssignments[wallet];
          print('   💰 $wallet -> ${info['name']} (${info['email']})');
        }
      }
    } else {
      print('❌ Wallet assignments check failed');
    }

    // Test specific wallet check
    final testWallet = '0xf39fd6e51aad88f6f4ce6ab8827279cfffb92266';
    print('\n🔍 Testing specific wallet check for: $testWallet');

    final walletCheckProcess = await Process.run('curl', [
      '-X',
      'GET',
      'http://localhost:3001/api/wallet-check/$testWallet',
      '-H',
      'Content-Type: application/json',
    ]);

    if (walletCheckProcess.exitCode == 0) {
      final walletResponse = json.decode(walletCheckProcess.stdout);
      print('✅ Wallet Check Success: ${walletResponse['success']}');
      print('🔒 Is Assigned: ${walletResponse['assigned']}');

      if (walletResponse['assigned']) {
        final user = walletResponse['user'];
        print('👤 Assigned to: ${user['name']} (${user['role']})');
        print('📧 Email: ${user['email']}');
        print('📅 Assigned At: ${user['assignedAt']}');
      } else {
        print('🆓 Wallet is available for assignment');
      }
    } else {
      print('❌ Wallet check failed');
    }

    print('\n🎉 MongoDB wallet address storage test completed!');
    print('💡 Now test by registering a new user in your Flutter app');
    print('🌐 Check the HTML explorer to see real-time updates');
  } catch (e) {
    print('❌ Test failed with error: $e');
  }
}
