const { Batch } = require('../models');
const { buildPagination, formatPage } = require('../utils/pagination');

const STATUS_FILTERS = ['pending', 'in_transit', 'delivered', 'sold', 'transported'];

const listBatches = async ({ status, farmerId, search, page, limit }) => {
  const query = {};

  if (status && STATUS_FILTERS.includes(status)) {
    query.status = status;
  }

  if (farmerId) {
    query.farmerId = farmerId;
  }

  if (search) {
    query.$or = [
      { productName: new RegExp(search, 'i') },
      { batchCode: new RegExp(search, 'i') }
    ];
  }

  const { currentPage, perPage, skip } = buildPagination({ page, limit });

  const [items, total] = await Promise.all([
    Batch.find(query)
      .sort({ createdAt: -1 })
      .skip(skip)
      .limit(perPage)
      .populate('farmerId', 'name email role')
      .populate('distributorId', 'name role')
      .populate('retailerId', 'name role'),
    Batch.countDocuments(query)
  ]);

  return formatPage(items, total, { currentPage, perPage });
};

const findById = async (id) => Batch.findById(id)
  .populate('farmerId')
  .populate('distributorId')
  .populate('retailerId');

  const getStats = async () => {
    const [statusAggregation, totalCount, totalQuantity] = await Promise.all([
      Batch.aggregate([
        {
          $group: {
            _id: '$status',
            count: { $sum: 1 },
            totalQuantity: { $sum: '$quantity' }
          }
        }
      ]),
      Batch.countDocuments(),
      Batch.aggregate([
        {
          $group: {
            _id: null,
            quantity: { $sum: '$quantity' },
            baseValue: { $sum: { $multiply: ['$quantity', '$basePrice'] } },
            currentValue: { $sum: { $ifNull: [{ $multiply: ['$quantity', '$currentPrice'] }, 0] } }
          }
        }
      ])
    ]);

    const totals = totalQuantity[0] || { quantity: 0, baseValue: 0, currentValue: 0 };

    return {
      totalBatches: totalCount,
      totals: {
        quantity: totals.quantity,
        baseValue: totals.baseValue,
        currentValue: totals.currentValue
      },
      byStatus: statusAggregation.map((entry) => ({
        status: entry._id,
        count: entry.count,
        totalQuantity: entry.totalQuantity
      }))
    };
  };

module.exports = {
  listBatches,
    findById,
    getStats
};
