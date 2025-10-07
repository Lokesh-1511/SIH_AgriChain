const express = require('express');
const dashboardController = require('../../controllers/admin/dashboardController');
const auth = require('../../middleware/auth');

const router = express.Router();

router.use(auth(['administrator']));

router.get('/overview', dashboardController.getOverview);
router.get('/activity', dashboardController.getActivity);

module.exports = router;
