/**
 * Quick test for specific Aadhaar validation
 */

const http = require('http');

const testData = {
  aadhaar_number: '123456789012',
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

console.log('🧪 Testing Aadhaar validation for Flutter app...');
console.log(`📱 Testing: ${testData.aadhaar_number}`);
console.log(`🔗 URL: http://10.252.175.5:3000/api/aadhaar/validate\n`);

const req = http.request(options, (res) => {
  let data = '';
  
  res.on('data', (chunk) => {
    data += chunk;
  });
  
  res.on('end', () => {
    console.log(`📊 Status Code: ${res.statusCode}`);
    console.log(`📋 Response:`, JSON.parse(data));
    
    if (res.statusCode === 200) {
      const response = JSON.parse(data);
      if (response.success && response.otp) {
        console.log('\n✅ SUCCESS! OTP Generated:', response.otp);
        console.log('🎉 Your Flutter app should receive this OTP!');
      } else {
        console.log('\n⚠️  Response successful but no OTP found');
      }
    } else {
      console.log('\n❌ Validation failed - check the error message above');
    }
  });
});

req.on('error', (err) => {
  console.error('\n❌ Connection Error:', err.message);
  console.log('🔧 Make sure the backend is running');
});

req.setTimeout(5000, () => {
  console.error('\n⏰ Request Timeout');
  req.destroy();
});

req.write(postData);
req.end();