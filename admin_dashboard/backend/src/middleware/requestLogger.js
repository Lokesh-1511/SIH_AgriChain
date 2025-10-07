const logger = require('../utils/logger');

module.exports = (req, res, next) => {
  const start = Date.now();

  res.on('finish', () => {
    const duration = Date.now() - start;
    const correlationId = req.context?.correlationId;
    logger.info('HTTP request completed', {
      correlationId,
      method: req.method,
      path: req.originalUrl,
      statusCode: res.statusCode,
      durationMs: duration,
      ip: req.ip,
      userAgent: req.headers['user-agent'],
      contentLength: res.getHeader('Content-Length') || 0
    });
  });

  next();
};
