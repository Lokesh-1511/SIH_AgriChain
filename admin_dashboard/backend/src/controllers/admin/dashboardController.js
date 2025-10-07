const dashboardService = require('../../services/dashboardService');

const getOverview = async (req, res, next) => {
  try {
    const data = await dashboardService.getOverview();
    return res.json({ status: 'success', data });
  } catch (error) {
    return next(error);
  }
};

const getActivity = async (req, res, next) => {
  try {
    const limit = req.query.limit ? parseInt(req.query.limit, 10) : undefined;
    const data = await dashboardService.getRecentActivity({ limit });
    return res.json({ status: 'success', data });
  } catch (error) {
    return next(error);
  }
};

module.exports = {
  getOverview,
  getActivity
};
