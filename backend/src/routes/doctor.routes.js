const router = require('express').Router();
const { getAll, getById, getSpecialties, getSchedule, getReviews, addReview } = require('../controllers/doctor.controller');
const { authMiddleware } = require('../middleware/auth.middleware');

router.get('/', getAll);
router.get('/specialties', getSpecialties);
router.get('/:id', getById);
router.get('/:id/schedule', getSchedule);
router.get('/:id/reviews', getReviews);
router.post('/:id/reviews', authMiddleware, addReview);

module.exports = router;
