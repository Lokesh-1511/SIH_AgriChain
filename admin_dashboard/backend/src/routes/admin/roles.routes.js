const express = require('express');
const roleController = require('../../controllers/admin/roleController');
const auth = require('../../middleware/auth');

const router = express.Router();

router.get('/', auth(['administrator']), roleController.listRoles);
router.get('/:id', auth(['administrator']), roleController.getRole);
router.post('/:id/approve', auth(['administrator']), roleController.approveRole);

module.exports = router;
