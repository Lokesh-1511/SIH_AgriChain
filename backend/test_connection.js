/**
 * Simple connectivity test for Android emulator
 */

const axios = require('axios');

async function testEmulatorConnection() {
  console.log('🧪 Testing Android Emulator Connection');
  console.log('=' .repeat(50));
  
  const urls = [
    'http://localhost:3000/api/health',
    'http://127.0.0.1:3000/api/health',
    'http://10.0.2.2:3000/api/health'  // This is what Android emulator will use
  ];
  
  for (const url of urls) {
    try {
      console.log(`📡 Testing: ${url}`);
      const response = await axios.get(url, { timeout: 5000 });
      console.log(`✅ SUCCESS: ${response.status} - ${response.data.status}`);
      console.log(`📊 Backend: ${response.data.service} v${response.data.version}`);
      console.log('');
    } catch (error) {
      if (error.code === 'ECONNREFUSED') {
        console.log(`❌ Connection refused: ${url}`);
      } else if (error.code === 'ENOTFOUND') {
        console.log(`❌ Host not found: ${url}`);
      } else {
        console.log(`❌ Error: ${error.message}`);
      }
      console.log('');
    }
  }
  
  console.log('📱 For Android Emulator:');
  console.log('   Use: http://10.0.2.2:3000');
  console.log('   This maps to host machine localhost:3000');
  console.log('');
  console.log('🖥️  For Web/Desktop:');
  console.log('   Use: http://localhost:3000');
  console.log('');
}

testEmulatorConnection();