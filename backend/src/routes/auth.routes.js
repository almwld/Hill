const router = require('express').Router();
const { register, login, loginWithPhone, getProfile, updateProfile } = require('../controllers/auth.controller');
const { authMiddleware } = require('../middleware/auth.middleware');

router.post('/register', register);
router.post('/login', login);
router.post('/login-phone', loginWithPhone);
router.get('/profile', authMiddleware, getProfile);
router.put('/profile', authMiddleware, updateProfile);

module.exports = router;
