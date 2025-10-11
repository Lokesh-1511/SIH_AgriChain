const roleService = require('../../services/roleService');
const auditService = require('../../services/auditService');

const listRoles = async (req, res, next) => {
  try {
    const { role, status, search, page, limit } = req.query;
    const result = await roleService.listRoles({ role, status, search, page, limit });
    res.json({ status: 'success', ...result });
  } catch (error) {
    next(error);
  }
};

const getRole = async (req, res, next) => {
  try {
    const { id } = req.params;
    const role = await roleService.getRole(id);
    if (!role) {
      return res.status(404).json({ status: 'error', message: 'Role not found' });
    }
    res.json({ status: 'success', data: role });
  } catch (error) {
    next(error);
  }
};

const approveRole = async (req, res, next) => {
  try {
    const { id } = req.params;
    const { notes } = req.body;
    const approvedBy = req.user?.sub || 'system';
    const updated = await roleService.approveRole(id, { approvedBy, notes });
    await auditService.logAction({
      action: 'admin.role.approve',
      actor: {
        id: req.user?.sub,
        role: req.user?.role,
        email: req.user?.email,
        name: req.user?.name
      },
      target: {
        id: updated.id,
        type: updated.role,
        name: updated.name
      },
      metadata: { notes },
      request: req,
      message: `Approved ${updated.role} ${updated.email}`
    });
    res.json({ status: 'success', data: updated });
  } catch (error) {
    if (error.message === 'User not found') {
      await auditService.logAction({
        action: 'admin.role.approve',
        status: 'failure',
        message: error.message,
        actor: {
          id: req.user?.sub,
          role: req.user?.role,
          email: req.user?.email
        },
        target: { id: req.params.id, type: 'user' },
        metadata: { notes: req.body?.notes },
        request: req
      });
      return res.status(404).json({ status: 'error', message: error.message });
    }
    next(error);
  }
};

module.exports = {
  listRoles,
  getRole,
  approveRole
};
