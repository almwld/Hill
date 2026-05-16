const router = require('express').Router();
const { authMiddleware } = require('../middleware/auth.middleware');
const { getAll, getById, create } = require('../controllers/prescription.controller');

router.get('/', authMiddleware, getAll);
router.get('/:id', authMiddleware, getById);
router.post('/', authMiddleware, create);

module.exports = router;
