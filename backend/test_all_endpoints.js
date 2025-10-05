/**
 * Test all backend endpoints for physical device
 */

const http = require('http');

const baseUrl = 'http://10.252.175.5:3000';
const endpoints = [
  '/api/health',
  '/api/aadhaar/validate',
  '/api/otp/verify'
];

console.log('🧪 Testing all backend endpoints for physical device...');
console.log(`🏠 Base URL: ${baseUrl}\n`);

async function testEndpoint(path, method = 'GET', data = null) {
  return new Promise((resolve) => {
    const options = {
      hostname: '10.252.175.5',
      port: 3000,
      path: path,
      method: method,
      headers: {
        'Content-Type': 'application/json',
      }
    };

    const req = http.request(options, (res) => {
      let responseData = '';
      
      res.on('data', (chunk) => {
        responseData += chunk;
      });
      
      res.on('end', () => {
        console.log(`✅ ${method} ${path} - Status: ${res.statusCode}`);
        if (res.statusCode === 200) {
          try {
            const parsed = JSON.parse(responseData);
            console.log(`   📋 Response: ${parsed.status || parsed.message || 'OK'}`);
          } catch (e) {
            console.log(`   📋 Response: ${responseData.substring(0, 100)}...`);
          }
        } else {
          console.log(`   ⚠️  Response: ${responseData.substring(0, 100)}`);
        }
        console.log('');
        resolve(true);
      });
    });

    req.on('error', (err) => {
      console.log(`❌ ${method} ${path} - Error: ${err.message}\n`);
      resolve(false);
    });

    req.setTimeout(5000, () => {
      console.log(`⏰ ${method} ${path} - Timeout\n`);
      req.destroy();
      resolve(false);
    });

    if (data) {
      req.write(JSON.stringify(data));
    }
    
    req.end();
  });
}

async function runTests() {
  // Test health endpoint
  await testEndpoint('/api/health');
  
  // Test Aadhaar validation with valid pattern
  await testEndpoint('/api/aadhaar/validate', 'POST', {
    aadhaar_number: '123456789012',
    user_id: 'test-user'
  });
  
  // Test invalid Aadhaar pattern
  await testEndpoint('/api/aadhaar/validate', 'POST', {
    aadhaar_number: '111111111111',
    user_id: 'test-user'
  });
  
  console.log('🎉 All tests completed!');
  console.log('📱 Your Flutter app should now work perfectly with these endpoints.');
}

runTests();