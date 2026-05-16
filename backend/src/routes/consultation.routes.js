const router = require('express').Router();
const { getAll, getById, create, updateStatus } = require('../controllers/consultation.controller');
const { authMiddleware } = require('../middleware/auth.middleware');

router.get('/', authMiddleware, getAll);
router.get('/:id', authMiddleware, getById);
router.post('/', authMiddleware, create);
router.put('/:id/status', authMiddleware, updateStatus);

module.exports = router;
