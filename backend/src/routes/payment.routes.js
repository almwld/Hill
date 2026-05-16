const router = require('express').Router();
const { authMiddleware } = require('../middleware/auth.middleware');
const { getAll, getWallet, addFunds, getPaymentMethods } = require('../controllers/payment.controller');

router.get('/', authMiddleware, getAll);
router.get('/wallet', authMiddleware, getWallet);
router.post('/wallet/add', authMiddleware, addFunds);
router.get('/methods', authMiddleware, getPaymentMethods);

module.exports = router;
