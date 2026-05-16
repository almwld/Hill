const router = require('express').Router();
const { authMiddleware } = require('../middleware/auth.middleware');
const { getAll, markAsRead, markAllAsRead, deleteNotification } = require('../controllers/notification.controller');

router.get('/', authMiddleware, getAll);
router.put('/:id/read', authMiddleware, markAsRead);
router.put('/read-all', authMiddleware, markAllAsRead);
router.delete('/:id', authMiddleware, deleteNotification);

module.exports = router;
