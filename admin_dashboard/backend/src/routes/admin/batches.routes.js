const express = require('express');
const batchController = require('../../controllers/admin/batchController');
const auth = require('../../middleware/auth');

const router = express.Router();

router.use(auth(['administrator']));

router.get('/stats', batchController.getBatchStats);
router.get('/:id/transactions', batchController.getBatchTransactions);
router.get('/:id', batchController.getBatch);
router.get('/', batchController.listBatches);

module.exports = router;
