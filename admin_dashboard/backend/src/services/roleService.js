const { userRepository } = require('../repositories');

const listRoles = async (filters) => {
  return userRepository.listUsers(filters);
};

const approveRole = async (userId, payload) => {
  return userRepository.approveUser(userId, payload);
};

const getRole = async (userId) => {
  return userRepository.findById(userId);
};

module.exports = {
  listRoles,
  approveRole,
  getRole
};
