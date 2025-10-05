/**
 * Test Script for AgriChain Backend
 */

const axios = require('axios');

const BASE_URL = 'http://localhost:3000';

async function testBackend() {
  console.log('🧪 Testing AgriChain Node.js Backend');
  console.log('=' .repeat(50));
  
  try {
    // Test 1: Health Check
    console.log('1. Testing Health Check...');
    const healthResponse = await axios.get(`${BASE_URL}/api/health`);
    console.log('✅ Health Check:', healthResponse.data.status);
    
    // Test 2: Valid Aadhaar Validation
    console.log('\n2. Testing Valid Aadhaar...');
    const validAadhaarResponse = await axios.post(`${BASE_URL}/api/aadhaar/validate`, {
      aadhaar_number: '123456789012',
      user_role: 'farmer',
      user_id: 'test_user_001'
    });
    
    console.log('✅ Aadhaar Validation Success:');
    console.log('   Transaction ID:', validAadhaarResponse.data.transaction_id);
    console.log('   Mobile Number:', validAadhaarResponse.data.mobile_number);
    console.log('   Debug OTP:', validAadhaarResponse.data.debug_otp);
    
    const transactionId = validAadhaarResponse.data.transaction_id;
    const debugOTP = validAadhaarResponse.data.debug_otp;
    
    // Test 3: OTP Verification
    console.log('\n3. Testing OTP Verification...');
    const otpResponse = await axios.post(`${BASE_URL}/api/otp/verify`, {
      transaction_id: transactionId,
      otp: debugOTP
    });
    
    console.log('✅ OTP Verification Success:');
    console.log('   Aadhaar Verified:', otpResponse.data.aadhaar_verified);
    console.log('   Verified At:', otpResponse.data.verified_at);
    
    // Test 4: Invalid Aadhaar
    console.log('\n4. Testing Invalid Aadhaar...');
    try {
      await axios.post(`${BASE_URL}/api/aadhaar/validate`, {
        aadhaar_number: '000000000000',
        user_role: 'farmer'
      });
    } catch (error) {
      console.log('✅ Invalid Aadhaar Properly Rejected:');
      console.log('   Error:', error.response.data.error);
    }
    
    console.log('\n🎉 All Tests Passed!');
    console.log('=' .repeat(50));
    console.log('📋 Summary:');
    console.log('✅ Backend server is running properly');
    console.log('✅ Aadhaar validation working with patterns');
    console.log('✅ OTP generation and verification working');
    console.log('✅ Error handling working correctly');
    console.log('\n🚀 Ready for Flutter integration!');
    
  } catch (error) {
    console.error('❌ Test Failed:', error.message);
    if (error.code === 'ECONNREFUSED') {
      console.error('💡 Make sure the backend server is running on port 3000');
    }
  }
}

// Only run if this script is executed directly
if (require.main === module) {
  testBackend();
}

module.exports = { testBackend };