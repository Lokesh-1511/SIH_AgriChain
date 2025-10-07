const mongoose = require('mongoose');
const config = require('../config/env');
const logger = require('../utils/logger');

mongoose.set('strictQuery', true);

const connect = async () => {
  try {
    await mongoose.connect(config.mongoUri, {
      serverSelectionTimeoutMS: 5000
    });
    // Redact credentials before logging
    let redacted = config.mongoUri;
    try {
      if (redacted.startsWith('mongodb')) {
        // mongodb+srv://user:pass@host/db -> remove password part
        redacted = redacted.replace(/(mongodb\+srv:\/\/[^:]+):[^@]+@/, '$1:****@');
      }
    } catch (e) {
      // fallback: do nothing, better to still log connection success than crash
    }
    logger.info('Connected to MongoDB', { uri: redacted });
  } catch (error) {
    logger.error('MongoDB connection error', { error: error.message });
    throw error;
  }
};

const disconnect = async () => {
  await mongoose.disconnect();
  logger.info('Disconnected from MongoDB');
};

module.exports = {
  connect,
  disconnect
};
