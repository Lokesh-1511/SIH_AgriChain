/**
 * Test all three Aadhaar numbers for Flutter app
 */

const http = require('http');

const testNumbers = [
  '123456789012',
  '999999990123', 
  '555555554321'
];

console.log('🧪 Testing all Aadhaar numbers for Flutter app...');
console.log(`🔗 URL: http://10.252.175.5:3000/api/aadhaar/validate\n`);

async function testAadhaar(aadhaarNumber) {
  return new Promise((resolve) => {
    const testData = {
      aadhaar_number: aadhaarNumber,
      user_id: 'test-user-flutter'
    };

    const postData = JSON.stringify(testData);

    const options = {
      hostname: '10.252.175.5',
      port: 3000,
      path: '/api/aadhaar/validate',
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Content-Length': Buffer.byteLength(postData)
      }
    };

    console.log(`📱 Testing: ${aadhaarNumber}`);

    const req = http.request(options, (res) => {
      let data = '';
      
      res.on('data', (chunk) => {
        data += chunk;
      });
      
      res.on('end', () => {
        console.log(`   📊 Status: ${res.statusCode}`);
        try {
          const response = JSON.parse(data);
          if (res.statusCode === 200 && response.success) {
            console.log(`   ✅ SUCCESS! OTP: ${response.debug_otp || 'Generated'}`);
            console.log(`   📱 Mobile: ${response.mobile_number}`);
            console.log(`   🆔 Transaction: ${response.transaction_id}`);
          } else {
            console.log(`   ❌ FAILED: ${response.error || response.message}`);
          }
        } catch (e) {
          console.log(`   ❌ Invalid JSON response: ${data.substring(0, 100)}`);
        }
        console.log('');
        resolve();
      });
    });

    req.on('error', (err) => {
      console.log(`   ❌ Connection Error: ${err.message}\n`);
      resolve();
    });

    req.setTimeout(5000, () => {
      console.log(`   ⏰ Timeout\n`);
      req.destroy();
      resolve();
    });

    req.write(postData);
    req.end();
  });
}

async function runAllTests() {
  for (const number of testNumbers) {
    await testAadhaar(number);
  }
  
  console.log('🎉 All tests completed!');
  console.log('📱 If these work, your Flutter app should work too!');
}

runAllTests();