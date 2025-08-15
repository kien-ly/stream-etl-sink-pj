-- ================================================
-- PostgreSQL Dummy Data Script
-- Tables: public.event, public.product, public.directus_users
-- ================================================


-- Switch back to main database for dummy data
\c testdb;

-- Create directus_users table
CREATE TABLE IF NOT EXISTS public.directus_users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    email VARCHAR(128) UNIQUE NOT NULL,
    password VARCHAR(255),
    location VARCHAR(255),
    title VARCHAR(50),
    description TEXT,
    tags JSON,
    avatar UUID,
    language VARCHAR(255) DEFAULT 'en-US',
    theme VARCHAR(20) DEFAULT 'auto',
    tfa_secret VARCHAR(255),
    status VARCHAR(16) DEFAULT 'active',
    role UUID,
    token VARCHAR(255),
    last_access TIMESTAMP,
    last_page VARCHAR(255),
    provider VARCHAR(128) DEFAULT 'default',
    external_identifier VARCHAR(255),
    auth_data JSON,
    email_notifications BOOLEAN DEFAULT true,
    appearance VARCHAR(255),
    theme_dark VARCHAR(255),
    theme_light VARCHAR(255),
    theme_light_overrides JSON,
    theme_dark_overrides JSON,
    date_created TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    date_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create product table
CREATE TABLE IF NOT EXISTS public.product (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    price DECIMAL(10,2),
    category VARCHAR(100),
    sku VARCHAR(50) UNIQUE,
    stock_quantity INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    tags JSON,
    metadata JSON,
    created_by UUID REFERENCES public.directus_users(id),
    updated_by UUID REFERENCES public.directus_users(id),
    date_created TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    date_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create event table
CREATE TABLE IF NOT EXISTS public.event (
    id SERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    event_type VARCHAR(50),
    start_date TIMESTAMP,
    end_date TIMESTAMP,
    location VARCHAR(255),
    max_participants INTEGER,
    current_participants INTEGER DEFAULT 0,
    price DECIMAL(10,2) DEFAULT 0.00,
    is_public BOOLEAN DEFAULT true,
    status VARCHAR(20) DEFAULT 'active',
    tags JSON,
    metadata JSON,
    organizer_id UUID REFERENCES public.directus_users(id),
    created_by UUID REFERENCES public.directus_users(id),
    updated_by UUID REFERENCES public.directus_users(id),
    date_created TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    date_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ================================================
-- INSERT DUMMY DATA
-- ================================================

-- Insert dummy directus_users
INSERT INTO public.directus_users (
    id, first_name, last_name, email, password, location, title, description, 
    language, status, date_created, date_updated
) VALUES 
(gen_random_uuid(), 'John', 'Doe', 'john.doe@example.com', '$2b$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Ho Chi Minh City', 'Admin', 'System Administrator', 'vi-VN', 'active', NOW(), NOW()),
(gen_random_uuid(), 'Jane', 'Smith', 'jane.smith@example.com', '$2b$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Hanoi', 'Manager', 'Product Manager', 'vi-VN', 'active', NOW(), NOW()),
(gen_random_uuid(), 'Alice', 'Johnson', 'alice.johnson@example.com', '$2b$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Da Nang', 'Developer', 'Full Stack Developer', 'en-US', 'active', NOW(), NOW()),
(gen_random_uuid(), 'Bob', 'Wilson', 'bob.wilson@example.com', '$2b$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Can Tho', 'Analyst', 'Data Analyst', 'vi-VN', 'active', NOW(), NOW()),
(gen_random_uuid(), 'Emma', 'Brown', 'emma.brown@example.com', '$2b$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Hue', 'Designer', 'UI/UX Designer', 'en-US', 'inactive', NOW(), NOW());

-- Insert dummy products (using subquery to get user IDs)
INSERT INTO public.product (
    name, description, price, category, sku, stock_quantity, is_active, 
    tags, metadata, created_by, updated_by, date_created, date_updated
) VALUES 
('Laptop ASUS ROG', 'Gaming laptop with RTX 4070', 25000000.00, 'Electronics', 'LAP-ASUS-001', 15, true, 
 '["gaming", "laptop", "asus"]'::json, '{"warranty": "2 years", "color": "black"}'::json, 
 (SELECT id FROM public.directus_users WHERE email = 'jane.smith@example.com'), 
 (SELECT id FROM public.directus_users WHERE email = 'jane.smith@example.com'), NOW(), NOW()),

('iPhone 15 Pro', 'Latest iPhone with A17 Pro chip', 30000000.00, 'Electronics', 'IPH-15-PRO', 25, true, 
 '["smartphone", "apple", "ios"]'::json, '{"storage": "256GB", "color": "titanium"}'::json,
 (SELECT id FROM public.directus_users WHERE email = 'jane.smith@example.com'), 
 (SELECT id FROM public.directus_users WHERE email = 'alice.johnson@example.com'), NOW(), NOW()),

('Áo thun nam', 'Áo thun cotton 100% chất lượng cao', 350000.00, 'Fashion', 'TSH-MAN-001', 100, true, 
 '["clothing", "men", "cotton"]'::json, '{"size": ["S", "M", "L", "XL"], "material": "cotton"}'::json,
 (SELECT id FROM public.directus_users WHERE email = 'emma.brown@example.com'), 
 (SELECT id FROM public.directus_users WHERE email = 'emma.brown@example.com'), NOW(), NOW()),

('Sách lập trình Python', 'Sách học Python từ cơ bản đến nâng cao', 120000.00, 'Books', 'BOOK-PY-001', 50, true, 
 '["book", "programming", "python"]'::json, '{"pages": 450, "language": "vietnamese"}'::json,
 (SELECT id FROM public.directus_users WHERE email = 'alice.johnson@example.com'), 
 (SELECT id FROM public.directus_users WHERE email = 'bob.wilson@example.com'), NOW(), NOW()),

('Cà phê Arabica', 'Cà phê rang xay từ hạt Arabica chất lượng cao', 85000.00, 'Food & Beverage', 'COFFEE-ARA-001', 200, true, 
 '["coffee", "arabica", "organic"]'::json, '{"weight": "500g", "origin": "Vietnam"}'::json,
 (SELECT id FROM public.directus_users WHERE email = 'bob.wilson@example.com'), 
 (SELECT id FROM public.directus_users WHERE email = 'john.doe@example.com'), NOW(), NOW());

-- Insert dummy events
INSERT INTO public.event (
    title, description, event_type, start_date, end_date, location, 
    max_participants, current_participants, price, is_public, status,
    tags, metadata, organizer_id, created_by, updated_by, date_created, date_updated
) VALUES 
('Vietnam Tech Conference 2025', 'Hội thảo công nghệ lớn nhất Việt Nam năm 2025', 'conference', 
 '2025-08-15 09:00:00', '2025-08-16 18:00:00', 'SECC, Ho Chi Minh City', 1000, 250, 500000.00, true, 'active',
 '["tech", "conference", "vietnam"]'::json, '{"speakers": 20, "sessions": 15}'::json,
 (SELECT id FROM public.directus_users WHERE email = 'john.doe@example.com'),
 (SELECT id FROM public.directus_users WHERE email = 'john.doe@example.com'),
 (SELECT id FROM public.directus_users WHERE email = 'jane.smith@example.com'), NOW(), NOW()),

('Workshop React/Next.js', 'Workshop thực hành React và Next.js cho beginners', 'workshop', 
 '2025-07-20 14:00:00', '2025-07-20 17:00:00', 'Saigon Innovation Hub', 30, 18, 200000.00, true, 'active',
 '["workshop", "react", "nextjs", "programming"]'::json, '{"level": "beginner", "duration": "3 hours"}'::json,
 (SELECT id FROM public.directus_users WHERE email = 'alice.johnson@example.com'),
 (SELECT id FROM public.directus_users WHERE email = 'alice.johnson@example.com'),
 (SELECT id FROM public.directus_users WHERE email = 'alice.johnson@example.com'), NOW(), NOW()),

('Data Science Meetup', 'Meetup hàng tháng cho cộng đồng Data Science', 'meetup', 
 '2025-07-25 19:00:00', '2025-07-25 21:00:00', 'WeWork Bitexco, Ho Chi Minh City', 50, 35, 0.00, true, 'active',
 '["datascience", "meetup", "ai", "ml"]'::json, '{"networking": true, "food": "provided"}'::json,
 (SELECT id FROM public.directus_users WHERE email = 'bob.wilson@example.com'),
 (SELECT id FROM public.directus_users WHERE email = 'bob.wilson@example.com'),
 (SELECT id FROM public.directus_users WHERE email = 'bob.wilson@example.com'), NOW(), NOW()),

('UI/UX Design Bootcamp', 'Bootcamp thiết kế UI/UX 3 ngày intensive', 'bootcamp', 
 '2025-08-01 09:00:00', '2025-08-03 17:00:00', 'FPT University HCM', 25, 22, 1500000.00, true, 'active',
 '["design", "uiux", "bootcamp"]'::json, '{"duration": "3 days", "certificate": true}'::json,
 (SELECT id FROM public.directus_users WHERE email = 'emma.brown@example.com'),
 (SELECT id FROM public.directus_users WHERE email = 'emma.brown@example.com'),
 (SELECT id FROM public.directus_users WHERE email = 'jane.smith@example.com'), NOW(), NOW()),

('Startup Pitch Competition', 'Cuộc thi pitch startup cho các team trẻ', 'competition', 
 '2025-09-10 10:00:00', '2025-09-10 16:00:00', 'HCMC Startup Incubator', 100, 45, 100000.00, true, 'draft',
 '["startup", "pitch", "competition", "entrepreneur"]'::json, '{"prize": "$10000", "judges": 5}'::json,
 (SELECT id FROM public.directus_users WHERE email = 'john.doe@example.com'),
 (SELECT id FROM public.directus_users WHERE email = 'jane.smith@example.com'),
 (SELECT id FROM public.directus_users WHERE email = 'john.doe@example.com'), NOW(), NOW());

-- ================================================
-- VERIFICATION QUERIES
-- ================================================

-- Count records in each table
SELECT 'directus_users' as table_name, COUNT(*) as record_count FROM public.directus_users
UNION ALL
SELECT 'product' as table_name, COUNT(*) as record_count FROM public.product
UNION ALL
SELECT 'event' as table_name, COUNT(*) as record_count FROM public.event;

-- Show sample data
SELECT 'directus_users' as table_name, first_name, last_name, email, status FROM public.directus_users LIMIT 3;
SELECT 'product' as table_name, name, price, category, stock_quantity FROM public.product LIMIT 3;
SELECT 'event' as table_name, title, event_type, start_date, status FROM public.event LIMIT 3; 