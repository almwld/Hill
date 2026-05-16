const { pool } = require('../config/db');

async function getAll(req, res) {
  try {
    const result = await pool.query(
      'SELECT * FROM notifications WHERE user_id = $1 ORDER BY created_at DESC',
      [req.user.id]
    );
    res.json(result.rows);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
}

async function markAsRead(req, res) {
  try {
    const { id } = req.params;
    await pool.query(
      'UPDATE notifications SET is_read = true WHERE id = $1 AND user_id = $2',
      [id, req.user.id]
    );
    res.json({ message: 'Notification marked as read' });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
}

async function markAllAsRead(req, res) {
  try {
    await pool.query(
      'UPDATE notifications SET is_read = true WHERE user_id = $1',
      [req.user.id]
    );
    res.json({ message: 'All notifications marked as read' });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
}

async function deleteNotification(req, res) {
  try {
    const { id } = req.params;
    await pool.query(
      'DELETE FROM notifications WHERE id = $1 AND user_id = $2',
      [id, req.user.id]
    );
    res.json({ message: 'Notification deleted' });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
}

module.exports = { getAll, markAsRead, markAllAsRead, deleteNotification };
