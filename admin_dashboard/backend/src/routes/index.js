const express = require('express');
const healthRoutes = require('./health.routes');
const adminAuthRoutes = require('./admin/auth.routes');
const adminRoleRoutes = require('./admin/roles.routes');
const adminBatchRoutes = require('./admin/batches.routes');
const adminTransactionRoutes = require('./admin/transactions.routes');
const adminDashboardRoutes = require('./admin/dashboard.routes');
const adminAnalyticsRoutes = require('./admin/analytics.routes');

const router = express.Router();

router.use('/health', healthRoutes);
router.use('/admin/auth', adminAuthRoutes);
router.use('/admin/roles', adminRoleRoutes);
router.use('/admin/batches', adminBatchRoutes);
router.use('/admin/transactions', adminTransactionRoutes);
router.use('/admin/dashboard', adminDashboardRoutes);
router.use('/admin/analytics', adminAnalyticsRoutes);

module.exports = router;
