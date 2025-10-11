const batchService = require('../../services/batchService');

const parsePositiveInt = (value, fallback) => {
  const parsed = parseInt(value, 10);
  if (Number.isNaN(parsed) || parsed <= 0) {
    return fallback;
  }
  return parsed;
};

const listBatches = async (req, res, next) => {
  try {
    const { status, farmerId, search } = req.query;
    const page = parsePositiveInt(req.query.page, 1);
    const limit = parsePositiveInt(req.query.limit, 20);

    const result = await batchService.listBatches({
      status,
      farmerId,
      search,
      page,
      limit
    });

    return res.json({ status: 'success', ...result });
  } catch (error) {
    return next(error);
  }
};

const getBatch = async (req, res, next) => {
  try {
    const batch = await batchService.getBatchById(req.params.id);
    if (!batch) {
      return res.status(404).json({ status: 'error', message: 'Batch not found' });
    }

    return res.json({ status: 'success', data: batch });
  } catch (error) {
    return next(error);
  }
};

const getBatchStats = async (req, res, next) => {
  try {
    const stats = await batchService.getBatchStats();
    return res.json({ status: 'success', data: stats });
  } catch (error) {
    return next(error);
  }
};

const getBatchTransactions = async (req, res, next) => {
  try {
    const limit = parsePositiveInt(req.query.limit, 50);
    const transactions = await batchService.getBatchTransactions(req.params.id, { limit });
    return res.json({ status: 'success', data: transactions });
  } catch (error) {
    return next(error);
  }
};

module.exports = {
  listBatches,
  getBatch,
  getBatchStats,
  getBatchTransactions
};
