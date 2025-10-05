/**
 * Complete end-to-end test: Aadhaar validation + OTP verification
 */

const http = require('http');

// Test with real Aadhaar pattern (starts with 2-9)
const testAadhaar = '234567890123';  // Should work with new patterns
let transactionId = '';
let generatedOTP = '';

console.log('🧪 Complete End-to-End Test: Aadhaar + OTP');
console.log('==============================================');

async function step1_ValidateAadhaar() {
  return new Promise((resolve, reject) => {
    console.log('\n📋 Step 1: Validate Aadhaar Number');
    console.log(`🆔 Testing: ${testAadhaar}`);
    
    const requestData = {
      aadhaar_number: testAadhaar,
      user_id: 'complete-test-user'
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
    
    const req = http.request(options, (res) => {
      let data = '';
      
      res.on('data', (chunk) => {
        data += chunk;
      });
      
      res.on('end', () => {
        try {
          const response = JSON.parse(data);
          console.log(`   📊 Status: ${res.statusCode}`);
          
          if (res.statusCode === 200 && response.success) {
            transactionId = response.transaction_id;
            generatedOTP = response.debug_otp;
            console.log(`   ✅ SUCCESS! Aadhaar validated`);
            console.log(`   🆔 Transaction ID: ${transactionId}`);
            console.log(`   🔑 Generated OTP: ${generatedOTP}`);
            resolve();
          } else {
            console.log(`   ❌ FAILED: ${response.error || response.message}`);
            reject(new Error(response.error || 'Aadhaar validation failed'));
          }
        } catch (e) {
          console.log(`   ❌ Invalid JSON: ${data}`);
          reject(e);
        }
      });
    });
    
    req.on('error', (err) => {
      console.log(`   ❌ Connection Error: ${err.message}`);
      reject(err);
    });
    
    req.setTimeout(10000, () => {
      console.log(`   ⏰ Timeout`);
      req.destroy();
      reject(new Error('Timeout'));
    });
    
    req.write(postData);
    req.end();
  });
}

async function step2_VerifyOTP() {
  return new Promise((resolve, reject) => {
    console.log('\n🔐 Step 2: Verify OTP');
    console.log(`🆔 Transaction ID: ${transactionId}`);
    console.log(`🔑 OTP to verify: ${generatedOTP}`);
    
    const requestData = {
      transaction_id: transactionId,
      otp: generatedOTP,
      aadhaar_number: testAadhaar,  // Flutter app sends this
      user_id: 'complete-test-user'  // Flutter app sends this
    };
    
    const postData = JSON.stringify(requestData);
    
    const options = {
      hostname: '10.252.175.5',
      port: 3000,
      path: '/api/otp/verify',
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Content-Length': Buffer.byteLength(postData)
      }
    };
    
    const req = http.request(options, (res) => {
      let data = '';
      
      res.on('data', (chunk) => {
        data += chunk;
      });
      
      res.on('end', () => {
        try {
          const response = JSON.parse(data);
          console.log(`   📊 Status: ${res.statusCode}`);
          console.log(`   📄 Response:`, response);
          
          if (res.statusCode === 200 && response.success) {
            console.log(`   ✅ SUCCESS! OTP verified correctly`);
            console.log(`   🎉 Aadhaar verification complete!`);
            resolve();
          } else {
            console.log(`   ❌ FAILED: ${response.error || response.message}`);
            reject(new Error(response.error || 'OTP verification failed'));
          }
        } catch (e) {
          console.log(`   ❌ Invalid JSON: ${data}`);
          reject(e);
        }
      });
    });
    
    req.on('error', (err) => {
      console.log(`   ❌ Connection Error: ${err.message}`);
      reject(err);
    });
    
    req.setTimeout(10000, () => {
      console.log(`   ⏰ Timeout`);
      req.destroy();
      reject(new Error('Timeout'));
    });
    
    req.write(postData);
    req.end();
  });
}

async function runCompleteTest() {
  try {
    await step1_ValidateAadhaar();
    await step2_VerifyOTP();
    
    console.log('\n🎉 COMPLETE SUCCESS!');
    console.log('✅ Aadhaar validation: WORKING');
    console.log('✅ OTP generation: WORKING');  
    console.log('✅ OTP verification: WORKING');
    console.log('\n📱 Your Flutter app should now work end-to-end!');
    console.log(`🆔 Try any Aadhaar starting with 2, 3, 4, 5, 6, 7, 8, or 9`);
    
  } catch (error) {
    console.error('\n❌ Test failed:', error.message);
  }
}

runCompleteTest();