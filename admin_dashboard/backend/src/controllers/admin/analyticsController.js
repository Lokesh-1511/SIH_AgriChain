const analyticsService = require('../../services/analyticsService');

const getOverview = async (req, res, next) => {
  try {
    const data = await analyticsService.getOverview();
    res.json({ status: 'success', data });
  } catch (error) {
    next(error);
  }
};

const getTrends = async (req, res, next) => {
  try {
    const interval = req.query.interval;
    const data = await analyticsService.getTrends({ interval });
    res.json({ status: 'success', data });
  } catch (error) {
    next(error);
  }
};

module.exports = {
  getOverview,
  getTrends
};
