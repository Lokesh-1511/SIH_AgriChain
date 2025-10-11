const { randomUUID } = require('crypto');

module.exports = (req, res, next) => {
  const existingId = req.headers['x-correlation-id'];
  const correlationId = typeof existingId === 'string' && existingId.trim() !== ''
    ? existingId.trim()
    : randomUUID();

  const context = {
    correlationId,
    receivedAt: Date.now()
  };

  req.context = context;
  res.locals.correlationId = correlationId;
  res.setHeader('X-Correlation-Id', correlationId);

  next();
};
