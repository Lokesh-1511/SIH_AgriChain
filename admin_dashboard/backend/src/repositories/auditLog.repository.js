const { AuditLog } = require('../models');

const create = async (payload) => AuditLog.create(payload);

module.exports = {
  create
};
