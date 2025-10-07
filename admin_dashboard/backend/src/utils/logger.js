const levels = ['error', 'warn', 'info', 'debug'];

const getLevelIndex = (level) => {
  const idx = levels.indexOf(level);
  return idx === -1 ? levels.indexOf('info') : idx;
};

const currentLevelIndex = getLevelIndex(process.env.LOG_LEVEL || 'info');

const log = (level, message, meta) => {
  if (getLevelIndex(level) > currentLevelIndex) return;
  const output = {
    level,
    message,
    timestamp: new Date().toISOString(),
    ...(meta || {})
  };
  // eslint-disable-next-line no-console
  console.log(JSON.stringify(output));
};

module.exports = {
  error: (message, meta) => log('error', message, meta),
  warn: (message, meta) => log('warn', message, meta),
  info: (message, meta) => log('info', message, meta),
  debug: (message, meta) => log('debug', message, meta)
};
