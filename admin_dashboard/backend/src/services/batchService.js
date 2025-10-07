const { batchRepository, transactionRepository } = require('../repositories');

const listBatches = async (filters) => batchRepository.listBatches(filters);

const getBatchById = async (id) => batchRepository.findById(id);

const getBatchStats = async () => batchRepository.getStats();

const getBatchTransactions = async (batchId, options) =>
  transactionRepository.listTransactionsForBatch(batchId, options);

module.exports = {
  listBatches,
  getBatchById,
  getBatchStats,
  getBatchTransactions
};
