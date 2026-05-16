const { pool } = require('../config/db');

async function getAll(req, res) {
  try {
    const result = await pool.query(`
      SELECT o.*, p.pharmacy_name, u.full_name as patient_name
      FROM orders o
      JOIN pharmacies p ON o.pharmacy_id = p.id
      JOIN users u ON o.patient_id = u.id
      WHERE o.patient_id = $1
      ORDER BY o.created_at DESC
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
      SELECT o.*, p.pharmacy_name, u.full_name as patient_name
      FROM orders o
      JOIN pharmacies p ON o.pharmacy_id = p.id
      JOIN users u ON o.patient_id = u.id
      WHERE o.id = $1 AND o.patient_id = $2
    `, [id, req.user.id]);
    if (result.rows.length === 0) return res.status(404).json({ error: 'Order not found' });
    res.json(result.rows[0]);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
}

async function create(req, res) {
  try {
    const { pharmacy_id, items, total_amount, delivery_address } = req.body;
    const result = await pool.query(
      `INSERT INTO orders (patient_id, pharmacy_id, items, total_amount, delivery_address, status) 
       VALUES ($1, $2, $3, $4, $5, 'pending') RETURNING *`,
      [req.user.id, pharmacy_id, JSON.stringify(items), total_amount, delivery_address]
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
      'UPDATE orders SET status = $1 WHERE id = $2 RETURNING *',
      [status, id]
    );
    res.json(result.rows[0]);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
}

module.exports = { getAll, getById, create, updateStatus };
