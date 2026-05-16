const { pool } = require('../config/db');

async function getAll(req, res) {
  try {
    const { specialty, search, limit = 20, offset = 0 } = req.query;
    let query = `
      SELECT d.*, u.full_name, u.phone, u.email, u.avatar,
             AVG(r.rating) as avg_rating, COUNT(r.id) as review_count
      FROM doctors d
      JOIN users u ON d.user_id = u.id
      LEFT JOIN reviews r ON d.id = r.doctor_id
    `;
    const params = [];
    const conditions = [];
    
    if (specialty) {
      conditions.push(`d.specialty = $${params.length + 1}`);
      params.push(specialty);
    }
    if (search) {
      conditions.push(`(u.full_name ILIKE $${params.length + 1} OR d.specialty ILIKE $${params.length + 1})`);
      params.push(`%${search}%`);
    }
    
    if (conditions.length > 0) {
      query += ' WHERE ' + conditions.join(' AND ');
    }
    
    query += ` GROUP BY d.id, u.id ORDER BY avg_rating DESC NULLS LAST LIMIT $${params.length + 1} OFFSET $${params.length + 2}`;
    params.push(limit, offset);
    
    const result = await pool.query(query, params);
    res.json({ doctors: result.rows, total: result.rowCount });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
}

async function getById(req, res) {
  try {
    const { id } = req.params;
    const result = await pool.query(`
      SELECT d.*, u.full_name, u.phone, u.email, u.avatar,
             AVG(r.rating) as avg_rating, COUNT(r.id) as review_count
      FROM doctors d
      JOIN users u ON d.user_id = u.id
      LEFT JOIN reviews r ON d.id = r.doctor_id
      WHERE d.id = $1
      GROUP BY d.id, u.id
    `, [id]);
    
    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Doctor not found' });
    }
    res.json(result.rows[0]);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
}

async function getSpecialties(req, res) {
  try {
    const result = await pool.query('SELECT DISTINCT specialty FROM doctors ORDER BY specialty');
    res.json(result.rows.map(r => r.specialty));
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
}

async function getSchedule(req, res) {
  try {
    const { id } = req.params;
    const result = await pool.query('SELECT * FROM doctor_schedule WHERE doctor_id = $1 ORDER BY day_of_week, start_time', [id]);
    res.json(result.rows);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
}

async function getReviews(req, res) {
  try {
    const { id } = req.params;
    const result = await pool.query(`
      SELECT r.*, u.full_name, u.avatar 
      FROM reviews r 
      JOIN users u ON r.patient_id = u.id 
      WHERE r.doctor_id = $1 
      ORDER BY r.created_at DESC
    `, [id]);
    res.json(result.rows);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
}

async function addReview(req, res) {
  try {
    const { id } = req.params;
    const { rating, comment } = req.body;
    const result = await pool.query(
      'INSERT INTO reviews (doctor_id, patient_id, rating, comment) VALUES ($1, $2, $3, $4) RETURNING *',
      [id, req.user.id, rating, comment]
    );
    res.status(201).json(result.rows[0]);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
}

module.exports = { getAll, getById, getSpecialties, getSchedule, getReviews, addReview };
