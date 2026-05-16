const { pool } = require('../config/db');

async function getAll(req, res) {
  try {
    const result = await pool.query(`
      SELECT * FROM wallet_transactions 
      WHERE user_id = $1 ORDER BY created_at DESC
    `, [req.user.id]);
    res.json(result.rows);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
}

async function getWallet(req, res) {
  try {
    const result = await pool.query(
      'SELECT * FROM wallets WHERE user_id = $1',
      [req.user.id]
    );
    if (result.rows.length === 0) {
      return res.json({ balance: 0, currency: 'YER' });
    }
    res.json(result.rows[0]);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
}

async function addFunds(req, res) {
  try {
    const { amount, payment_method } = req.body;
    const result = await pool.query(
      `INSERT INTO wallet_transactions (user_id, amount, type, payment_method, status) 
       VALUES ($1, $2, 'deposit', $3, 'completed') RETURNING *`,
      [req.user.id, amount, payment_method]
    );
    await pool.query(
      'UPDATE wallets SET balance = balance + $1 WHERE user_id = $2',
      [amount, req.user.id]
    );
    res.status(201).json(result.rows[0]);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
}

async function getPaymentMethods(req, res) {
  try {
    const result = await pool.query(
      'SELECT * FROM payment_methods WHERE user_id = $1',
      [req.user.id]
    );
    res.json(result.rows);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
}

module.exports = { getAll, getWallet, addFunds, getPaymentMethods };
