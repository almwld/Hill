const { pool } = require('../config/db');

async function getAll(req, res) {
  try {
    const result = await pool.query(`
      SELECT p.*, d.full_name as doctor_name
      FROM prescriptions p
      JOIN users d ON p.doctor_id = d.id
      WHERE p.patient_id = $1
      ORDER BY p.created_at DESC
    `, [req.user.id]);
    res.json(result.rows);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
}

async function getById(req, res) {
  try {
    const { id } = req.params;
    const result = await pool.query(`
      SELECT p.*, d.full_name as doctor_name
      FROM prescriptions p
      JOIN users d ON p.doctor_id = d.id
      WHERE p.id = $1 AND p.patient_id = $2
    `, [id, req.user.id]);
    if (result.rows.length === 0) return res.status(404).json({ error: 'Prescription not found' });
    res.json(result.rows[0]);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
}

async function create(req, res) {
  try {
    const { patient_id, medications, notes } = req.body;
    const result = await pool.query(
      `INSERT INTO prescriptions (doctor_id, patient_id, medications, notes) 
       VALUES ($1, $2, $3, $4) RETURNING *`,
      [req.user.id, patient_id, JSON.stringify(medications), notes]
    );
    res.status(201).json(result.rows[0]);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
}

module.exports = { getAll, getById, create };
