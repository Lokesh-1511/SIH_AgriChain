const jwt = require('jsonwebtoken');
const config = require('../config/env');
const logger = require('../utils/logger');

const authMiddleware = (requiredRoles = []) => (req, res, next) => {
  const authHeader = req.headers.authorization;
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return res.status(401).json({ status: 'error', message: 'Authentication required' });
  }

  const token = authHeader.split(' ')[1];

  try {
    const payload = jwt.verify(token, config.jwtSecret);
    req.user = payload;

    if (requiredRoles.length > 0 && !requiredRoles.includes(payload.role)) {
      return res.status(403).json({ status: 'error', message: 'Forbidden' });
    }

    return next();
  } catch (error) {
    logger.warn('JWT verification failed', { error: error.message });
    return res.status(401).json({ status: 'error', message: 'Invalid token' });
  }
};

module.exports = authMiddleware;
