const { pool } = require('../config/db');

async function getAll(req, res) {
  try {
    const patientId = req.user?.id;
    let query = `
      SELECT c.*, 
             u1.full_name as patient_name, u1.avatar as patient_avatar,
             u2.full_name as doctor_name, u2.avatar as doctor_avatar,
             d.specialty
      FROM consultations c
      JOIN users u1 ON c.patient_id = u1.id
      JOIN doctors d ON c.doctor_id = d.id
      JOIN users u2 ON d.user_id = u2.id
    `;
    const params = [];
    
    if (patientId) {
      query += ' WHERE c.patient_id = $1';
      params.push(patientId);
    }
    
    query += ' ORDER BY c.created_at DESC';
    const result = await pool.query(query, params);
    res.json(result.rows);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
}

async function getById(req, res) {
  try {
    const { id } = req.params;
    const result = await pool.query(`
      SELECT c.*,
             u1.full_name as patient_name, u1.avatar as patient_avatar,
             u2.full_name as doctor_name, u2.avatar as doctor_avatar,
             d.specialty
      FROM consultations c
      JOIN users u1 ON c.patient_id = u1.id
      JOIN doctors d ON c.doctor_id = d.id
      JOIN users u2 ON d.user_id = u2.id
      WHERE c.id = $1
    `, [id]);
    
    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Consultation not found' });
    }
    res.json(result.rows[0]);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
}

async function create(req, res) {
  try {
    const { doctor_id, symptoms, type = 'text' } = req.body;
    const patient_id = req.user.id;
    
    const result = await pool.query(
      `INSERT INTO consultations (patient_id, doctor_id, symptoms, type, status) 
       VALUES ($1, $2, $3, $4, 'pending') RETURNING *`,
      [patient_id, doctor_id, symptoms, type]
    );
    res.status(201).json(result.rows[0]);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
}

async function updateStatus(req, res) {
  try {
    const { id } = req.params;
    const { status } = req.body;
    const result = await pool.query(
      'UPDATE consultations SET status = $1 WHERE id = $2 RETURNING *',
      [status, id]
    );
    res.json(result.rows[0]);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
}

module.exports = { getAll, getById, create, updateStatus };
