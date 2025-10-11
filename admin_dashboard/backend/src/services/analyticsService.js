const { userRepository, batchRepository, transactionRepository } = require('../repositories');
const { Batch, Transaction } = require('../models');

const INTERVAL_CONFIG = {
  daily: { format: '%Y-%m-%d', subtractDays: 30, granularity: 'day' },
  weekly: { format: '%G-%V', subtractDays: 26 * 7, granularity: 'week' },
  monthly: { format: '%Y-%m', subtractDays: 12 * 30, granularity: 'month' }
};

const resolveInterval = (interval = 'daily') => {
  const normalized = interval?.toLowerCase();
  if (INTERVAL_CONFIG[normalized]) {
    return normalized;
  }
  return 'daily';
};

const buildDateRange = (intervalKey) => {
  const config = INTERVAL_CONFIG[intervalKey];
  const to = new Date();
  const from = new Date(to.getTime() - config.subtractDays * 24 * 60 * 60 * 1000);
  return { from, to, format: config.format };
};

const getOverview = async () => {
  const [users, batches, transactions] = await Promise.all([
    userRepository.getStats(),
    batchRepository.getStats(),
    transactionRepository.getStats()
  ]);

  return {
    users,
    batches,
    transactions,
    summary: {
      totalUsers: users.totalUsers,
      verifiedUsers: users.verifiedUsers,
      pendingApprovals: users.pendingApproval,
      totalBatches: batches.totalBatches,
      totalQuantity: batches.totals?.quantity || 0,
      totalBaseValue: batches.totals?.baseValue || 0,
      totalCurrentValue: batches.totals?.currentValue || 0,
      totalTransactions: transactions.totalTransactions,
      totalTransactionAmount: transactions.totalAmount
    }
  };
};

const aggregateByPeriod = async ({
  model,
  dateField,
  from,
  format,
  accumulator
}) => {
  return model.aggregate([
    { $match: { [dateField]: { $gte: from } } },
    {
      $group: {
        _id: {
          period: {
            $dateToString: {
              format,
              date: `$${dateField}`
            }
          }
        },
        ...accumulator
      }
    },
    { $sort: { '_id.period': 1 } }
  ]);
};

const mergeSeries = (seriesList) => {
  const map = new Map();

  seriesList.forEach(({ key, data, fields }) => {
    data.forEach((entry) => {
      const period = entry._id?.period;
      if (!period) return;
      if (!map.has(period)) {
        map.set(period, { period });
      }
      const bucket = map.get(period);
      fields.forEach((field) => {
        bucket[field.alias] = entry[field.source] || 0;
      });
    });
  });

  return Array.from(map.values()).sort((a, b) => (a.period < b.period ? -1 : 1));
};

const getTrends = async ({ interval }) => {
  const resolvedInterval = resolveInterval(interval);
  const { from, to, format } = buildDateRange(resolvedInterval);

  const [batchSeries, transactionSeries] = await Promise.all([
    aggregateByPeriod({
      model: Batch,
      dateField: 'createdAt',
      from,
      format,
      accumulator: {
        batches: { $sum: 1 },
        pending: {
          $sum: {
            $cond: [{ $eq: ['$status', 'pending'] }, 1, 0]
          }
        }
      }
    }),
    aggregateByPeriod({
      model: Transaction,
      dateField: 'occurredAt',
      from,
      format,
      accumulator: {
        transactions: { $sum: 1 },
        amount: { $sum: { $ifNull: ['$amount', 0] } }
      }
    })
  ]);

  const points = mergeSeries([
    {
      key: 'batches',
      data: batchSeries,
      fields: [
        { source: 'batches', alias: 'batchesCreated' },
        { source: 'pending', alias: 'pendingBatches' }
      ]
    },
    {
      key: 'transactions',
      data: transactionSeries,
      fields: [
        { source: 'transactions', alias: 'transactionsProcessed' },
        { source: 'amount', alias: 'transactionAmount' }
      ]
    }
  ]);

  return {
    interval: resolvedInterval,
    range: {
      from: from.toISOString(),
      to: to.toISOString()
    },
    points
  };
};

module.exports = {
  getOverview,
  getTrends
};
