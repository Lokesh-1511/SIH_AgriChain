const mongoose = require('mongoose');
const { Transaction } = require('../models');
const { buildPagination, formatPage } = require('../utils/pagination');

const listTransactions = async ({ batchId, type, status, search, page, limit }) => {
  const query = {};

  if (batchId) {
    query.batchId = batchId;
  }

  if (type) {
    query.transactionType = type;
  }

  if (status) {
    query.status = status;
  }

  if (search) {
    query.$or = [
      { transactionCode: new RegExp(search, 'i') },
      { blockchainHash: new RegExp(search, 'i') }
    ];
  }

  const { currentPage, perPage, skip } = buildPagination({ page, limit });

  const [items, total] = await Promise.all([
    Transaction.find(query)
      .sort({ occurredAt: -1 })
      .skip(skip)
      .limit(perPage)
      .populate('batchId', 'batchCode productName')
      .populate('fromUserId', 'name role')
      .populate('toUserId', 'name role'),
    Transaction.countDocuments(query)
  ]);

  return formatPage(items, total, { currentPage, perPage });
};

  const listTransactionsForBatch = async (batchId, { limit = 50 } = {}) => {
    if (!mongoose.Types.ObjectId.isValid(batchId)) {
      return [];
    }

    return Transaction.find({ batchId })
      .sort({ occurredAt: -1 })
      .limit(Math.min(Math.max(limit, 1), 200))
      .populate('fromUserId', 'name role')
      .populate('toUserId', 'name role');
  };

  const getStats = async () => {
    const [statusAggregation, typeAggregation, totalCount, totalAmount] = await Promise.all([
      Transaction.aggregate([
        { $group: { _id: '$status', count: { $sum: 1 }, amount: { $sum: { $ifNull: ['$amount', 0] } } } }
      ]),
      Transaction.aggregate([
        { $group: { _id: '$transactionType', count: { $sum: 1 }, amount: { $sum: { $ifNull: ['$amount', 0] } } } }
      ]),
      Transaction.countDocuments(),
      Transaction.aggregate([
        { $group: { _id: null, total: { $sum: { $ifNull: ['$amount', 0] } } } }
      ])
    ]);

    return {
      totalTransactions: totalCount,
      totalAmount: (totalAmount[0] && totalAmount[0].total) || 0,
      byStatus: statusAggregation.map((entry) => ({
        status: entry._id,
        count: entry.count,
        amount: entry.amount
      })),
      byType: typeAggregation.map((entry) => ({
        type: entry._id,
        count: entry.count,
        amount: entry.amount
      }))
    };
  };

  const listRecentTransactions = async ({ limit = 10 } = {}) => {
    const safeLimit = Math.min(Math.max(limit, 1), 50);
    return Transaction.find({})
      .sort({ occurredAt: -1 })
      .limit(safeLimit)
      .populate('batchId', 'batchCode productName status')
      .populate('fromUserId', 'name role')
      .populate('toUserId', 'name role');
  };

module.exports = {
    listTransactions,
    listTransactionsForBatch,
    getStats,
    listRecentTransactions
};
