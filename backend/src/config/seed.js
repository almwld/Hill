const { pool } = require('./db');
const bcrypt = require('bcryptjs');

async function seed() {
  try {
    // Create default admin
    const adminPass = await bcrypt.hash('admin123', 12);
    await pool.query(`
      INSERT INTO users (full_name, email, phone, password_hash, user_type, role) 
      VALUES ('مدير النظام', 'admin@sehatak.com', '+967777000000', $1, 'admin', 'admin')
      ON CONFLICT (phone) DO NOTHING
    `, [adminPass]);

    // Create sample doctors
    const docPass = await bcrypt.hash('doctor123', 12);
    
    const doctors = [
      { name: 'د. علي المولد', email: 'ali.m@sehatak.com', phone: '+967777123456', specialty: 'باطنية', sub: 'أطفال', exp: 20, fee: 500, hospital: 'مستشفى الثورة' },
      { name: 'د. حسن رضا', email: 'hassan@sehatak.com', phone: '+967777123457', specialty: 'طب عام', sub: 'عام', exp: 8, fee: 300, hospital: 'مستشفى الجمهوري' },
      { name: 'د. عائشة ملك', email: 'aisha@sehatak.com', phone: '+967777123458', specialty: 'جلدية', sub: 'تجميل', exp: 6, fee: 400, hospital: 'مستشفى السلام' },
      { name: 'د. محمد صالح', email: 'mohamed@sehatak.com', phone: '+967777123459', specialty: 'جراحة', sub: 'عظام', exp: 15, fee: 600, hospital: 'مستشفى الثورة' },
      { name: 'د. فاطمة أحمد', email: 'fatima@sehatak.com', phone: '+967777123460', specialty: 'نساء وتوليد', sub: 'توليد', exp: 12, fee: 450, hospital: 'مستشفى السلام' }
    ];

    for (const doc of doctors) {
      const userResult = await pool.query(`
        INSERT INTO users (full_name, email, phone, password_hash, user_type, role)
        VALUES ($1, $2, $3, $4, 'doctor', 'doctor')
        ON CONFLICT (phone) DO UPDATE SET full_name = $1
        RETURNING id
      `, [doc.name, doc.email, doc.phone, docPass]);
      
      const userId = userResult.rows[0].id;
      
      await pool.query(`
        INSERT INTO doctors (user_id, specialty, sub_specialty, qualification, experience_years, consultation_fee, hospital, bio, is_available)
        VALUES ($1, $2, $3, 'بكالوريوس طب والبورد العربي', $4, $5, $6, $7, true)
        ON CONFLICT DO NOTHING
      `, [userId, doc.specialty, doc.sub, doc.exp, doc.fee, doc.hospital, `استشاري ${doc.specialty} - خبرة ${doc.exp} سنة`]);
    }

    // Seed emergency numbers
    await pool.query(`
      INSERT INTO emergency_numbers (name, number, category) VALUES
      ('الإسعاف', '191', 'medical'),
      ('الشرطة', '194', 'police'),
      ('الدفاع المدني', '191', 'fire'),
      ('طوارئ الكهرباء', '177', 'utilities'),
      ('طوارئ الماء', '175', 'utilities')
      ON CONFLICT DO NOTHING
    `);

    console.log('✅ Database seeded successfully');
    process.exit(0);
  } catch (error) {
    console.error('❌ Seed failed:', error);
    process.exit(1);
  }
}

seed();
