const express = require('express');
const authController = require('../../controllers/admin/authController');
const authMiddleware = require('../../middleware/auth');
const loginRateLimiter = require('../../middleware/loginRateLimiter');

const router = express.Router();

router.post('/login', loginRateLimiter, authController.login);
router.get('/me', authMiddleware(['administrator']), authController.profile);

module.exports = router;
