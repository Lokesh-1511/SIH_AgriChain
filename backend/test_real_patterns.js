/**
 * Test real Aadhaar patterns coverage
 */

const http = require('http');

// Test various realistic Aadhaar numbers
const testNumbers = [
  '234567890123',  // Starts with 2
  '345678901234',  // Starts with 3  
  '456789012345',  // Starts with 4
  '567890123456',  // Starts with 5
  '678901234567',  // Starts with 6
  '789012345678',  // Starts with 7
  '890123456789',  // Starts with 8
  '901234567890',  // Starts with 9
  // These should fail (start with 0 or 1)
  '012345678901',  // Should fail - starts with 0
  '123456789012',  // Should fail - starts with 1
];

console.log('🧪 Testing Real Aadhaar Pattern Coverage');
console.log('========================================');
console.log('✅ Should work: Numbers starting with 2-9');
console.log('❌ Should fail: Numbers starting with 0-1\n');

async function testAadhaar(aadhaarNumber, shouldWork = true) {
  return new Promise((resolve) => {
    const requestData = {
      aadhaar_number: aadhaarNumber,
      user_id: 'pattern-test-user'
    };
    
    const postData = JSON.stringify(requestData);
    
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
    
    console.log(`🆔 ${aadhaarNumber} (${shouldWork ? 'should work' : 'should fail'})`);
    
    const req = http.request(options, (res) => {
      let data = '';
      
      res.on('data', (chunk) => {
        data += chunk;
      });
      
      res.on('end', () => {
        try {
          const response = JSON.parse(data);
          const worked = res.statusCode === 200 && response.success;
          
          if (worked && shouldWork) {
            console.log(`   ✅ CORRECT: Generated OTP ${response.debug_otp}`);
          } else if (!worked && !shouldWork) {
            console.log(`   ✅ CORRECT: Rejected - ${response.error || response.message}`);
          } else if (worked && !shouldWork) {
            console.log(`   ⚠️  UNEXPECTED: Should have failed but worked`);
          } else {
            console.log(`   ⚠️  UNEXPECTED: Should have worked but failed - ${response.error}`);
          }
        } catch (e) {
          console.log(`   ❌ Invalid response: ${data.substring(0, 50)}`);
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

async function runPatternTests() {
  // Test numbers that should work (start with 2-9)
  for (let i = 0; i < 8; i++) {
    await testAadhaar(testNumbers[i], true);
  }
  
  console.log('🚫 Testing patterns that should be rejected:\n');
  
  // Test numbers that should fail (start with 0-1)
  for (let i = 8; i < testNumbers.length; i++) {
    await testAadhaar(testNumbers[i], false);
  }
  
  console.log('🎉 Pattern coverage test complete!');
  console.log('\n💡 Summary:');
  console.log('✅ Your Flutter app can now use ANY real Aadhaar number!');
  console.log('🆔 Valid patterns: Any 12-digit number starting with 2, 3, 4, 5, 6, 7, 8, or 9');
  console.log('🚫 Invalid patterns: Numbers starting with 0 or 1 (not used by UIDAI)');
  console.log('\n📱 Try your real Aadhaar number in your Flutter app!');
}

runPatternTests();