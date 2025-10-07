const { auditLogRepository } = require('../repositories');

const buildActor = (actor = {}) => {
  if (!actor) return undefined;
  const { id, sub, role, email, name } = actor;
  return {
    id: id || sub || undefined,
    role,
    email,
    name
  };
};

const buildTarget = (target = {}) => {
  if (!target) return undefined;
  const { id, type, name } = target;
  return {
    id,
    type,
    name
  };
};

const logAction = async ({
  action,
  status = 'success',
  message,
  actor,
  target,
  metadata,
  request
}) => {
  try {
    await auditLogRepository.create({
      action,
      status,
      message,
      actor: buildActor(actor),
      target: buildTarget(target),
      metadata,
      ip: request?.ip,
      userAgent: request?.headers?.['user-agent'],
      correlationId: request?.context?.correlationId
    });
  } catch (error) {
    // Failing to log should not break the main flow; swallow but emit debug
    const logger = require('../utils/logger');
    logger.warn('Failed to persist audit log', {
      error: error.message,
      action,
      correlationId: request?.context?.correlationId
    });
  }
};

module.exports = {
  logAction
};
