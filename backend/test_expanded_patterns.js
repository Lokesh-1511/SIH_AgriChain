/**
 * Test expanded Aadhaar patterns for realistic validation
 */

const http = require('http');

// Test various Aadhaar patterns that should now work
const testNumbers = [
  // Original patterns
  '123456789012',
  '999999990123',
  '555555554321',
  
  // New patterns for better coverage
  '234567890123',  // 234567* pattern
  '345678901234',  // 345678* pattern
  '456789012345',  // 456789* pattern
  '567890123456',  // 567890* pattern
  '678901234567',  // 678901* pattern
  '789012345678',  // 789012* pattern
  '890123456789',  // 890123* pattern
  '202020202020',  // 202020* pattern
  '303030303030',  // 303030* pattern
  '404040404040',  // 404040* pattern
  '121212121212',  // 121212* pattern
  '131313131313',  // 131313* pattern
  
  // These should still fail
  '100000000000',  // Not in allowed patterns
  '987654321098',  // Not in allowed patterns
];

console.log('🧪 Testing expanded Aadhaar validation patterns...');
console.log(`🔗 Backend: http://10.252.175.5:3000/api/aadhaar/validate`);
console.log(`📊 Testing ${testNumbers.length} different Aadhaar numbers:\n`);

async function testAadhaar(aadhaarNumber, expectedResult = 'should work') {
  return new Promise((resolve) => {
    const testData = {
      aadhaar_number: aadhaarNumber,
      user_id: 'test-expanded-patterns'
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

    console.log(`📱 ${aadhaarNumber} (${expectedResult})`);

    const req = http.request(options, (res) => {
      let data = '';
      
      res.on('data', (chunk) => {
        data += chunk;
      });
      
      res.on('end', () => {
        try {
          const response = JSON.parse(data);
          if (res.statusCode === 200 && response.success) {
            console.log(`   ✅ SUCCESS! OTP: ${response.debug_otp}`);
            console.log(`   🆔 Transaction: ${response.transaction_id.substring(0, 20)}...`);
          } else {
            console.log(`   ❌ FAILED: ${response.error || response.message || 'Unknown error'}`);
          }
        } catch (e) {
          console.log(`   ❌ Invalid response: ${data.substring(0, 50)}...`);
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
  // Test patterns that should work
  for (let i = 0; i < testNumbers.length - 2; i++) {
    await testAadhaar(testNumbers[i], 'should work');
  }
  
  console.log('🚫 Testing patterns that should be rejected:\n');
  
  // Test patterns that should fail
  for (let i = testNumbers.length - 2; i < testNumbers.length; i++) {
    await testAadhaar(testNumbers[i], 'should fail');
  }
  
  console.log('🎉 All pattern tests completed!');
  console.log('💡 Now you can use any Aadhaar number starting with these patterns:');
  console.log('   123456*, 234567*, 345678*, 456789*, 567890*, 678901*,');
  console.log('   789012*, 890123*, 202020*, 303030*, 404040*, 121212*,');
  console.log('   131313*, 999999*, 888888*, 777777*, 666666*, 555555*,');
  console.log('   444444*, 333333*, 222222*, 111111*, and many more!');
  console.log('\n📱 Try entering any 12-digit number starting with these patterns in your Flutter app!');
}

runAllTests();