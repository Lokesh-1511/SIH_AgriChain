const rateLimit = require('express-rate-limit');
const config = require('../config/env');

const loginRateLimiter = rateLimit({
  windowMs: config.loginRateLimit.windowMs,
  max: config.loginRateLimit.max,
  standardHeaders: true,
  legacyHeaders: false,
  keyGenerator: (req) => `${req.ip}:${req.body?.email || 'anonymous'}`,
  handler: (req, res) => {
    res.status(429).json({
      status: 'error',
      message: 'Too many login attempts. Please try again later.'
    });
  }
});

module.exports = loginRateLimiter;
