const router = require('express').Router();
const { authMiddleware } = require('../middleware/auth.middleware');
const { getAll, getById, create, updateStatus } = require('../controllers/order.controller');

router.get('/', authMiddleware, getAll);
router.get('/:id', authMiddleware, getById);
router.post('/', authMiddleware, create);
router.put('/:id/status', authMiddleware, updateStatus);

module.exports = router;
