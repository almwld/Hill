-- ==========================================
-- صحتك - Sehatak Database Schema
-- ==========================================

-- Users Table
CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    full_name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE,
    phone VARCHAR(20) UNIQUE NOT NULL,
    password_hash VARCHAR(255),
    avatar TEXT,
    user_type VARCHAR(50) DEFAULT 'patient',
    role VARCHAR(50) DEFAULT 'patient',
    is_verified BOOLEAN DEFAULT false,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Doctors Table
CREATE TABLE IF NOT EXISTS doctors (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    specialty VARCHAR(255) NOT NULL,
    sub_specialty VARCHAR(255),
    qualification TEXT,
    experience_years INTEGER,
    consultation_fee DECIMAL(10, 2) DEFAULT 0,
    hospital VARCHAR(255),
    bio TEXT,
    is_available BOOLEAN DEFAULT true,
    rating DECIMAL(3, 2) DEFAULT 0,
    review_count INTEGER DEFAULT 0,
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Doctor Schedule
CREATE TABLE IF NOT EXISTS doctor_schedule (
    id SERIAL PRIMARY KEY,
    doctor_id INTEGER REFERENCES doctors(id) ON DELETE CASCADE,
    day_of_week INTEGER NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    is_available BOOLEAN DEFAULT true
);

-- Reviews Table
CREATE TABLE IF NOT EXISTS reviews (
    id SERIAL PRIMARY KEY,
    doctor_id INTEGER REFERENCES doctors(id) ON DELETE CASCADE,
    patient_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    rating DECIMAL(3, 2) NOT NULL CHECK (rating >= 0 AND rating <= 5),
    comment TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Consultations Table
CREATE TABLE IF NOT EXISTS consultations (
    id SERIAL PRIMARY KEY,
    patient_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    doctor_id INTEGER REFERENCES doctors(id) ON DELETE CASCADE,
    symptoms TEXT,
    type VARCHAR(50) DEFAULT 'text',
    status VARCHAR(50) DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Messages Table
CREATE TABLE IF NOT EXISTS messages (
    id SERIAL PRIMARY KEY,
    consultation_id INTEGER REFERENCES consultations(id) ON DELETE CASCADE,
    sender_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    content TEXT NOT NULL,
    is_read BOOLEAN DEFAULT false,
    sent_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Appointments Table
CREATE TABLE IF NOT EXISTS appointments (
    id SERIAL PRIMARY KEY,
    patient_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    doctor_id INTEGER REFERENCES doctors(id) ON DELETE CASCADE,
    appointment_date DATE NOT NULL,
    appointment_time TIME NOT NULL,
    status VARCHAR(50) DEFAULT 'pending',
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Pharmacies Table
CREATE TABLE IF NOT EXISTS pharmacies (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    pharmacy_name VARCHAR(255) NOT NULL,
    license_number VARCHAR(255),
    address TEXT,
    address_lat DECIMAL(10, 8),
    address_lng DECIMAL(11, 8),
    delivery_range_km DECIMAL(5, 2) DEFAULT 10,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Products Table
CREATE TABLE IF NOT EXISTS products (
    id SERIAL PRIMARY KEY,
    pharmacy_id INTEGER REFERENCES pharmacies(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    category VARCHAR(255),
    price DECIMAL(10, 2) NOT NULL,
    stock INTEGER DEFAULT 0,
    image_url TEXT,
    requires_prescription BOOLEAN DEFAULT false,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Orders Table
CREATE TABLE IF NOT EXISTS orders (
    id SERIAL PRIMARY KEY,
    patient_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    pharmacy_id INTEGER REFERENCES pharmacies(id),
    items JSONB NOT NULL DEFAULT '[]',
    total_amount DECIMAL(10, 2) NOT NULL,
    delivery_address TEXT,
    status VARCHAR(50) DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Prescriptions Table
CREATE TABLE IF NOT EXISTS prescriptions (
    id SERIAL PRIMARY KEY,
    doctor_id INTEGER REFERENCES users(id),
    patient_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    medications JSONB NOT NULL DEFAULT '[]',
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Wallets Table
CREATE TABLE IF NOT EXISTS wallets (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    balance DECIMAL(10, 2) DEFAULT 0,
    currency VARCHAR(10) DEFAULT 'YER',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Wallet Transactions
CREATE TABLE IF NOT EXISTS wallet_transactions (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    amount DECIMAL(10, 2) NOT NULL,
    type VARCHAR(50) NOT NULL,
    payment_method VARCHAR(100),
    status VARCHAR(50) DEFAULT 'completed',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Payment Methods
CREATE TABLE IF NOT EXISTS payment_methods (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    type VARCHAR(100) NOT NULL,
    details JSONB DEFAULT '{}',
    is_default BOOLEAN DEFAULT false,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Notifications Table
CREATE TABLE IF NOT EXISTS notifications (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    type VARCHAR(100) DEFAULT 'general',
    is_read BOOLEAN DEFAULT false,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Health Metrics Table
CREATE TABLE IF NOT EXISTS health_metrics (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    metric_type VARCHAR(100) NOT NULL,
    value DECIMAL(10, 2) NOT NULL,
    unit VARCHAR(50),
    notes TEXT,
    recorded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Labs Table
CREATE TABLE IF NOT EXISTS labs (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    lab_name VARCHAR(255) NOT NULL,
    license_number VARCHAR(255),
    address TEXT,
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Lab Tests
CREATE TABLE IF NOT EXISTS lab_tests (
    id SERIAL PRIMARY KEY,
    lab_id INTEGER REFERENCES labs(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    price DECIMAL(10, 2) NOT NULL,
    duration VARCHAR(100),
    is_active BOOLEAN DEFAULT true
);

-- Test Bookings
CREATE TABLE IF NOT EXISTS test_bookings (
    id SERIAL PRIMARY KEY,
    patient_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    test_id INTEGER REFERENCES lab_tests(id),
    lab_id INTEGER REFERENCES labs(id),
    booking_date DATE NOT NULL,
    booking_time TIME,
    is_home_visit BOOLEAN DEFAULT false,
    status VARCHAR(50) DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insurance Companies
CREATE TABLE IF NOT EXISTS insurance_companies (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    logo_url TEXT,
    description TEXT,
    contact_phone VARCHAR(50),
    contact_email VARCHAR(255),
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insurance Plans
CREATE TABLE IF NOT EXISTS insurance_plans (
    id SERIAL PRIMARY KEY,
    company_id INTEGER REFERENCES insurance_companies(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    coverage_details JSONB DEFAULT '{}',
    monthly_premium DECIMAL(10, 2),
    is_active BOOLEAN DEFAULT true
);

-- Emergency Numbers
CREATE TABLE IF NOT EXISTS emergency_numbers (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    number VARCHAR(50) NOT NULL,
    category VARCHAR(100),
    is_active BOOLEAN DEFAULT true
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_users_phone ON users(phone);
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_doctors_specialty ON doctors(specialty);
CREATE INDEX IF NOT EXISTS idx_doctors_available ON doctors(is_available);
CREATE INDEX IF NOT EXISTS idx_appointments_patient ON appointments(patient_id);
CREATE INDEX IF NOT EXISTS idx_appointments_doctor ON appointments(doctor_id);
CREATE INDEX IF NOT EXISTS idx_messages_consultation ON messages(consultation_id);
CREATE INDEX IF NOT EXISTS idx_orders_patient ON orders(patient_id);
CREATE INDEX IF NOT EXISTS idx_notifications_user ON notifications(user_id);
CREATE INDEX IF NOT EXISTS idx_products_pharmacy ON products(pharmacy_id);
