const authService = require('../../services/authService');
const auditService = require('../../services/auditService');

const sanitizeUser = (user) => {
  if (!user) {
    return null;
  }

  if (typeof user.toJSON === 'function') {
    return user.toJSON();
  }

  const cloned = { ...user };
  delete cloned.passwordHash;
  return cloned;
};

const login = async (req, res, next) => {
  try {
    const { email, password } = req.body ?? {};

    if (!email || !password) {
      return res.status(400).json({ status: 'error', message: 'Email and password are required' });
    }

    const { user, token } = await authService.login(
      { email, password },
      { requireRole: 'administrator', requireVerified: true }
    );

    await auditService.logAction({
      action: 'admin.auth.login',
      actor: {
        id: user.id,
        role: user.role,
        email: user.email,
        name: user.name
      },
      metadata: { userId: user.id },
      message: 'Administrator login successful',
      request: req
    });

    return res.json({
      status: 'success',
      data: {
        token,
        user: sanitizeUser(user)
      }
    });
  } catch (error) {
    await auditService.logAction({
      action: 'admin.auth.login',
      status: 'failure',
      message: error.message,
      metadata: { email: req.body?.email },
      request: req
    });

    if (error.statusCode) {
      return res.status(error.statusCode).json({
        status: 'error',
        message: error.message,
        code: error.code
      });
    }

    return next(error);
  }
};

const profile = async (req, res, next) => {
  try {
    const userId = req.user?.sub;
    if (!userId) {
      return res.status(401).json({ status: 'error', message: 'Authentication required' });
    }

    const admin = await authService.getUserProfile(userId);
    if (!admin || admin.role !== 'administrator') {
      return res.status(404).json({ status: 'error', message: 'Administrator not found' });
    }

    return res.json({
      status: 'success',
      data: sanitizeUser(admin)
    });
  } catch (error) {
    return next(error);
  }
};

module.exports = {
  login,
  profile
};
