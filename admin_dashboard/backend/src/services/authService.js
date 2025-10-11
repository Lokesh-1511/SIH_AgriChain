const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const config = require('../config/env');
const User = require('../models/user.model');
const { userRepository } = require('../repositories');

const createAuthError = (message, statusCode = 400, code) => {
  const error = new Error(message);
  error.statusCode = statusCode;
  if (code) {
    error.code = code;
  }
  return error;
};

const PASSWORD_POLICY = {
  minLength: 8,
  regex: /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#$%^&*()_+\-=\[\]{};':"\\|,.<>/?]).+$/
};

const ensurePasswordStrength = (password) => {
  if (!password || password.length < PASSWORD_POLICY.minLength || !PASSWORD_POLICY.regex.test(password)) {
    throw createAuthError(
      'Password must be at least 8 characters long and include uppercase, lowercase, number, and special character.',
      400,
      'WEAK_PASSWORD'
    );
  }
};

const generateToken = (user) => {
  const payload = {
    sub: user._id.toString(),
    role: user.role,
    email: user.email
  };

  return jwt.sign(payload, config.jwtSecret, { expiresIn: config.jwtExpiresIn });
};

const register = async (userData) => {
  const existing = await User.findOne({ email: userData.email });
  if (existing) {
    throw createAuthError('Email already in use', 409, 'EMAIL_IN_USE');
  }

  ensurePasswordStrength(userData.password);

  const passwordHash = await bcrypt.hash(userData.password, 10);
  const user = await User.create({ ...userData, passwordHash });
  return {
    user,
    token: generateToken(user)
  };
};

const login = async ({ email, password }, options = {}) => {
  const { requireRole, requireVerified = false } = options;

  const user = await User.findOne({ email });
  if (!user) {
    throw createAuthError('Invalid credentials', 401, 'INVALID_CREDENTIALS');
  }

  const isValid = await bcrypt.compare(password, user.passwordHash);
  if (!isValid) {
    throw createAuthError('Invalid credentials', 401, 'INVALID_CREDENTIALS');
  }

  if (requireRole && user.role !== requireRole) {
    throw createAuthError('User role is not permitted', 403, 'ROLE_NOT_ALLOWED');
  }

  if (requireVerified && !user.isVerified) {
    throw createAuthError('Account is not verified', 403, 'ACCOUNT_NOT_VERIFIED');
  }

  return {
    user,
    token: generateToken(user)
  };
};

const getUserProfile = async (id) => userRepository.findById(id);

module.exports = {
  register,
  login,
  getUserProfile
};
