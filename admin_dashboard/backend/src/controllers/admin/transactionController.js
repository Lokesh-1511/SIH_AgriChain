const transactionService = require('../../services/transactionService');

const parsePositiveInt = (value, fallback) => {
  const parsed = parseInt(value, 10);
  if (Number.isNaN(parsed) || parsed <= 0) {
    return fallback;
  }
  return parsed;
};

const listTransactions = async (req, res, next) => {
  try {
    const { batchId, type, status, search } = req.query;
    const page = parsePositiveInt(req.query.page, 1);
    const limit = parsePositiveInt(req.query.limit, 20);

    const result = await transactionService.listTransactions({
      batchId,
      type,
      status,
      search,
      page,
      limit
    });

    return res.json({ status: 'success', ...result });
  } catch (error) {
    return next(error);
  }
};

const getTransactionStats = async (req, res, next) => {
  try {
    const stats = await transactionService.getTransactionStats();
    return res.json({ status: 'success', data: stats });
  } catch (error) {
    return next(error);
  }
};

module.exports = {
  listTransactions,
  getTransactionStats
};
