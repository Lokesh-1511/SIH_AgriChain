const pkg = require('../../package.json');

const getHealth = (req, res) => {
  const uptimeSeconds = process.uptime();
  res.json({
    status: 'success',
    data: {
      service: 'admin-dashboard-backend',
      version: pkg.version,
      uptime: uptimeSeconds,
      timestamp: new Date().toISOString()
    }
  });
};

module.exports = {
  getHealth
};
