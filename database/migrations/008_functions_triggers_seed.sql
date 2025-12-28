-- ============================================================================
-- TALENTFORGE ATS - DATABASE SCHEMA
-- Part 8: Functions, Triggers, Views, and Seed Data
-- ============================================================================

-- ============================================================================
-- SECTION 23: UTILITY FUNCTIONS
-- ============================================================================

-- -----------------------------------------------------------------------------
-- Function: update_updated_at_column
-- Purpose: Auto-update updated_at timestamp
-- -----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION update_updated_at_column() IS 'Auto-update updated_at timestamp on row update';

-- -----------------------------------------------------------------------------
-- Function: generate_slug
-- Purpose: Generate URL-safe slug from text
-- -----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION generate_slug(input_text TEXT)
RETURNS TEXT AS $$
BEGIN
    RETURN LOWER(
        REGEXP_REPLACE(
            REGEXP_REPLACE(
                unaccent(TRIM(input_text)),
                '[^a-zA-Z0-9\s-]', '', 'g'
            ),
            '[\s-]+', '-', 'g'
        )
    );
END;
$$ LANGUAGE plpgsql IMMUTABLE;

COMMENT ON FUNCTION generate_slug(TEXT) IS 'Generate URL-safe slug from text';

-- -----------------------------------------------------------------------------
-- Function: generate_reference_code
-- Purpose: Generate unique reference codes (e.g., JOB-2024-0001)
-- -----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION generate_reference_code(
    prefix TEXT,
    org_id UUID
)
RETURNS TEXT AS $$
DECLARE
    year_part TEXT;
    sequence_num INTEGER;
    result TEXT;
BEGIN
    year_part := TO_CHAR(NOW(), 'YYYY');
    
    -- Get next sequence number for this org and year
    SELECT COALESCE(MAX(
        CAST(
            SUBSTRING(reference_code FROM LENGTH(prefix) + 6 FOR 4) 
            AS INTEGER
        )
    ), 0) + 1
    INTO sequence_num
    FROM jobs
    WHERE organization_id = org_id
    AND reference_code LIKE prefix || '-' || year_part || '-%';
    
    result := prefix || '-' || year_part || '-' || LPAD(sequence_num::TEXT, 4, '0');
    RETURN result;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION generate_reference_code(TEXT, UUID) IS 'Generate unique reference codes like JOB-2024-0001';

-- -----------------------------------------------------------------------------
-- Function: calculate_experience_months
-- Purpose: Calculate total months between dates
-- -----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION calculate_experience_months(
    start_date DATE,
    end_date DATE
)
RETURNS INTEGER AS $$
BEGIN
    IF start_date IS NULL THEN
        RETURN 0;
    END IF;
    
    IF end_date IS NULL THEN
        end_date := CURRENT_DATE;
    END IF;
    
    RETURN EXTRACT(YEAR FROM AGE(end_date, start_date)) * 12 +
           EXTRACT(MONTH FROM AGE(end_date, start_date));
END;
$$ LANGUAGE plpgsql IMMUTABLE;

COMMENT ON FUNCTION calculate_experience_months(DATE, DATE) IS 'Calculate months between two dates';

-- -----------------------------------------------------------------------------
-- Function: update_candidate_search_vector
-- Purpose: Update full-text search vector for candidates
-- -----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION update_candidate_search_vector()
RETURNS TRIGGER AS $$
BEGIN
    NEW.search_vector := 
        setweight(to_tsvector('english', COALESCE(NEW.first_name, '')), 'A') ||
        setweight(to_tsvector('english', COALESCE(NEW.last_name, '')), 'A') ||
        setweight(to_tsvector('english', COALESCE(NEW.headline, '')), 'B') ||
        setweight(to_tsvector('english', COALESCE(NEW.current_title, '')), 'B') ||
        setweight(to_tsvector('english', COALESCE(NEW.current_company, '')), 'C') ||
        setweight(to_tsvector('english', COALESCE(NEW.profile_summary, '')), 'C') ||
        setweight(to_tsvector('english', COALESCE(array_to_string(NEW.tags, ' '), '')), 'D');
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION update_candidate_search_vector() IS 'Update candidate full-text search vector';

-- -----------------------------------------------------------------------------
-- Function: update_job_search_vector
-- Purpose: Update full-text search vector for jobs
-- -----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION update_job_search_vector()
RETURNS TRIGGER AS $$
BEGIN
    NEW.search_vector := 
        setweight(to_tsvector('english', COALESCE(NEW.title, '')), 'A') ||
        setweight(to_tsvector('english', COALESCE(NEW.summary, '')), 'B') ||
        setweight(to_tsvector('english', COALESCE(NEW.description, '')), 'C') ||
        setweight(to_tsvector('english', COALESCE(NEW.responsibilities, '')), 'C') ||
        setweight(to_tsvector('english', COALESCE(NEW.qualifications, '')), 'C');
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION update_job_search_vector() IS 'Update job full-text search vector';

-- ============================================================================
-- SECTION 24: TRIGGERS
-- ============================================================================

-- Apply updated_at trigger to all tables with the column
DO $$
DECLARE
    t TEXT;
BEGIN
    FOR t IN 
        SELECT table_name 
        FROM information_schema.columns 
        WHERE column_name = 'updated_at' 
        AND table_schema = 'public'
    LOOP
        EXECUTE format('
            DROP TRIGGER IF EXISTS trigger_update_%I_updated_at ON %I;
            CREATE TRIGGER trigger_update_%I_updated_at
            BEFORE UPDATE ON %I
            FOR EACH ROW
            EXECUTE FUNCTION update_updated_at_column();
        ', t, t, t, t);
    END LOOP;
END;
$$ LANGUAGE plpgsql;

-- Candidate search vector trigger
CREATE TRIGGER trigger_candidate_search_vector
BEFORE INSERT OR UPDATE OF first_name, last_name, headline, current_title, current_company, profile_summary, tags
ON candidates
FOR EACH ROW
EXECUTE FUNCTION update_candidate_search_vector();

-- Job search vector trigger
CREATE TRIGGER trigger_job_search_vector
BEFORE INSERT OR UPDATE OF title, summary, description, responsibilities, qualifications
ON jobs
FOR EACH ROW
EXECUTE FUNCTION update_job_search_vector();

-- ============================================================================
-- SECTION 25: VIEWS
-- ============================================================================

-- -----------------------------------------------------------------------------
-- View: v_active_jobs
-- Purpose: Currently active/open jobs
-- -----------------------------------------------------------------------------
CREATE OR REPLACE VIEW v_active_jobs AS
SELECT 
    j.*,
    o.name AS organization_name,
    d.name AS department_name,
    l.name AS location_name,
    u.first_name || ' ' || u.last_name AS hiring_manager_name
FROM jobs j
JOIN organizations o ON j.organization_id = o.id
LEFT JOIN organization_departments d ON j.department_id = d.id
LEFT JOIN organization_locations l ON j.location_id = l.id
LEFT JOIN users u ON j.hiring_manager_id = u.id
WHERE j.status = 'open'
AND j.deleted_at IS NULL;

COMMENT ON VIEW v_active_jobs IS 'Currently active/open jobs with related info';

-- -----------------------------------------------------------------------------
-- View: v_application_pipeline
-- Purpose: Application pipeline overview
-- -----------------------------------------------------------------------------
CREATE OR REPLACE VIEW v_application_pipeline AS
SELECT 
    a.id AS application_id,
    a.organization_id,
    a.job_id,
    j.title AS job_title,
    a.candidate_id,
    c.first_name || ' ' || c.last_name AS candidate_name,
    c.email AS candidate_email,
    c.current_title AS candidate_current_title,
    ps.name AS current_stage_name,
    ps.stage_type,
    a.status,
    a.overall_score,
    a.ai_recommendation,
    a.applied_at,
    a.last_activity_at,
    a.recruiter_rating,
    a.is_starred
FROM applications a
JOIN candidates c ON a.candidate_id = c.id
JOIN jobs j ON a.job_id = j.id
LEFT JOIN job_pipeline_stages ps ON a.current_stage_id = ps.id
WHERE a.deleted_at IS NULL;

COMMENT ON VIEW v_application_pipeline IS 'Application pipeline with candidate and job details';

-- -----------------------------------------------------------------------------
-- View: v_candidate_full_profile
-- Purpose: Complete candidate profile with aggregated data
-- -----------------------------------------------------------------------------
CREATE OR REPLACE VIEW v_candidate_full_profile AS
SELECT 
    c.*,
    -- Experience count
    (SELECT COUNT(*) FROM candidate_experience ce WHERE ce.candidate_id = c.id) AS experience_count,
    -- Education count
    (SELECT COUNT(*) FROM candidate_education ed WHERE ed.candidate_id = c.id) AS education_count,
    -- Skills count
    (SELECT COUNT(*) FROM candidate_skills cs WHERE cs.candidate_id = c.id) AS skills_count,
    -- Active applications
    (SELECT COUNT(*) FROM applications a WHERE a.candidate_id = c.id AND a.status NOT IN ('hired', 'rejected', 'withdrawn')) AS active_applications,
    -- Total applications
    (SELECT COUNT(*) FROM applications a WHERE a.candidate_id = c.id) AS total_applications,
    -- Country name
    co.name AS country_name,
    -- City name
    ci.name AS city_name
FROM candidates c
LEFT JOIN countries co ON c.country_id = co.id
LEFT JOIN cities ci ON c.city_id = ci.id
WHERE c.deleted_at IS NULL;

COMMENT ON VIEW v_candidate_full_profile IS 'Complete candidate profile with aggregated counts';

-- -----------------------------------------------------------------------------
-- View: v_interview_schedule
-- Purpose: Upcoming interviews
-- -----------------------------------------------------------------------------
CREATE OR REPLACE VIEW v_interview_schedule AS
SELECT 
    i.*,
    a.candidate_id,
    c.first_name || ' ' || c.last_name AS candidate_name,
    c.email AS candidate_email,
    j.title AS job_title,
    it.name AS interview_type_name,
    array_agg(u.first_name || ' ' || u.last_name) AS interviewer_names
FROM interviews i
JOIN applications a ON i.application_id = a.id
JOIN candidates c ON a.candidate_id = c.id
JOIN jobs j ON a.job_id = j.id
LEFT JOIN interview_types it ON i.interview_type_id = it.id
LEFT JOIN interview_participants ip ON i.id = ip.interview_id
LEFT JOIN users u ON ip.user_id = u.id
WHERE i.status IN ('scheduled', 'confirmed')
AND i.scheduled_at > NOW()
GROUP BY i.id, a.candidate_id, c.first_name, c.last_name, c.email, j.title, it.name;

COMMENT ON VIEW v_interview_schedule IS 'Upcoming interview schedule';

-- -----------------------------------------------------------------------------
-- View: v_organization_stats
-- Purpose: Organization-level statistics
-- -----------------------------------------------------------------------------
CREATE OR REPLACE VIEW v_organization_stats AS
SELECT 
    o.id AS organization_id,
    o.name AS organization_name,
    o.subscription_tier,
    -- Counts
    (SELECT COUNT(*) FROM users u WHERE u.organization_id = o.id AND u.deleted_at IS NULL) AS user_count,
    (SELECT COUNT(*) FROM jobs j WHERE j.organization_id = o.id AND j.deleted_at IS NULL) AS total_jobs,
    (SELECT COUNT(*) FROM jobs j WHERE j.organization_id = o.id AND j.status = 'open' AND j.deleted_at IS NULL) AS open_jobs,
    (SELECT COUNT(*) FROM candidates c WHERE c.organization_id = o.id AND c.deleted_at IS NULL) AS total_candidates,
    (SELECT COUNT(*) FROM applications a WHERE a.organization_id = o.id AND a.deleted_at IS NULL) AS total_applications,
    -- Recent activity
    (SELECT COUNT(*) FROM applications a WHERE a.organization_id = o.id AND a.applied_at > NOW() - INTERVAL '7 days') AS applications_last_7_days,
    (SELECT COUNT(*) FROM applications a WHERE a.organization_id = o.id AND a.outcome = 'hired' AND a.outcome_at > NOW() - INTERVAL '30 days') AS hires_last_30_days
FROM organizations o
WHERE o.deleted_at IS NULL;

COMMENT ON VIEW v_organization_stats IS 'Organization-level statistics dashboard';

-- ============================================================================
-- SECTION 26: SEED DATA
-- ============================================================================

-- Insert education levels
INSERT INTO education_levels (code, name, rank, description) VALUES
('high_school', 'High School Diploma', 1, 'High school or equivalent'),
('associate', 'Associate Degree', 2, 'Two-year college degree'),
('bachelor', 'Bachelor''s Degree', 3, 'Four-year undergraduate degree'),
('master', 'Master''s Degree', 4, 'Graduate degree'),
('mba', 'MBA', 4, 'Master of Business Administration'),
('phd', 'Doctorate (PhD)', 5, 'Doctor of Philosophy'),
('md', 'Medical Degree (MD)', 5, 'Doctor of Medicine'),
('jd', 'Law Degree (JD)', 5, 'Juris Doctor'),
('professional', 'Professional Certification', 3, 'Industry certification')
ON CONFLICT (code) DO NOTHING;

-- Insert skill categories
INSERT INTO skill_categories (name, description, sort_order) VALUES
('Programming Languages', 'Software programming languages', 1),
('Frameworks & Libraries', 'Software frameworks and libraries', 2),
('Databases', 'Database technologies', 3),
('Cloud & DevOps', 'Cloud platforms and DevOps tools', 4),
('Data Science & AI', 'Data science and AI/ML technologies', 5),
('Design', 'Design tools and skills', 6),
('Project Management', 'Project management methodologies', 7),
('Soft Skills', 'Interpersonal and communication skills', 8),
('Languages', 'Human languages', 9),
('Industry Knowledge', 'Domain-specific knowledge', 10)
ON CONFLICT (name) DO NOTHING;

-- Insert document types
INSERT INTO document_types (code, name, category, allowed_extensions, max_size_mb) VALUES
('resume', 'Resume/CV', 'resume', ARRAY['pdf', 'doc', 'docx'], 10),
('cover_letter', 'Cover Letter', 'cover_letter', ARRAY['pdf', 'doc', 'docx'], 5),
('portfolio', 'Portfolio', 'portfolio', ARRAY['pdf', 'zip'], 50),
('transcript', 'Academic Transcript', 'education', ARRAY['pdf'], 10),
('degree_certificate', 'Degree Certificate', 'education', ARRAY['pdf', 'jpg', 'png'], 10),
('id_proof', 'ID Proof', 'id', ARRAY['pdf', 'jpg', 'png'], 5),
('work_sample', 'Work Sample', 'portfolio', ARRAY['pdf', 'zip', 'doc', 'docx'], 25),
('reference_letter', 'Reference Letter', 'other', ARRAY['pdf'], 5),
('other', 'Other Document', 'other', ARRAY['pdf', 'doc', 'docx', 'jpg', 'png', 'zip'], 25)
ON CONFLICT (code) DO NOTHING;

-- Insert currencies
INSERT INTO currencies (code, name, symbol, decimal_places) VALUES
('USD', 'US Dollar', '$', 2),
('EUR', 'Euro', '€', 2),
('GBP', 'British Pound', '£', 2),
('INR', 'Indian Rupee', '₹', 2),
('CAD', 'Canadian Dollar', 'C$', 2),
('AUD', 'Australian Dollar', 'A$', 2),
('JPY', 'Japanese Yen', '¥', 0),
('CNY', 'Chinese Yuan', '¥', 2),
('SGD', 'Singapore Dollar', 'S$', 2),
('AED', 'UAE Dirham', 'د.إ', 2)
ON CONFLICT (code) DO NOTHING;

-- Insert languages
INSERT INTO languages (iso_code, iso_code_3, name, native_name) VALUES
('en', 'eng', 'English', 'English'),
('es', 'spa', 'Spanish', 'Español'),
('fr', 'fra', 'French', 'Français'),
('de', 'deu', 'German', 'Deutsch'),
('zh', 'zho', 'Chinese', '中文'),
('ja', 'jpn', 'Japanese', '日本語'),
('ko', 'kor', 'Korean', '한국어'),
('hi', 'hin', 'Hindi', 'हिन्दी'),
('ar', 'ara', 'Arabic', 'العربية'),
('pt', 'por', 'Portuguese', 'Português'),
('ru', 'rus', 'Russian', 'Русский'),
('it', 'ita', 'Italian', 'Italiano'),
('nl', 'nld', 'Dutch', 'Nederlands'),
('pl', 'pol', 'Polish', 'Polski'),
('tr', 'tur', 'Turkish', 'Türkçe')
ON CONFLICT (iso_code) DO NOTHING;

-- Insert job boards
INSERT INTO job_boards (name, code, website, api_available, supports_apply) VALUES
('LinkedIn', 'linkedin', 'https://www.linkedin.com', true, true),
('Indeed', 'indeed', 'https://www.indeed.com', true, true),
('Glassdoor', 'glassdoor', 'https://www.glassdoor.com', true, true),
('ZipRecruiter', 'ziprecruiter', 'https://www.ziprecruiter.com', true, true),
('Monster', 'monster', 'https://www.monster.com', true, true),
('Naukri', 'naukri', 'https://www.naukri.com', true, true),
('AngelList', 'angellist', 'https://angel.co', true, true),
('Stack Overflow Jobs', 'stackoverflow', 'https://stackoverflow.com/jobs', true, true)
ON CONFLICT (code) DO NOTHING;

-- Insert integration providers
INSERT INTO integration_providers (code, name, category, is_active) VALUES
('google_calendar', 'Google Calendar', 'calendar', true),
('outlook_calendar', 'Microsoft Outlook', 'calendar', true),
('slack', 'Slack', 'communication', true),
('teams', 'Microsoft Teams', 'communication', true),
('zoom', 'Zoom', 'video', true),
('google_meet', 'Google Meet', 'video', true),
('sendgrid', 'SendGrid', 'email', true),
('twilio', 'Twilio', 'sms', true),
('bamboohr', 'BambooHR', 'hris', true),
('workday', 'Workday', 'hris', true),
('hackerrank', 'HackerRank', 'assessment', true),
('codility', 'Codility', 'assessment', true),
('checkr', 'Checkr', 'background_check', true),
('zapier', 'Zapier', 'automation', true)
ON CONFLICT (code) DO NOTHING;

-- Insert permissions
INSERT INTO permissions (code, name, category) VALUES
-- Jobs
('jobs.view', 'View Jobs', 'jobs'),
('jobs.create', 'Create Jobs', 'jobs'),
('jobs.edit', 'Edit Jobs', 'jobs'),
('jobs.delete', 'Delete Jobs', 'jobs'),
('jobs.publish', 'Publish Jobs', 'jobs'),
-- Candidates
('candidates.view', 'View Candidates', 'candidates'),
('candidates.create', 'Create Candidates', 'candidates'),
('candidates.edit', 'Edit Candidates', 'candidates'),
('candidates.delete', 'Delete Candidates', 'candidates'),
('candidates.export', 'Export Candidates', 'candidates'),
-- Applications
('applications.view', 'View Applications', 'applications'),
('applications.manage', 'Manage Applications', 'applications'),
('applications.move_stage', 'Move Application Stage', 'applications'),
-- Interviews
('interviews.view', 'View Interviews', 'interviews'),
('interviews.schedule', 'Schedule Interviews', 'interviews'),
('interviews.feedback', 'Submit Interview Feedback', 'interviews'),
-- Offers
('offers.view', 'View Offers', 'offers'),
('offers.create', 'Create Offers', 'offers'),
('offers.approve', 'Approve Offers', 'offers'),
-- Reports
('reports.view', 'View Reports', 'reports'),
('reports.create', 'Create Reports', 'reports'),
('reports.export', 'Export Reports', 'reports'),
-- Settings
('settings.view', 'View Settings', 'settings'),
('settings.edit', 'Edit Settings', 'settings'),
('users.manage', 'Manage Users', 'settings'),
('integrations.manage', 'Manage Integrations', 'settings'),
('billing.view', 'View Billing', 'settings'),
('billing.manage', 'Manage Billing', 'settings')
ON CONFLICT (code) DO NOTHING;

-- Insert subscription plans
INSERT INTO subscription_plans (code, name, tier, price_monthly, price_yearly, max_users, max_jobs, max_candidates_per_month, is_active, sort_order) VALUES
('free', 'Free', 'free', 0, 0, 1, 1, 25, true, 1),
('starter', 'Starter', 'starter', 49, 490, 3, 5, 200, true, 2),
('pro', 'Professional', 'pro', 149, 1490, 10, 25, 1000, true, 3),
('business', 'Business', 'business', 299, 2990, 25, -1, 5000, true, 4),
('enterprise', 'Enterprise', 'enterprise', NULL, NULL, -1, -1, -1, true, 5)
ON CONFLICT (code) DO NOTHING;

-- ============================================================================
-- SECTION 27: SAMPLE SKILLS (Common tech skills)
-- ============================================================================

INSERT INTO skills (canonical_name, display_name, category_id, skill_type, is_verified) 
SELECT name, name, c.id, 'hard', true
FROM (VALUES
    ('JavaScript', 'Programming Languages'),
    ('TypeScript', 'Programming Languages'),
    ('Python', 'Programming Languages'),
    ('Java', 'Programming Languages'),
    ('C#', 'Programming Languages'),
    ('Go', 'Programming Languages'),
    ('Rust', 'Programming Languages'),
    ('Ruby', 'Programming Languages'),
    ('PHP', 'Programming Languages'),
    ('Swift', 'Programming Languages'),
    ('Kotlin', 'Programming Languages'),
    ('React', 'Frameworks & Libraries'),
    ('Angular', 'Frameworks & Libraries'),
    ('Vue.js', 'Frameworks & Libraries'),
    ('Node.js', 'Frameworks & Libraries'),
    ('Django', 'Frameworks & Libraries'),
    ('Flask', 'Frameworks & Libraries'),
    ('Spring Boot', 'Frameworks & Libraries'),
    ('Express.js', 'Frameworks & Libraries'),
    ('Next.js', 'Frameworks & Libraries'),
    ('PostgreSQL', 'Databases'),
    ('MySQL', 'Databases'),
    ('MongoDB', 'Databases'),
    ('Redis', 'Databases'),
    ('Elasticsearch', 'Databases'),
    ('AWS', 'Cloud & DevOps'),
    ('Azure', 'Cloud & DevOps'),
    ('Google Cloud', 'Cloud & DevOps'),
    ('Docker', 'Cloud & DevOps'),
    ('Kubernetes', 'Cloud & DevOps'),
    ('Terraform', 'Cloud & DevOps'),
    ('Jenkins', 'Cloud & DevOps'),
    ('Git', 'Cloud & DevOps'),
    ('Machine Learning', 'Data Science & AI'),
    ('Deep Learning', 'Data Science & AI'),
    ('TensorFlow', 'Data Science & AI'),
    ('PyTorch', 'Data Science & AI'),
    ('Data Analysis', 'Data Science & AI'),
    ('SQL', 'Data Science & AI'),
    ('Figma', 'Design'),
    ('Adobe XD', 'Design'),
    ('Sketch', 'Design'),
    ('UI Design', 'Design'),
    ('UX Design', 'Design'),
    ('Agile', 'Project Management'),
    ('Scrum', 'Project Management'),
    ('Jira', 'Project Management'),
    ('Leadership', 'Soft Skills'),
    ('Communication', 'Soft Skills'),
    ('Problem Solving', 'Soft Skills'),
    ('Team Collaboration', 'Soft Skills')
) AS s(name, category_name)
JOIN skill_categories c ON c.name = s.category_name
ON CONFLICT (canonical_name) DO NOTHING;

-- ============================================================================
-- COMPLETE
-- ============================================================================

-- Final message
DO $$
BEGIN
    RAISE NOTICE 'TalentForge ATS Database Schema Created Successfully!';
    RAISE NOTICE 'Tables: 60+';
    RAISE NOTICE 'Views: 5';
    RAISE NOTICE 'Functions: 5';
    RAISE NOTICE 'Triggers: Auto-generated for updated_at';
END;
$$ LANGUAGE plpgsql;
