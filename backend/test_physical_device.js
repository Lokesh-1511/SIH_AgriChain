/**
 * Test backend connectivity for physical Android device
 * Tests the specific IP address for the development machine
 */

const http = require('http');

const testUrl = 'http://10.252.175.5:3000/api/health';

console.log('🔍 Testing backend connectivity for physical Android device...');
console.log(`📱 Target URL: ${testUrl}`);

const req = http.get(testUrl, (res) => {
  let data = '';
  
  res.on('data', (chunk) => {
    data += chunk;
  });
  
  res.on('end', () => {
    console.log('\n✅ SUCCESS! Physical device can connect to backend');
    console.log(`📊 Status Code: ${res.statusCode}`);
    console.log(`📋 Response: ${data}`);
    console.log('\n🎉 Your Flutter app should now work on physical device!');
  });
});

req.on('error', (err) => {
  console.error('\n❌ CONNECTION FAILED!');
  console.error(`🚫 Error: ${err.message}`);
  console.log('\n🔧 Troubleshooting steps:');
  console.log('1. Make sure your phone and PC are on the same WiFi network');
  console.log('2. Check Windows Firewall settings');
  console.log('3. Verify the IP address is correct: 10.252.175.5');
});

req.setTimeout(5000, () => {
  console.error('\n⏰ CONNECTION TIMEOUT');
  console.log('🔧 This might be due to:');
  console.log('1. Firewall blocking the connection');
  console.log('2. Different WiFi networks');
  console.log('3. Network security settings');
  req.destroy();
});