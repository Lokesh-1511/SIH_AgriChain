const logger = require('../utils/logger');

module.exports = (err, req, res, next) => {
  const status = err.status || err.statusCode || 500;
  const response = {
    status: 'error',
    message: err.message || 'Internal Server Error'
  };

  const meta = {
    correlationId: req.context?.correlationId,
    path: req.originalUrl,
    method: req.method
  };

  if (status >= 500) {
    logger.error('Unhandled error', { ...meta, error: err.stack || err.message });
  } else {
    logger.warn('Handled error', { ...meta, status, message: err.message });
  }

  res.status(status).json(response);
};
