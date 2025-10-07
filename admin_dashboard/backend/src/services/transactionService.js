const { transactionRepository } = require('../repositories');

const listTransactions = async (filters) => transactionRepository.listTransactions(filters);

const getTransactionStats = async () => transactionRepository.getStats();

module.exports = {
  listTransactions,
  getTransactionStats
};
