const app = require('./app');
const config = require('./config/env');
const db = require('./db/mongoose');
const logger = require('./utils/logger');

const start = async () => {
  try {
    await db.connect();
    app.listen(config.port, () => {
      logger.info('Server started', { port: config.port, env: config.env });
    });
  } catch (error) {
    logger.error('Failed to start server', { error: error.message });
    process.exit(1);
  }
};

process.on('unhandledRejection', (reason) => {
  logger.error('Unhandled rejection', { reason });
  process.exit(1);
});

process.on('SIGTERM', async () => {
  logger.info('Received SIGTERM, shutting down gracefully');
  await db.disconnect();
  process.exit(0);
});

start();
