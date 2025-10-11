const { User } = require('../models');
const { buildPagination, formatPage } = require('../utils/pagination');

const ROLE_FILTERS = ['farmer', 'distributor', 'retailer', 'consumer', 'administrator'];

const listUsers = async ({
  role,
  status,
  search,
  page,
  limit
}) => {
  const query = {};

  if (role && ROLE_FILTERS.includes(role)) {
    query.role = role;
  }

  if (status === 'verified') {
    query.isVerified = true;
  } else if (status === 'pending') {
    query.isVerified = false;
  }

  if (search) {
    query.$or = [
      { name: new RegExp(search, 'i') },
      { email: new RegExp(search, 'i') },
      { phone: new RegExp(search, 'i') }
    ];
  }

  const { currentPage, perPage, skip } = buildPagination({ page, limit });

  const [items, total] = await Promise.all([
    User.find(query)
      .sort({ createdAt: -1 })
      .skip(skip)
      .limit(perPage),
    User.countDocuments(query)
  ]);

  return formatPage(items, total, { currentPage, perPage });
};

const findById = async (id) => User.findById(id);

const approveUser = async (id, { approvedBy, notes }) => {
  const user = await User.findById(id);
  if (!user) {
    throw new Error('User not found');
  }

  user.isVerified = true;
  user.additionalInfo = {
    ...user.additionalInfo,
    approval: {
      approvedBy,
      notes,
      approvedAt: new Date().toISOString()
    }
  };

  await user.save();
  return user;
};

const getStats = async () => {
  const [roleAggregation, verificationAggregation, totalCount] = await Promise.all([
    User.aggregate([
      { $group: { _id: '$role', count: { $sum: 1 } } }
    ]),
    User.aggregate([
      { $group: { _id: '$isVerified', count: { $sum: 1 } } }
    ]),
    User.countDocuments()
  ]);

  const byRole = roleAggregation.map((entry) => ({
    role: entry._id,
    count: entry.count
  }));

  const verificationMap = verificationAggregation.reduce((acc, entry) => {
    acc[entry._id ? 'verified' : 'pending'] = entry.count;
    return acc;
  }, { verified: 0, pending: 0 });

  return {
    totalUsers: totalCount,
    verifiedUsers: verificationMap.verified || 0,
    pendingApproval: verificationMap.pending || 0,
    byRole
  };
};

const listRecentApprovals = async ({ limit = 10 } = {}) => {
  const safeLimit = Math.min(Math.max(limit, 1), 50);
  return User.find({
    isVerified: true,
    'additionalInfo.approval.approvedAt': { $exists: true }
  })
    .sort({ 'additionalInfo.approval.approvedAt': -1 })
    .limit(safeLimit)
    .select('name email role additionalInfo.approval createdAt');
};

module.exports = {
  listUsers,
  findById,
  approveUser,
  getStats,
  listRecentApprovals
};
