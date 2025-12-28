-- ============================================================================
-- TALENTFORGE ATS - DATABASE SCHEMA
-- Part 3: Candidates, Education, Experience, Skills, Documents
-- ============================================================================

-- ============================================================================
-- SECTION 7: CANDIDATES
-- ============================================================================

-- -----------------------------------------------------------------------------
-- Table: candidates
-- Purpose: Core candidate/applicant records
-- -----------------------------------------------------------------------------
CREATE TABLE candidates (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    
    -- Identity
    email VARCHAR(255) NOT NULL,
    email_verified_at TIMESTAMPTZ,
    secondary_email VARCHAR(255),
    phone VARCHAR(30),
    phone_country_code VARCHAR(5),
    secondary_phone VARCHAR(30),
    
    -- Name
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    middle_name VARCHAR(100),
    preferred_name VARCHAR(100),
    
    -- Professional
    headline VARCHAR(255),                       -- "Senior Software Engineer at Google"
    current_title VARCHAR(150),
    current_company VARCHAR(200),
    
    -- Location
    address_line1 VARCHAR(255),
    address_line2 VARCHAR(255),
    city_id INTEGER REFERENCES cities(id),
    state_province_id INTEGER REFERENCES states_provinces(id),
    country_id INTEGER REFERENCES countries(id),
    postal_code VARCHAR(20),
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    timezone VARCHAR(50),
    
    -- Work preferences
    willing_to_relocate BOOLEAN,
    preferred_locations JSONB DEFAULT '[]',      -- Array of location preferences
    preferred_workplace_type workplace_type,
    preferred_job_types job_type[] DEFAULT '{}',
    
    -- Compensation
    current_salary_amount DECIMAL(15, 2),
    current_salary_currency_id INTEGER REFERENCES currencies(id),
    expected_salary_min DECIMAL(15, 2),
    expected_salary_max DECIMAL(15, 2),
    expected_salary_currency_id INTEGER REFERENCES currencies(id),
    salary_negotiable BOOLEAN DEFAULT true,
    
    -- Experience summary
    total_experience_years DECIMAL(4, 1),
    total_experience_months INTEGER,
    
    -- Source
    source candidate_source,
    source_details VARCHAR(255),                 -- Specific campaign, referrer name, etc.
    referrer_user_id UUID REFERENCES users(id),
    referrer_candidate_id UUID REFERENCES candidates(id),
    
    -- Social/Links
    linkedin_url VARCHAR(500),
    github_url VARCHAR(500),
    portfolio_url VARCHAR(500),
    personal_website VARCHAR(500),
    twitter_url VARCHAR(500),
    social_links JSONB DEFAULT '{}',
    
    -- Resume/Profile
    resume_url VARCHAR(500),
    resume_text TEXT,                            -- Extracted plain text
    resume_parsed_at TIMESTAMPTZ,
    resume_parsing_confidence DECIMAL(3, 2),
    profile_summary TEXT,
    
    -- Generated Portfolio
    portfolio_generated BOOLEAN DEFAULT false,
    portfolio_slug VARCHAR(100),
    portfolio_theme VARCHAR(50),
    portfolio_url VARCHAR(500),
    portfolio_views INTEGER DEFAULT 0,
    
    -- Status
    status candidate_status NOT NULL DEFAULT 'active',
    availability_date DATE,
    notice_period_days INTEGER,
    
    -- Tags and notes
    tags TEXT[] DEFAULT '{}',
    internal_notes TEXT,
    
    -- Privacy
    do_not_contact BOOLEAN DEFAULT false,
    do_not_contact_reason TEXT,
    gdpr_consent_at TIMESTAMPTZ,
    gdpr_consent_ip INET,
    marketing_consent BOOLEAN DEFAULT false,
    
    -- Matching cache (denormalized for performance)
    skills_vector VECTOR(384),                   -- For semantic search (if using pgvector)
    search_vector TSVECTOR,                      -- For full-text search
    
    -- Audit columns
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by UUID,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_by UUID,
    deleted_at TIMESTAMPTZ,
    deleted_by UUID,
    
    UNIQUE(organization_id, email)
);

CREATE INDEX idx_candidates_org ON candidates(organization_id);
CREATE INDEX idx_candidates_email ON candidates(email);
CREATE INDEX idx_candidates_name ON candidates(last_name, first_name);
CREATE INDEX idx_candidates_status ON candidates(organization_id, status);
CREATE INDEX idx_candidates_source ON candidates(source);
CREATE INDEX idx_candidates_location ON candidates(country_id, city_id);
CREATE INDEX idx_candidates_experience ON candidates(total_experience_years);
CREATE INDEX idx_candidates_portfolio ON candidates(portfolio_slug) WHERE portfolio_slug IS NOT NULL;
CREATE INDEX idx_candidates_search ON candidates USING gin(search_vector);
CREATE INDEX idx_candidates_tags ON candidates USING gin(tags);
CREATE INDEX idx_candidates_deleted ON candidates(deleted_at) WHERE deleted_at IS NULL;
CREATE INDEX idx_candidates_created ON candidates(organization_id, created_at DESC);

COMMENT ON TABLE candidates IS 'Core candidate records with comprehensive profile data';

-- -----------------------------------------------------------------------------
-- Table: candidate_experience
-- Purpose: Work experience entries
-- -----------------------------------------------------------------------------
CREATE TABLE candidate_experience (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    candidate_id UUID NOT NULL REFERENCES candidates(id) ON DELETE CASCADE,
    
    -- Company
    company_name VARCHAR(200) NOT NULL,
    company_linkedin_url VARCHAR(500),
    company_website VARCHAR(500),
    company_industry_id INTEGER REFERENCES industries(id),
    company_size VARCHAR(30),
    
    -- Role
    title VARCHAR(150) NOT NULL,
    department VARCHAR(100),
    employment_type job_type,
    
    -- Location
    location_city_id INTEGER REFERENCES cities(id),
    location_country_id INTEGER REFERENCES countries(id),
    location_text VARCHAR(200),                  -- Fallback if city not matched
    is_remote BOOLEAN DEFAULT false,
    
    -- Duration
    start_date DATE,
    end_date DATE,
    is_current BOOLEAN DEFAULT false,
    duration_months INTEGER,                     -- Calculated
    
    -- Details
    description TEXT,
    responsibilities TEXT,
    achievements TEXT,
    
    -- Skills used (linked separately in candidate_experience_skills)
    
    -- Verification
    is_verified BOOLEAN DEFAULT false,
    verified_at TIMESTAMPTZ,
    verification_method VARCHAR(50),
    
    -- Display
    sort_order INTEGER DEFAULT 0,
    is_visible BOOLEAN DEFAULT true,
    
    -- Audit columns
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by UUID,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_by UUID
);

CREATE INDEX idx_exp_candidate ON candidate_experience(candidate_id);
CREATE INDEX idx_exp_company ON candidate_experience(company_name);
CREATE INDEX idx_exp_title ON candidate_experience(title);
CREATE INDEX idx_exp_dates ON candidate_experience(start_date, end_date);
CREATE INDEX idx_exp_current ON candidate_experience(candidate_id, is_current) WHERE is_current = true;

COMMENT ON TABLE candidate_experience IS 'Work experience history for candidates';

-- -----------------------------------------------------------------------------
-- Table: candidate_experience_skills
-- Purpose: Skills used in each experience entry
-- -----------------------------------------------------------------------------
CREATE TABLE candidate_experience_skills (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    experience_id UUID NOT NULL REFERENCES candidate_experience(id) ON DELETE CASCADE,
    skill_id INTEGER NOT NULL REFERENCES skills(id),
    
    -- Audit columns
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    UNIQUE(experience_id, skill_id)
);

CREATE INDEX idx_exp_skills_exp ON candidate_experience_skills(experience_id);
CREATE INDEX idx_exp_skills_skill ON candidate_experience_skills(skill_id);

COMMENT ON TABLE candidate_experience_skills IS 'Skills used in each work experience';

-- -----------------------------------------------------------------------------
-- Table: candidate_education
-- Purpose: Education history
-- -----------------------------------------------------------------------------
CREATE TABLE candidate_education (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    candidate_id UUID NOT NULL REFERENCES candidates(id) ON DELETE CASCADE,
    
    -- Institution
    institution_name VARCHAR(250) NOT NULL,
    institution_type VARCHAR(50),                -- university, college, bootcamp, online
    institution_country_id INTEGER REFERENCES countries(id),
    institution_city VARCHAR(100),
    institution_website VARCHAR(500),
    
    -- Degree
    education_level_id INTEGER REFERENCES education_levels(id),
    degree_name VARCHAR(150),                    -- Bachelor of Science, MBA, etc.
    field_of_study_id INTEGER REFERENCES fields_of_study(id),
    field_of_study_text VARCHAR(150),            -- Fallback
    major VARCHAR(150),
    minor VARCHAR(150),
    specialization VARCHAR(150),
    
    -- Duration
    start_date DATE,
    end_date DATE,
    is_current BOOLEAN DEFAULT false,
    
    -- Performance
    gpa DECIMAL(4, 2),
    gpa_scale DECIMAL(4, 2) DEFAULT 4.0,
    percentage DECIMAL(5, 2),
    grade VARCHAR(20),
    honors VARCHAR(100),                         -- Cum Laude, Summa Cum Laude, etc.
    
    -- Details
    description TEXT,
    activities TEXT,
    thesis_title VARCHAR(500),
    
    -- Verification
    is_verified BOOLEAN DEFAULT false,
    verified_at TIMESTAMPTZ,
    
    -- Display
    sort_order INTEGER DEFAULT 0,
    is_visible BOOLEAN DEFAULT true,
    
    -- Audit columns
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by UUID,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_by UUID
);

CREATE INDEX idx_edu_candidate ON candidate_education(candidate_id);
CREATE INDEX idx_edu_institution ON candidate_education(institution_name);
CREATE INDEX idx_edu_level ON candidate_education(education_level_id);
CREATE INDEX idx_edu_field ON candidate_education(field_of_study_id);
CREATE INDEX idx_edu_dates ON candidate_education(start_date, end_date);

COMMENT ON TABLE candidate_education IS 'Education history for candidates';

-- -----------------------------------------------------------------------------
-- Table: candidate_skills
-- Purpose: Candidate skills with proficiency
-- -----------------------------------------------------------------------------
CREATE TABLE candidate_skills (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    candidate_id UUID NOT NULL REFERENCES candidates(id) ON DELETE CASCADE,
    skill_id INTEGER NOT NULL REFERENCES skills(id),
    
    -- Proficiency
    proficiency_level VARCHAR(20),               -- beginner, intermediate, advanced, expert
    proficiency_score INTEGER CHECK (proficiency_score BETWEEN 1 AND 10),
    years_of_experience DECIMAL(4, 1),
    
    -- Source
    source VARCHAR(30) DEFAULT 'parsed',         -- parsed, self_reported, verified, inferred
    is_primary BOOLEAN DEFAULT false,            -- Top/highlighted skill
    
    -- Last used
    last_used_date DATE,
    
    -- Verification
    is_verified BOOLEAN DEFAULT false,
    verified_at TIMESTAMPTZ,
    verified_by_assessment_id UUID,
    
    -- Display
    is_visible BOOLEAN DEFAULT true,
    sort_order INTEGER DEFAULT 0,
    
    -- Audit columns
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by UUID,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_by UUID,
    
    UNIQUE(candidate_id, skill_id)
);

CREATE INDEX idx_cand_skills_candidate ON candidate_skills(candidate_id);
CREATE INDEX idx_cand_skills_skill ON candidate_skills(skill_id);
CREATE INDEX idx_cand_skills_proficiency ON candidate_skills(proficiency_level);
CREATE INDEX idx_cand_skills_primary ON candidate_skills(candidate_id, is_primary) WHERE is_primary = true;

COMMENT ON TABLE candidate_skills IS 'Candidate skills with proficiency levels';

-- -----------------------------------------------------------------------------
-- Table: candidate_certifications
-- Purpose: Professional certifications
-- -----------------------------------------------------------------------------
CREATE TABLE candidate_certifications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    candidate_id UUID NOT NULL REFERENCES candidates(id) ON DELETE CASCADE,
    
    -- Certification
    name VARCHAR(200) NOT NULL,
    issuing_organization VARCHAR(200) NOT NULL,
    credential_id VARCHAR(100),
    credential_url VARCHAR(500),
    
    -- Dates
    issue_date DATE,
    expiry_date DATE,
    is_permanent BOOLEAN DEFAULT false,
    
    -- Details
    description TEXT,
    
    -- Related skills
    related_skill_ids INTEGER[] DEFAULT '{}',
    
    -- Verification
    is_verified BOOLEAN DEFAULT false,
    verified_at TIMESTAMPTZ,
    
    -- Display
    sort_order INTEGER DEFAULT 0,
    is_visible BOOLEAN DEFAULT true,
    
    -- Audit columns
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by UUID,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_by UUID
);

CREATE INDEX idx_cert_candidate ON candidate_certifications(candidate_id);
CREATE INDEX idx_cert_name ON candidate_certifications(name);
CREATE INDEX idx_cert_org ON candidate_certifications(issuing_organization);
CREATE INDEX idx_cert_expiry ON candidate_certifications(expiry_date);

COMMENT ON TABLE candidate_certifications IS 'Professional certifications and licenses';

-- -----------------------------------------------------------------------------
-- Table: candidate_languages
-- Purpose: Language proficiencies
-- -----------------------------------------------------------------------------
CREATE TABLE candidate_languages (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    candidate_id UUID NOT NULL REFERENCES candidates(id) ON DELETE CASCADE,
    language_id INTEGER NOT NULL REFERENCES languages(id),
    
    -- Proficiency (CEFR scale)
    reading_level VARCHAR(10),                   -- A1, A2, B1, B2, C1, C2, Native
    writing_level VARCHAR(10),
    speaking_level VARCHAR(10),
    listening_level VARCHAR(10),
    overall_level VARCHAR(10),
    
    is_native BOOLEAN DEFAULT false,
    
    -- Display
    sort_order INTEGER DEFAULT 0,
    is_visible BOOLEAN DEFAULT true,
    
    -- Audit columns
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by UUID,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_by UUID,
    
    UNIQUE(candidate_id, language_id)
);

CREATE INDEX idx_cand_lang_candidate ON candidate_languages(candidate_id);
CREATE INDEX idx_cand_lang_language ON candidate_languages(language_id);

COMMENT ON TABLE candidate_languages IS 'Language proficiencies for candidates';

-- -----------------------------------------------------------------------------
-- Table: candidate_projects
-- Purpose: Notable projects/portfolio items
-- -----------------------------------------------------------------------------
CREATE TABLE candidate_projects (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    candidate_id UUID NOT NULL REFERENCES candidates(id) ON DELETE CASCADE,
    
    -- Project details
    name VARCHAR(200) NOT NULL,
    description TEXT,
    role VARCHAR(150),
    
    -- Links
    url VARCHAR(500),
    repository_url VARCHAR(500),
    demo_url VARCHAR(500),
    
    -- Media
    thumbnail_url VARCHAR(500),
    images JSONB DEFAULT '[]',
    
    -- Related experience
    experience_id UUID REFERENCES candidate_experience(id),
    
    -- Duration
    start_date DATE,
    end_date DATE,
    is_ongoing BOOLEAN DEFAULT false,
    
    -- Technologies
    technologies TEXT[],
    
    -- Display
    is_featured BOOLEAN DEFAULT false,
    sort_order INTEGER DEFAULT 0,
    is_visible BOOLEAN DEFAULT true,
    
    -- Audit columns
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by UUID,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_by UUID
);

CREATE INDEX idx_projects_candidate ON candidate_projects(candidate_id);
CREATE INDEX idx_projects_featured ON candidate_projects(candidate_id, is_featured) WHERE is_featured = true;

COMMENT ON TABLE candidate_projects IS 'Portfolio projects for candidates';

-- -----------------------------------------------------------------------------
-- Table: candidate_publications
-- Purpose: Publications, papers, articles
-- -----------------------------------------------------------------------------
CREATE TABLE candidate_publications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    candidate_id UUID NOT NULL REFERENCES candidates(id) ON DELETE CASCADE,
    
    -- Publication details
    title VARCHAR(500) NOT NULL,
    publication_type VARCHAR(50),                -- article, paper, book, patent, blog
    
    publisher VARCHAR(200),
    journal_name VARCHAR(200),
    
    -- Authors
    authors TEXT,
    is_primary_author BOOLEAN DEFAULT false,
    
    -- Links
    url VARCHAR(500),
    doi VARCHAR(100),
    
    -- Date
    publication_date DATE,
    
    -- Details
    abstract TEXT,
    citation_count INTEGER,
    
    -- Display
    sort_order INTEGER DEFAULT 0,
    is_visible BOOLEAN DEFAULT true,
    
    -- Audit columns
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by UUID,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_by UUID
);

CREATE INDEX idx_pub_candidate ON candidate_publications(candidate_id);
CREATE INDEX idx_pub_type ON candidate_publications(publication_type);

COMMENT ON TABLE candidate_publications IS 'Publications and patents for candidates';

-- -----------------------------------------------------------------------------
-- Table: candidate_awards
-- Purpose: Awards and honors
-- -----------------------------------------------------------------------------
CREATE TABLE candidate_awards (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    candidate_id UUID NOT NULL REFERENCES candidates(id) ON DELETE CASCADE,
    
    title VARCHAR(200) NOT NULL,
    issuer VARCHAR(200),
    date_received DATE,
    description TEXT,
    url VARCHAR(500),
    
    -- Display
    sort_order INTEGER DEFAULT 0,
    is_visible BOOLEAN DEFAULT true,
    
    -- Audit columns
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by UUID,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_by UUID
);

CREATE INDEX idx_awards_candidate ON candidate_awards(candidate_id);

COMMENT ON TABLE candidate_awards IS 'Awards and honors for candidates';

-- -----------------------------------------------------------------------------
-- Table: candidate_references
-- Purpose: Professional references
-- -----------------------------------------------------------------------------
CREATE TABLE candidate_references (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    candidate_id UUID NOT NULL REFERENCES candidates(id) ON DELETE CASCADE,
    
    -- Reference person
    name VARCHAR(150) NOT NULL,
    title VARCHAR(150),
    company VARCHAR(200),
    relationship VARCHAR(100),                   -- Manager, Colleague, Client, etc.
    
    -- Contact
    email VARCHAR(255),
    phone VARCHAR(30),
    linkedin_url VARCHAR(500),
    
    -- Status
    is_verified BOOLEAN DEFAULT false,
    verified_at TIMESTAMPTZ,
    reference_letter_url VARCHAR(500),
    
    -- Privacy
    can_contact BOOLEAN DEFAULT true,
    contact_notes TEXT,
    
    -- Display
    sort_order INTEGER DEFAULT 0,
    is_visible BOOLEAN DEFAULT true,
    
    -- Audit columns
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by UUID,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_by UUID
);

CREATE INDEX idx_refs_candidate ON candidate_references(candidate_id);

COMMENT ON TABLE candidate_references IS 'Professional references for candidates';
