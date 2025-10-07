/* eslint-disable no-console */
process.env.NODE_ENV = 'test';
process.env.JWT_SECRET = process.env.JWT_SECRET || 'test-secret';

const request = require('supertest');
const app = require('../src/app');

disableExternalLogging();

async function run() {
  try {
    const response = await request(app).get('/api/health');
    if (response.status !== 200 || response.body.status !== 'success') {
      console.error('Health check failed', response.status, response.body);
      process.exit(1);
    }
    console.log('Health check passed');
  } catch (error) {
    console.error('Health check error', error);
    process.exit(1);
  }
}

function disableExternalLogging() {
  const originalLog = console.log;
  const originalError = console.error;
  console.log = (...args) => {
    if (typeof args[0] === 'string' && args[0].includes('::1')) {
      return;
    }
    originalLog(...args);
  };
  console.error = (...args) => {
    if (typeof args[0] === 'string' && args[0].includes('DeprecationWarning')) {
      return;
    }
    originalError(...args);
  };
}

run();
