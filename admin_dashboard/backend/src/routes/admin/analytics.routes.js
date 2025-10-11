const express = require('express');
const analyticsController = require('../../controllers/admin/analyticsController');
const auth = require('../../middleware/auth');

const router = express.Router();

router.use(auth(['administrator']));

router.get('/overview', analyticsController.getOverview);
router.get('/trends', analyticsController.getTrends);

module.exports = router;
