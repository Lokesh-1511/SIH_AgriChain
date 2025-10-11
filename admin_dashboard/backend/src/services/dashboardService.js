const { userRepository, batchRepository, transactionRepository } = require('../repositories');

const getOverview = async () => {
  const [userStats, batchStats, transactionStats] = await Promise.all([
    userRepository.getStats(),
    batchRepository.getStats(),
    transactionRepository.getStats()
  ]);

  return {
    users: userStats,
    batches: batchStats,
    transactions: transactionStats
  };
};

const getRecentActivity = async ({ limit = 10 } = {}) => {
  const [approvals, transactions] = await Promise.all([
    userRepository.listRecentApprovals({ limit }),
    transactionRepository.listRecentTransactions({ limit })
  ]);

  return {
    approvals,
    transactions
  };
};

module.exports = {
  getOverview,
  getRecentActivity
};
