const path = require('path');
const dotenv = require('dotenv');

const envFile = process.env.NODE_ENV === 'test' ? '.env.test' : '.env';
dotenv.config({ path: path.resolve(process.cwd(), envFile) });

const parseNumber = (value, fallback) => {
  const parsed = Number(value);
  return Number.isFinite(parsed) ? parsed : fallback;
};

const config = {
  env: process.env.NODE_ENV || 'development',
  port: parseNumber(process.env.PORT, 5000),
  mongoUri: process.env.MONGODB_URI || 'mongodb://localhost:27017/agrichain',
  jwtSecret: process.env.JWT_SECRET,
  jwtExpiresIn: process.env.JWT_EXPIRES_IN || '1h',
  logLevel: process.env.LOG_LEVEL || 'info',
  rateLimit: {
    windowMs: parseNumber(process.env.RATE_LIMIT_WINDOW_MS, 60_000),
    max: parseNumber(process.env.RATE_LIMIT_MAX, 100)
  },
  loginRateLimit: {
    windowMs: parseNumber(process.env.LOGIN_RATE_LIMIT_WINDOW_MS, 15 * 60_000),
    max: parseNumber(process.env.LOGIN_RATE_LIMIT_MAX, 5)
  }
};

if (!config.jwtSecret) {
  // eslint-disable-next-line no-console
  console.warn('⚠️  JWT_SECRET is not set. Using a weak fallback for development.');
  config.jwtSecret = 'change-me-in-production';
}

module.exports = config;
