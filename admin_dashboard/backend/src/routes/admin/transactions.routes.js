const express = require('express');
const transactionController = require('../../controllers/admin/transactionController');
const auth = require('../../middleware/auth');

const router = express.Router();

router.use(auth(['administrator']));

router.get('/stats', transactionController.getTransactionStats);
router.get('/', transactionController.listTransactions);

module.exports = router;
