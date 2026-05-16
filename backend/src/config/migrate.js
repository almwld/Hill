const fs = require('fs');
const path = require('path');
const { pool } = require('./db');

async function migrate() {
  const schemaPath = path.join(__dirname, '../../migrations/schema.sql');
  
  if (!fs.existsSync(schemaPath)) {
    console.error('Schema file not found:', schemaPath);
    process.exit(1);
  }
  
  const schema = fs.readFileSync(schemaPath, 'utf8');

  try {
    // Split and execute each statement separately
    const statements = schema.split(';').filter(s => s.trim().length > 0);
    for (const statement of statements) {
      try {
        await pool.query(statement + ';');
      } catch (err) {
        // Ignore "already exists" errors
        if (!err.message.includes('already exists')) {
          console.warn('Warning:', err.message);
        }
      }
    }
    console.log('✅ Migration completed successfully');
  } catch (err) {
    console.error('❌ Migration failed:', err);
  } finally {
    pool.end();
  }
}

migrate();
